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

}

