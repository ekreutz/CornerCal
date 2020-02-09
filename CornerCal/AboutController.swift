//
//  AboutController.swift
//  CornerCal
//
//  Created by Alexey Boldakov on 09.02.2020.
//  Copyright © 2020 Alex Boldakov. All rights reserved.
//

import Cocoa

class AboutController: NSObject, NSWindowDelegate {
    
    @IBAction func emailClicked(_ sender: NSButton) {
        let service = NSSharingService(named: NSSharingService.Name.composeEmail)
        service?.recipients = [sender.title]
        service?.subject = "CornerCal feedback"
        service?.perform(withItems: [""])
    }
    
    @IBAction func donateClicked(_ sender: NSButton) {
        openUrl(link: sender.title)
    }
    
    @IBAction func projectClicked(_ sender: NSButton) {
        openUrl(link: sender.title)
    }
    
    override init() {
        super.init()
    }
    
    private func openUrl(link: String) {
        let url = URL(string: link)!
        if NSWorkspace.shared.open(url) {
            print("default browser was successfully opened")
        }
    }
}
