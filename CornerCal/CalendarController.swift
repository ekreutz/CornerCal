//
//  CalendarController.swift
//  CornerCal
//
//  Created by Emil Kreutzman on 08/10/2017.
//  Copyright © 2020 Alex Boldakov. All rights reserved.
//

import Cocoa

struct Day {
    var isNumber = false
    var isToday = false
    var isCurrentMonth = false
    var text = "0"
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
    }
    
    func setDateFormat() {
        let defaults = UserDefaults.standard
        let keys = SettingsKeys()
        
        let showSeconds = defaults.bool(forKey: keys.SHOW_SECONDS_KEY)
        
        let use24Hours = defaults.bool(forKey: keys.USE_HOURS_24_KEY)
        let showAMPM = defaults.bool(forKey: keys.SHOW_AM_PM_KEY)
        let showDate = defaults.bool(forKey: keys.SHOW_DATE_KEY)
        let showDayOfWeek = defaults.bool(forKey: keys.SHOW_DAY_OF_WEEK_KEY)
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
        
        if (index < daysInWeek) {
            day.text = weekdays[(calendar.firstWeekday + index - 1) % daysInWeek].capitalizingFirstLetter()
        } else {
            let dayOffset = index - daysInWeek
            let date = calendar.date(byAdding: .day, value: dayOffset, to: lastFirstWeekdayLastMonth!)!
            
            day.isNumber = true
            day.text = String(calendar.ordinality(of: .day, in: .month, for: date)!)
            day.isCurrentMonth = calendar.isDate(date, equalTo: currentMonth!, toGranularity: .month)
            day.isToday = calendar.isDateInToday(date)
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
        monthOffset += 1
        updateCurrentlyShownDays()
        onCalendarUpdate?()
    }
    
    func decrementMonth() {
        monthOffset -= 1
        updateCurrentlyShownDays()
        onCalendarUpdate?()
    }
    
    func resetMonth() {
        monthOffset = 0
        updateCurrentlyShownDays()
        onCalendarUpdate?()
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    func uppercaseLast(count: Int) -> String {
        let index = self.index(self.endIndex, offsetBy: -2)
        let uppercasedString = String(self[index...]).uppercased()
        return self.dropLast(2) + uppercasedString
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    mutating func uppercaseLast(count: Int) {
        self = self.uppercaseLast(count: count)
    }
}
