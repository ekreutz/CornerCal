//
//  AboutController.swift
//  CornerCal
//
//  Created by Alex Boldakov on 09.02.2020.
//  Copyright © 2020 Alex Boldakov. All rights reserved.
//

import Cocoa

class AboutController: NSObject, NSWindowDelegate {
    
    @IBAction func projectClicked(_ sender: NSButton) {
        openUrl(link: sender.title)
    }
    
    @IBOutlet weak var versionLabel: NSTextField! {
        didSet {
            versionLabel.stringValue = version()
        }
    }
    
    override init() {
        super.init()
        //self.versionLabel.stringValue = version()
    }
    
    private func openUrl(link: String) {
        let url = URL(string: link)!
        if NSWorkspace.shared.open(url) {
            print("default browser was successfully opened")
        }
    }
    
    func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version)(\(build))"
    }
}
