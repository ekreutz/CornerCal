//
//  AppDelegate.swift
//  CornerCal
//
//  Created by Emil Kreutzman on 23/09/2017.
//  Copyright © 2017 Emil Kreutzman. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var appController: MainMenuController!
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        let keys = SettingsKeys()
        
        // Set some defaults values for this app's settings
        trySetDefaultValueFor(key: keys.SHOW_SECONDS_KEY, value: false)
        trySetDefaultValueFor(key: keys.SHOW_DATE_KEY, value: true)
        trySetDefaultValueFor(key: keys.SHOW_DAY_OF_WEEK_KEY, value: true)
        trySetDefaultValueFor(key: keys.USE_HOURS_24_KEY, value: true)
        trySetDefaultValueFor(key: keys.SHOW_AM_PM_KEY, value: true)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        appController.refreshState()
    }
    
    func applicationDidChangeOcclusionState(_ notification: Notification) {
        if (NSApp.occlusionState.contains(.visible)) {
            // the app now became visible
            appController.refreshState()
        } else {
            // none of the app is visible anymore, so pause everything
            appController.deactivate()
        }
    }
    
    private func defaultsContains(key: String) -> Bool {
        return UserDefaults.standard.value(forKey: key) != nil
    }
    
    private func trySetDefaultValueFor(key: String, value: Bool) {
        if (!defaultsContains(key: key)) {
            print(String(format: "setting default \"%@\"", key))
            UserDefaults.standard.set(value, forKey: key)
        }
    }

}

