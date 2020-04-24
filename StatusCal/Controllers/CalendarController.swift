//
//  CalendarController.swift
//  CornerCal
//
//  Created by Alex Boldakov on 08/10/2017.
//  Copyright © 2020 Alex Boldakov. All rights reserved.
//

import Cocoa
import EventKit

struct Day {
    var isNumber = false
    var isToday = false
    var isCurrentMonth = false
    var text = "0"
    var date = Date()
    var formattedDate = ""
    var hasEvents = false
}

class CalendarController: NSObject {
    var calendar = Calendar.current
    let formatter = DateFormatter()
    let monthFormatter = DateFormatter()
    var locale: Locale!
    var timer: Timer? = nil
    
    var shownItemCount = 0
    var weekdays: [String] = []
    var daysInWeek = 0
    var monthOffset = 0
    
    var currentMonth: Date? = nil
    var lastFirstWeekdayLastMonth: Date? = nil
    var lastTick: Date? = Date()
    var tick: Date? = nil
    var tickInterval: Double = 60
    
    var onTimeUpdate: (() -> ())? = nil
    var onCalendarUpdate: (() -> ())? = nil
    var eventStore = CalendarManager.shared
    var calendarGranted: Bool = false
    
    var events: Dictionary<Int, Int> = [:]
    var showEvents: Bool = false
    var enabledCalendars: [String: String] = [:]
    
    let defaultsManager = DefaultsManager.shared
    
    override init() {
        super.init()
        
        let languageIdentifier = Locale.preferredLanguages[0]
        locale = Locale.init(identifier: languageIdentifier)
        
        monthFormatter.locale = locale
        monthFormatter.dateFormat = "LLLL yyyy"
        
        calendar.locale = locale
        weekdays = calendar.veryShortWeekdaySymbols
        daysInWeek = weekdays.count
        
        let maxWeeksInMonth = (calendar.maximumRange(of: .day)?.upperBound)! / daysInWeek
        shownItemCount = daysInWeek * (maxWeeksInMonth + 2 + 1)
        
        updateCurrentlyShownDays()
        checkCalendarAuthorizationStatus()
    }
    
    func setDateFormat() {
        let showSeconds = defaultsManager.getBool(forKey: defaultsManager.keys.SHOW_SECONDS_KEY)
        let use24Hours = defaultsManager.getBool(forKey:  defaultsManager.keys.USE_HOURS_24_KEY)
        let showAMPM = defaultsManager.getBool(forKey:  defaultsManager.keys.SHOW_AM_PM_KEY)
        let showDate = defaultsManager.getBool(forKey:  defaultsManager.keys.SHOW_DATE_KEY)
        let showDayOfWeek = defaultsManager.getBool(forKey:  defaultsManager.keys.SHOW_DAY_OF_WEEK_KEY)
        
        let showAnyDateInfo = showDayOfWeek || showDate
        
        formatter.locale = locale
        
        var dateTemplate = ""
        dateTemplate += (showDayOfWeek) ? "EEE" : ""
        dateTemplate += (showDate) ? "dMMM" : ""
        
        formatter.setLocalizedDateFormatFromTemplate(dateTemplate)
        let dateFormat = (showAnyDateInfo) ? formatter.dateFormat! + " " : ""
        
        var timeTemplate = "mm"
        timeTemplate += (showSeconds) ? "ss" : ""
        timeTemplate += (use24Hours) ? "H" : "h"
        
        formatter.setLocalizedDateFormatFromTemplate(timeTemplate)
        var timeFormat = formatter.dateFormat!
        
        if (use24Hours || !showAMPM) {
            timeFormat = timeFormat.replacingOccurrences(of: "a", with: "")
        }
        
        formatter.dateFormat = String(format: "%@%@", dateFormat, timeFormat)
        initTiming(useSeconds: showSeconds)
    }
    
    private func onTick(timer: Timer) {
        tick = calendar.date(byAdding: .second, value: Int(tickInterval), to: lastTick!)
        
        onTimeUpdate?()
        if (!calendar.isDate(tick!, equalTo: lastTick!, toGranularity: .day)) {
            onCalendarUpdate?()
        }
        
        let now = Date()
        let timeDeviation = abs((tick?.timeIntervalSince1970)! - now.timeIntervalSince1970)
        
        // allow maximum time deviation of 0.5 seconds
        if (timeDeviation > 0.5) {
            tick = now
        }
        
        lastTick = tick
    }
    
    private func initTiming(useSeconds: Bool) {
        tickInterval = (useSeconds) ? 1 : 60
        let now = Date()
        let fireAfter = (useSeconds) ? 1 : 60 - calendar.component(.second, from: now)
        
        // kill any previous timers
        timer?.invalidate()
        
        let fireAt = calendar.date(byAdding: .second, value: fireAfter, to: now)!
        timer = Timer(fire: fireAt, interval: tickInterval, repeats: true, block: onTick)
        RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
        
        // tick once to update straight away
        lastTick = calendar.date(byAdding: .second, value: Int(-tickInterval), to: now)
        onTick(timer: timer!)
    }
    
    private func daysInMonth(month: Date) -> Int {
        return (calendar.range(of: .day, in: .month, for: month)?.count)!
    }
    
    private func getLastFirstWeekday(month: Date) -> Date {
        // zero-based weekday of the date "month"
        let weekday = (daysInWeek + calendar.component(.weekday, from: month) - calendar.firstWeekday) % daysInWeek
        
        // the date of the first day that same week (eg. the monday of that week)
        let d = calendar.ordinality(of: .day, in: .month, for: month)! - weekday
        
        // calculate full weeks left after the day number "d" and add that to d, to get the "last first day of the month"
        let totalDaysInMonth = daysInMonth(month: month)
        let lastFirstWeekdayNumber = (totalDaysInMonth - d) / daysInWeek * daysInWeek + d
        let dayOfMonth = calendar.ordinality(of: .day, in: .month, for: month)!

        return calendar.date(byAdding: .day, value: (lastFirstWeekdayNumber - dayOfMonth), to: month)!
    }
    
    private func updateCurrentlyShownDays() {
        currentMonth = calendar.date(byAdding: .month, value: Int(monthOffset), to: Date())!
        let lastMonth = calendar.date(byAdding: .month, value: Int(-1), to: currentMonth!)!
        lastFirstWeekdayLastMonth = getLastFirstWeekday(month: lastMonth)
    }
    
    func subscribe(onTimeUpdate: @escaping () -> (), onCalendarUpdate: @escaping () -> ()) {
        self.onTimeUpdate = onTimeUpdate
        self.onCalendarUpdate = onCalendarUpdate
        
        if (tick == nil) {
            onCalendarUpdate()
            setDateFormat()
        }
    }
    
    func pause() {
        timer?.invalidate()
        tick = nil
    }
    
    func itemCount() -> Int {
        return shownItemCount
    }
    
    func getItemAt(index: Int) -> Day {
        var day = Day()
        let dayOffset = index - daysInWeek
        let mDate = calendar.date(byAdding: .day, value: dayOffset, to: lastFirstWeekdayLastMonth!)!
        let date = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: mDate)!
        let endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: mDate)!
        
        if (index < daysInWeek) {
            // For days of week label (Mon, Teu ... etc)
            day.text = weekdays[(calendar.firstWeekday + index - 1) % daysInWeek].capitalizingFirstLetter()
            day.date = date
            day.formattedDate = formatter.string(from: date)
        } else {
            // For days
            day.date = date
            day.formattedDate = formatter.string(from: date)
            day.isNumber = true
            day.text = String(calendar.ordinality(of: .day, in: .month, for: date)!)
            day.isCurrentMonth = calendar.isDate(date, equalTo: currentMonth!, toGranularity: .month)
            day.isToday = calendar.isDateInToday(date)
            day.hasEvents = dateHasEvents(date: date, endDate: endDate)
        }
        
        return day
    }
    
    func getFormattedDate() -> String {
        var formatted = formatter.string(from: tick!).capitalizingFirstLetter()
        
        if formatted.contains("pm") || formatted.contains("am") {
            formatted = formatted.uppercaseLast(count: 2)
        }
        
        return formatted
    }
    
    func getMonth() -> String {
        return monthFormatter.string(from: currentMonth!).capitalizingFirstLetter()
    }
    
    func incrementMonth() {
        DispatchQueue.main.async(execute: {
            self.monthOffset += 1
            self.updateCurrentlyShownDays()
            self.onCalendarUpdate?()
        })
    }
    
    func decrementMonth() {
        DispatchQueue.main.async(execute: {
            self.monthOffset -= 1
            self.updateCurrentlyShownDays()
            self.onCalendarUpdate?()
        })
    }
    
    func resetMonth() {
        DispatchQueue.main.async(execute: {
            self.monthOffset = 0
            self.updateCurrentlyShownDays()
            self.onCalendarUpdate?()
        })
    }
    
    func dateHasEvents(date: Date, endDate: Date) -> Bool {
        if !showEvents {
            return false
        }
        
        let calendars = eventStore.getCalendars().filter { enabledCalendars[$0.title] != nil }

        for calendar in calendars {
            let contains = eventStore.containsEvents(startDate: date, endDate: endDate, calendar: calendar)
            if contains {
                return contains
            }
        }

        return false
    }
    
    func refreshEventsState() {
        showEvents = defaultsManager.getBool(forKey: defaultsManager.keys.SHOW_EVENTS)
        enabledCalendars = defaultsManager.getValue(forKey: defaultsManager.keys.SELECTED_CALENDARS) as? [String : String] ?? [:]
        resetMonth()
    }
    
    func requestPermissions() {
        eventStore.requestAccess(completion: { (granted) in
            self.calendarGranted = granted
        })
    }
    
    func checkCalendarAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)

        switch (status) {

        case EKAuthorizationStatus.notDetermined:
            requestPermissions()
        case EKAuthorizationStatus.authorized:
            self.calendarGranted = true
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            print("RESTRICTED or DENIED")
            showMessagePrompt("RESTRICTED", message: "RESTRICTED or DENIED")
        default: break

        }
    }
    
    func showMessagePrompt(_ title: String, message: String) {
        let alert = NSAlert.init()
        alert.informativeText = title
        alert.messageText = message
        
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
