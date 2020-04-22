//
//  SettingsController.swift
//  CornerCal
//
//  Created by Alex Boldakov on 21/10/2017.
//  Copyright © 2020 Alex Boldakov. All rights reserved.
//

import Cocoa
import EventKit

struct SettingsKeys {
    let SHOW_SECONDS_KEY = "TIME_WITH_SECONDS"
    let USE_HOURS_24_KEY = "USE_24_H"
    let SHOW_AM_PM_KEY = "AM_PM"
    let SHOW_DATE_KEY = "SHOW_DATE"
    let SHOW_DAY_OF_WEEK_KEY = "DAY_OF_WEEK"
    let SHOW_EVENTS = "SHOW_EVENTS"
    let SELECTED_CALENDARS = "SELECTED_CALENDARS"
}

class SettingsController: NSObject, NSWindowDelegate {
    
    let defaults: UserDefaults!
    let keysToViewMap: [String]!
    let keys = SettingsKeys()
    var calendarsList: [EKCalendar] = []
    let calendarManager = CalendarManager.shared
    var selectedCalendars: Dictionary<String, String> = [:]
    
    @IBOutlet weak var calendarController: CalendarController! {
        didSet {
            calendarController.refreshEventsState()
        }
    }
    
    override init() {
        defaults = UserDefaults.standard
        defaults.synchronize()
        
        keysToViewMap = [
            keys.SHOW_SECONDS_KEY,
            keys.USE_HOURS_24_KEY,
            keys.SHOW_AM_PM_KEY,
            keys.SHOW_DATE_KEY,
            keys.SHOW_DAY_OF_WEEK_KEY
        ]
        
        super.init()
    }
    
    func windowDidBecomeMain(_ notification: Notification) {
        let boxMap: [NSButton] = [
            showSecondsBox,
            use24HoursBox,
            showAMPMBox,
            showDateBox,
            showDayOfWeekBox
        ]
        
        // read values of checkboxes from the settings, and apply!
        for i in 0...(boxMap.count - 1) {
            boxMap[i].state = defaults.bool(forKey: keysToViewMap[i]) ? .on : .off
        }
        
        updateAMPMEnabled()
        setCalendarsState()
    }
    
    func updateAMPMEnabled() {
        showAMPMBox.isEnabled = use24HoursBox.state == .off
    }
    
    @IBOutlet weak var showSecondsBox: NSButton!
    
    @IBOutlet weak var use24HoursBox: NSButton!
    
    @IBOutlet weak var showAMPMBox: NSButton!
    
    @IBOutlet weak var showDateBox: NSButton!
    
    @IBOutlet weak var showDayOfWeekBox: NSButton!
    
    @IBOutlet weak var showEventBox: NSButton!
    
    @IBOutlet weak var calendarsTableView: NSTableView!
    
    @IBAction func checkBoxClicked(_ sender: NSButton) {
        // we use tags defined for views to recognize the right checkbox
        // checkboxes use tags starting from 1
        if (sender.tag > 0 && sender.tag <= keysToViewMap.count) {
            let key = keysToViewMap[sender.tag - 1]
            
            defaults.set(sender.state == .on, forKey: key)
            defaults.synchronize()
            
            updateAMPMEnabled()
            calendarController.setDateFormat()
        }
    }
    
    @IBAction func showEventClicked(_ sender: NSButton) {
        defaults.set(sender.state == .on, forKey: keys.SHOW_EVENTS)
        defaults.synchronize()
        
        if sender.state == .on {
            checkCalendarAuthorizationStatus()
        } else {
            calendarsList = []
            calendarsTableView.reloadData()
        }
        
        calendarController.refreshEventsState()
    }
    
    func setCalendarsState() {
        let isEnabled = defaults.bool(forKey: keys.SHOW_EVENTS)
        selectedCalendars = defaults.value(forKey: keys.SELECTED_CALENDARS) as? [String : String] ?? [:]
        
        if (isEnabled) {
            showEventBox.state = .on
            checkCalendarAuthorizationStatus()
        } else {
            showEventBox.state = .off
        }
    }
    
    func checkCalendarAuthorizationStatus() {
        switch (calendarManager.storeStatus()) {

        case EKAuthorizationStatus.notDetermined:
            requestPermissions()
            break
        case EKAuthorizationStatus.authorized:
            updateCalendarList()
            break
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:

            break
        default: break

        }
    }
    
    func updateCalendarList() {
        DispatchQueue.main.async(execute: {
            self.calendarsList = self.calendarManager.getCalendars()
            self.calendarsTableView.reloadData()
        })
    }
    
    func requestPermissions() {
        let granted = calendarManager.requescAccess()
        
        if granted {
            self.updateCalendarList()
        }
    }
}

extension SettingsController: NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return calendarsList.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let calendarItem = calendarsList[row]
        
        if tableColumn == tableView.tableColumns[0] {
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "textCell"), owner: self) as? NSTableCellView
            cell?.textField?.stringValue = calendarItem.title
            return cell
        } else  {
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "chekboxCell"), owner: self) as? CheckboxCell
            cell?.calendar = calendarItem
            cell?.delegate = self
            
            let isSelected = selectedCalendars[calendarItem.title] != nil
            
            if isSelected {
                cell?.chekbox?.state = .on
            } else {
                cell?.chekbox?.state = .off
            }
            return cell
        }
    }
}

extension SettingsController: CheckboxCellViewDelegate {
    func checkboxChecked(isChecked: Bool, calendarItem: EKCalendar) {
        
        if isChecked {
            selectedCalendars.updateValue(calendarItem.calendarIdentifier, forKey: calendarItem.title)
        } else {
            selectedCalendars.removeValue(forKey: calendarItem.title)
        }
        
        defaults.set(selectedCalendars, forKey: keys.SELECTED_CALENDARS)
        defaults.synchronize()
        
        calendarController.refreshEventsState()
    }
}


