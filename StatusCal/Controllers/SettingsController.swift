//
//  SettingsController.swift
//  CornerCal
//
//  Created by Alex Boldakov on 21/10/2017.
//  Copyright © 2020 Alex Boldakov. All rights reserved.
//

import Cocoa
import EventKit
import ServiceManagement


class SettingsController: NSObject, NSWindowDelegate {
    
    let defaultsManager = DefaultsManager.shared
    let keysToViewMap: [String]!
    var calendarsList: [EKCalendar] = []
    let calendarManager = CalendarManager.shared
    var selectedCalendars: Dictionary<String, String> = [:]
    
    @IBOutlet weak var calendarController: CalendarController! {
        didSet {
            calendarController.refreshEventsState()
        }
    }
    
    override init() {
        keysToViewMap = [
            defaultsManager.keys.SHOW_SECONDS_KEY,
            defaultsManager.keys.USE_HOURS_24_KEY,
            defaultsManager.keys.SHOW_AM_PM_KEY,
            defaultsManager.keys.SHOW_DATE_KEY,
            defaultsManager.keys.SHOW_DAY_OF_WEEK_KEY
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
            boxMap[i].state = defaultsManager.getBool(forKey: keysToViewMap[i]) ? .on : .off
        }
        
        updateAMPMEnabled()
        setCalendarsState()
        initLaunchLoginState()
    }
    
    func updateAMPMEnabled() {
        showAMPMBox.isEnabled = use24HoursBox.state == .off
    }
    
    @IBOutlet weak var loginLaunchBox: NSButton!
    
    @IBOutlet weak var showSecondsBox: NSButton!
    
    @IBOutlet weak var use24HoursBox: NSButton!
    
    @IBOutlet weak var showAMPMBox: NSButton!
    
    @IBOutlet weak var showDateBox: NSButton!
    
    @IBOutlet weak var showDayOfWeekBox: NSButton!
    
    @IBOutlet weak var showEventBox: NSButton!
    
    @IBOutlet weak var calendarsTableView: NSTableView!
    
    @IBAction func loginLaunchClicked(_ sender: NSButton) {
        let isAuto = sender.state == .on
        defaultsManager.setBool(isAuto, forKey: defaultsManager.keys.START_AT_LOGIN)
        SMLoginItemSetEnabled(Constants.launcherAppId as CFString, isAuto)
    }
    
    @IBAction func checkBoxClicked(_ sender: NSButton) {
        // we use tags defined for views to recognize the right checkbox
        // checkboxes use tags starting from 1
        if (sender.tag > 0 && sender.tag <= keysToViewMap.count) {
            let key = keysToViewMap[sender.tag - 1]
            
            defaultsManager.setBool(sender.state == .on, forKey: key)
            
            updateAMPMEnabled()
            calendarController.setDateFormat()
        }
    }
    
    @IBAction func showEventClicked(_ sender: NSButton) {
        defaultsManager.setBool(sender.state == .on, forKey: defaultsManager.keys.SHOW_EVENTS)
        
        if sender.state == .on {
            checkCalendarAuthorizationStatus()
        } else {
            calendarsList = []
            calendarsTableView.reloadData()
        }
        
        calendarController.refreshEventsState()
    }
    
    func initLaunchLoginState() {
        let isLaunchAtLoginEnabled = defaultsManager.getBool(forKey: defaultsManager.keys.START_AT_LOGIN)
        loginLaunchBox.state = isLaunchAtLoginEnabled ? .on : .off
    }
    
    func setCalendarsState() {
        let isEnabled = defaultsManager.getBool(forKey: defaultsManager.keys.SHOW_EVENTS)
        selectedCalendars = defaultsManager.getValue(forKey: defaultsManager.keys.SELECTED_CALENDARS) as? [String : String] ?? [:]
        
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
        calendarManager.requestAccess(completion: { (granted) in
            self.updateCalendarList()
        })
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
        
        defaultsManager.setAny(selectedCalendars, forKey: defaultsManager.keys.SELECTED_CALENDARS)
        calendarController.refreshEventsState()
    }
}


