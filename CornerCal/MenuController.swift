//
//  MenuController.swift
//  CornerCal
//
//  Created by Emil Kreutzman on 23/09/2017.
//  Copyright © 2017 Emil Kreutzman. All rights reserved.
//

import Cocoa

class MenuController: NSObject, NSCollectionViewDataSource {
    
    let firstRow = ["M", "T", "O", "T", "F", "S", "S"]
    // let firstCol = ["", "41", "42", "43", "44", "45", "46"]
    
    let calendar = Calendar.autoupdatingCurrent
    var dayOneInView: Date? = nil
    var todayInMonths: Date? = nil
    
    var monthsFromNow = 0
    
    let itemsInRow = 7
    let totalItemsInGrid = 7 * 7
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalItemsInGrid
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let id = NSUserInterfaceItemIdentifier.init(rawValue: "CalendarDayItem")
        
        let item = collectionView.makeItem(withIdentifier: id, for: indexPath)
        guard let calendarItem = item as? CalendarDayItem else {
            return item
        }
        
        let row = indexPath.item / itemsInRow
        let col = indexPath.item % itemsInRow
        
        calendarItem.setBold(bold: row == 0)
        
        if (row == 0) {
            calendarItem.setDate(date: firstRow[col])
            calendarItem.setIsParfOfSelectedMonth(isPart: true)
            calendarItem.setToday(today: false)
        } else {
            let daySinceFirstDay = (row - 1) * 7 + col
            
            if let d = dayOneInView {
                // 1. set month number of date view
                let currentDateInLoop = calendar.date(byAdding: Calendar.Component.day, value: daySinceFirstDay, to: d)!
                calendarItem.setDate(date: String(calendar.component(Calendar.Component.day, from: currentDateInLoop)))
                
                // 2. set red circle if date is today
                calendarItem.setToday(today: calendar.isDateInToday(currentDateInLoop))
                
                // 3. set grey background if date is not this month
                let isThisMonth = calendar.isDate(currentDateInLoop, equalTo: todayInMonths!, toGranularity: Calendar.Component.month)
                calendarItem.setIsParfOfSelectedMonth(isPart: isThisMonth)
            }
        }
        
        return calendarItem
    }
    
    func initDates() {
        let now = Date.init(timeIntervalSinceNow: 0)
        let calendar = Calendar.autoupdatingCurrent
        
        let startingDate = calendar.date(byAdding: Calendar.Component.month, value: monthsFromNow, to: now)!
        let dayInMonth = calendar.component(Calendar.Component.day, from: startingDate)
        let firstDayOfMonth = calendar.date(byAdding: Calendar.Component.day, value: -dayInMonth + 1, to: startingDate)!
        
        // 1-7, Sunday = 1
        let firstDayWeekday = calendar.component(Calendar.Component.weekday, from: firstDayOfMonth)
        let firstViewDay = calendar.date(byAdding: Calendar.Component.day, value: -(((firstDayWeekday + 4) % 7) + 1), to: firstDayOfMonth)!
        
        todayInMonths = startingDate
        dayOneInView = firstViewDay
        
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateFormat = "MMMM yyyy"
        monthLabel.stringValue = formatter.string(from: todayInMonths!)
    }
    

    @IBOutlet weak var statusMenu: NSMenu!
    
    @IBOutlet weak var monthLabel: NSTextField!
    
    @IBOutlet weak var collectionView: NSCollectionView!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    override func awakeFromNib() {
        statusItem.title = "CornerCal"
        statusItem.menu = statusMenu
        
        initDates()
    }
    
    private func setMonthsFromNow(monthsFromNow: Int) {
        self.monthsFromNow = monthsFromNow
        initDates()
        collectionView.reloadData()
    }
    
    @IBAction func leftClicked(_ sender: NSButton) {
        setMonthsFromNow(monthsFromNow: monthsFromNow - 1)
    }
    
    @IBAction func rightClicked(_ sender: NSButton) {
        setMonthsFromNow(monthsFromNow: monthsFromNow + 1)
    }
    
    @IBAction func clearMonthHopping(_ sender: NSButton) {
        setMonthsFromNow(monthsFromNow: 0)
    }

}
