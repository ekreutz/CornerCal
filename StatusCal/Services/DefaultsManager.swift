//
//  DefaultsManager.swift
//  StatusCal
//
//  Created by Alexey Boldakov on 22.04.2020.
//  Copyright © 2020 Alex Boldakov. All rights reserved.
//

import Foundation

struct SettingsKeys {
    let IS_FIRST_LAUNCH = "IS_FIRST_LAUCH"
    let SHOW_SECONDS_KEY = "TIME_WITH_SECONDS"
    let USE_HOURS_24_KEY = "USE_24_H"
    let SHOW_AM_PM_KEY = "AM_PM"
    let SHOW_DATE_KEY = "SHOW_DATE"
    let SHOW_DAY_OF_WEEK_KEY = "DAY_OF_WEEK"
    let SHOW_EVENTS = "SHOW_EVENTS"
    let SELECTED_CALENDARS = "SELECTED_CALENDARS"
    let START_AT_LOGIN = "START_AT_LOGIN"
}

class DefaultsManager {
    
    static let shared = DefaultsManager()
    
    let keys = SettingsKeys()
    private var defaults: UserDefaults = UserDefaults.standard
    
    init() {
        
    }
    
    func trySetDefaults() {
        trySetDefaultValueFor(key: keys.IS_FIRST_LAUNCH, value: true)
        trySetDefaultValueFor(key: keys.SHOW_SECONDS_KEY, value: false)
        trySetDefaultValueFor(key: keys.SHOW_DATE_KEY, value: true)
        trySetDefaultValueFor(key: keys.SHOW_DAY_OF_WEEK_KEY, value: true)
        trySetDefaultValueFor(key: keys.USE_HOURS_24_KEY, value: true)
        trySetDefaultValueFor(key: keys.SHOW_AM_PM_KEY, value: true)
        trySetDefaultValueFor(key: keys.START_AT_LOGIN, value: true)
    }
    
    private func trySetDefaultValueFor(key: String, value: Bool) {
        if (!defaultsContains(key: key)) {
            defaults.set(value, forKey: key)
        }
    }
    
    private func defaultsContains(key: String) -> Bool {
        return defaults.value(forKey: key) != nil
    }
    
    func getBool(forKey: String) -> Bool {
        return defaults.bool(forKey: forKey)
    }
    
    func setBool(_ value: Bool, forKey: String) {
        defaults.set(value, forKey: forKey)
    }
    
    func getValue(forKey: String) -> Any? {
        return defaults.value(forKey: forKey)
    }
 
    func setAny(_ value: Any, forKey: String) {
        defaults.set(value, forKey: forKey)
    }
}
