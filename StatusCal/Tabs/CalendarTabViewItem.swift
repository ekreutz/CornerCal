//
//  CalendarTabViewItem.swift
//  StatusCal
//
//  Created by Alexey Boldakov on 30.04.2020.
//  Copyright © 2020 Alex Boldakov. All rights reserved.
//

import Cocoa
import EventKit

class CalendarTabViewItem: NSTabViewItem {
    
    weak var delegate: CalendarTabViewItemDelegate? = nil
    
    @IBOutlet weak var showEventBox: NSButton!
    
    @IBOutlet weak var calendarsTableView: NSTableView! {
        didSet {
            calendarsTableView.delegate = self
            calendarsTableView.dataSource = self
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
        delegate?.calendarSettingsChanged()
    }
    
    let defaultsManager = DefaultsManager.shared
    var calendarsList: [EKCalendar] = []
    let calendarManager = CalendarManager.shared
    var selectedCalendars: Dictionary<String, String> = [:]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func initState() {
        setCalendarsState()
    }
    
    private func setCalendarsState() {
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
        case EKAuthorizationStatus.authorized:
            updateCalendarList()
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            break
        default:
            break
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

extension CalendarTabViewItem: NSTableViewDelegate, NSTableViewDataSource {
    
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

extension CalendarTabViewItem: CheckboxCellViewDelegate {
    func checkboxChecked(isChecked: Bool, calendarItem: EKCalendar) {
        
        if isChecked {
            selectedCalendars.updateValue(calendarItem.calendarIdentifier, forKey: calendarItem.title)
        } else {
            selectedCalendars.removeValue(forKey: calendarItem.title)
        }
        
        defaultsManager.setAny(selectedCalendars, forKey: defaultsManager.keys.SELECTED_CALENDARS)
        delegate?.calendarSettingsChanged()
    }
}

protocol CalendarTabViewItemDelegate: class {
    func calendarSettingsChanged()
}
