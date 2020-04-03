//
//  AppDelegate.swift
//  CornerCalLauncher
//
//  Created by Alexey Boldakov on 08.02.2020.
//  Copyright © 2020 Alex Boldakov. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @objc func terminate() {
        NSApp.terminate(nil)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let mainAppIdentifier = "ru.alexvr.StatusCal"
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == mainAppIdentifier }.isEmpty

        if !isRunning {
            DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.terminate), name: .killLauncher, object: mainAppIdentifier)

            let path = Bundle.main.bundlePath as NSString
            var components = path.pathComponents
            components.removeLast()
            components.removeLast()
            components.removeLast()
            components.append("MacOS")
            components.append("StatusCal")

            let newPath = NSString.path(withComponents: components)

            NSWorkspace.shared.launchApplication(newPath)
        }
        else {
            self.terminate()
        }
    }
}

extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
}



