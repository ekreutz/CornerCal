//
//  AboutTabViewItem.swift
//  StatusCal
//
//  Created by Alexey Boldakov on 30.04.2020.
//  Copyright © 2020 Alex Boldakov. All rights reserved.
//

import Cocoa


class AboutTabViewItem: NSTabViewItem {
    
    @IBOutlet weak var versionLabel: NSTextField! {
        didSet {
            versionLabel.stringValue = version()
        }
    }
    
    @IBAction func projectClicked(_ sender: NSButton) {
        openUrl(link: Constants.projectPageURL)
    }
    
    @IBAction func termsClicked(_ sender: NSButton) {
        openUrl(link: Constants.projectPageURL)
    }
    
    @IBAction func privacyClicked(_ sender: NSButton) {
        openUrl(link: Constants.projectPageURL)
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
