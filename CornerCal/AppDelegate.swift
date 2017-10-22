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
        
        print("will finish launching")
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to launch your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationDidUpdate(_ notification: Notification) {
        // Make sure that the internal state is up-to-date
        appController.updateState()
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

