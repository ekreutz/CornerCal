//
//  AppDelegate.swift
//  CornerCal
//
//  Created by Alex Boldakov on 23/09/2017.
//  Copyright © 2020 Alex Boldakov. All rights reserved.
//

import Cocoa
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private let defaultsManager = DefaultsManager.shared
    @IBOutlet weak var appController: MainMenuController!
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        defaultsManager.trySetDefaults()
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
    
    private func initLaunchAtLogin() {
        let isFirstLaunch = defaultsManager.getBool(forKey: defaultsManager.keys.IS_FIRST_LAUNCH)
        
        if isFirstLaunch {
            SMLoginItemSetEnabled(Constants.launcherAppId as CFString, true)
            defaultsManager.setBool(true, forKey: defaultsManager.keys.START_AT_LOGIN)
            defaultsManager.setBool(false, forKey: defaultsManager.keys.IS_FIRST_LAUNCH)
        }
    }
}

