//
//  CalendarController.swift
//  CornerCal
//
//  Created by Emil Kreutzman on 08/10/2017.
//  Copyright © 2017 Emil Kreutzman. All rights reserved.
//

import Cocoa

struct Day {
    var isNumber = false
    var isToday = false
    var isCurrentMonth = false
    var text = "0"
}

class CalendarController: NSObject {
    
    let calendar = Calendar.autoupdatingCurrent
    let formatter = DateFormatter()
    let monthFormatter = DateFormatter()
    var locale: Locale!
    var dayZero: Date? = nil
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
        monthFormatter.dateFormat = "MMMM yyyy"
        
        weekdays = calendar.veryShortWeekdaySymbols
        daysInWeek = weekdays.count
        
        let maxWeeksInMonth = (calendar.maximumRange(of: .day)?.upperBound)! / daysInWeek
        shownItemCount = daysInWeek * (maxWeeksInMonth + 2 + 1)
        
        calculateDayZero()
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
        let dateFormat = (showAnyDateInfo) ? formatter.dateFormat!.replacingOccurrences(of: ",", with: "") + "  " : ""
        
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
        
        // allow maximum time deviation of 1.5 seconds
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
        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
        
        // tick once to update straight away
        lastTick = calendar.date(byAdding: .second, value: Int(-tickInterval), to: now)
        onTick(timer: timer!)
    }
    
    private func calculateDayZero() {
        dayZero = Date(timeIntervalSince1970: 86400 * 5)
        let now = Date()
        
        let dayZeroOrdinality = calendar.ordinality(of: .month, in: .era, for: dayZero!)!
        let nowOrdinality = calendar.ordinality(of: .month, in: .era, for: now)!
        
        monthOffset = nowOrdinality - dayZeroOrdinality
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
        return calendar.date(bySetting: .day, value: lastFirstWeekdayNumber, of: month)!
    }
    
    private func updateCurrentlyShownDays() {
        currentMonth = calendar.date(byAdding: .month, value: monthOffset, to: dayZero!)
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
    
    func itemCount() -> Int {
        return shownItemCount
    }
    
    func getItemAt(index: Int) -> Day {
        var day = Day()
        
        if (index < daysInWeek) {
            day.text = weekdays[(calendar.firstWeekday + index - 1) % daysInWeek]
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
        // notice the added spaces around the date itself
        // they're used as a hack to stop the date from wobbling around in the menu item
        // basically, we're forcing an overflow here
        return String(format: " %@    .", formatter.string(from: tick!))
    }
    
    func getMonth() -> String {
        return monthFormatter.string(from: currentMonth!)
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
        calculateDayZero()
        updateCurrentlyShownDays()
        onCalendarUpdate?()
    }
}
