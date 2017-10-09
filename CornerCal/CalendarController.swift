//
//  CalendarController.swift
//  CornerCal
//
//  Created by Emil Kreutzman on 08/10/2017.
//  Copyright © 2017 Emil Kreutzman. All rights reserved.
//

import Cocoa

class CalendarController: NSObject {
    
    let calendar = Calendar.autoupdatingCurrent
    let locale = Locale.autoupdatingCurrent
    let formatter = DateFormatter()
    
    var shownItemCount = 0
    var weekdays: [String] = []
    var daysInWeek = 0
    
    var month = 0
    var monthOffset = 0
    var today = 0
    
    var daysInCurrentMonth = 0
    var daysInLastMonth = 0
    var lastFirstWeekdayLastMonth = 0
    
    override init() {
        super.init()
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.locale = locale
        
        weekdays = calendar.veryShortWeekdaySymbols
        daysInWeek = weekdays.count
        
        let maxWeeksInMonth = (calendar.maximumRange(of: .day)?.upperBound)! / daysInWeek
        shownItemCount = daysInWeek * (maxWeeksInMonth + 2 + 1)
        
        updateCurrentlyShownDays()
    }
    
    private func daysInMonth(month: Date) -> Int {
        return (calendar.range(of: .day, in: .month, for: month)?.count)!
    }
    
    private func updateCurrentlyShownDays() {
        let now = Date()
        month = calendar.ordinality(of: .month, in: .era, for: now)!
        today = calendar.ordinality(of: .day, in: .era, for: now)!
        
        let currentMonth = calendar.date(byAdding: .month, value: monthOffset, to: now)!
        let lastMonth = calendar.date(byAdding: .month, value: Int(-1), to: currentMonth)!
        
        daysInCurrentMonth = daysInMonth(month: currentMonth)
        daysInLastMonth = daysInMonth(month: lastMonth)
        
        let lastMonthDay = calendar.ordinality(of: .day, in: .month, for: lastMonth)!
        let lastMonthWeekday = (daysInWeek + calendar.component(.weekday, from: lastMonth) - calendar.firstWeekday) % daysInWeek
        
        let temp = lastMonthDay - lastMonthWeekday
        lastFirstWeekdayLastMonth = (daysInLastMonth - temp) / daysInWeek * daysInWeek + temp
    }
    
    func itemCount() -> Int {
        return shownItemCount
    }
    
    func getItemAt(index: Int) -> String {
        if (index < daysInWeek) {
            return weekdays[(calendar.firstWeekday + index - 1) % daysInWeek]
        }
        
        let base = lastFirstWeekdayLastMonth + index - daysInWeek
        
        if (base <= daysInLastMonth) {
            return String(base)
        }
        
        return String((base - daysInLastMonth - 1) % daysInCurrentMonth + 1)
    }
    
    func getFormattedDate() -> String {
        return formatter.string(from: Date())
    }
    
    func getMonth() -> String {
        return "September 2017"
    }
    
    func incrementMonth() {
        
    }
    
    func decrementMonth() {
        
    }
    
    func resetMonth() {
        
    }
}
