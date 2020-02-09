//
//  SettingsController.swift
//  CornerCal
//
//  Created by Emil Kreutzman on 21/10/2017.
//  Copyright © 2017 Emil Kreutzman. All rights reserved.
//

import Cocoa

struct SettingsKeys {
    let SHOW_SECONDS_KEY = "TIME_WITH_SECONDS"
    let USE_HOURS_24_KEY = "USE_24_H"
    let SHOW_AM_PM_KEY = "AM_PM"
    let SHOW_DATE_KEY = "SHOW_DATE"
    let SHOW_DAY_OF_WEEK_KEY = "DAY_OF_WEEK"
}

class SettingsController: NSObject, NSWindowDelegate {
    
    let defaults: UserDefaults!
    let keysToViewMap: [String]!
    let keys = SettingsKeys()
    
    @IBOutlet weak var calendarController: CalendarController!
    
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
    }
    
    func updateAMPMEnabled() {
        showAMPMBox.isEnabled = use24HoursBox.state == .off
    }
    
    @IBOutlet weak var showSecondsBox: NSButton!
    
    @IBOutlet weak var use24HoursBox: NSButton!
    
    @IBOutlet weak var showAMPMBox: NSButton!
    
    @IBOutlet weak var showDateBox: NSButton!
    
    @IBOutlet weak var showDayOfWeekBox: NSButton!
    
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
}
