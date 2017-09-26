//
//  CalendarDayItem.swift
//  CornerCal
//
//  Created by Emil Kreutzman on 24/09/2017.
//  Copyright © 2017 Emil Kreutzman. All rights reserved.
//

import Cocoa

class CalendarDayItem: NSCollectionViewItem {
    
    public func setToday(today: Bool) {
        if (today) {
            view.layer?.cornerRadius = (view.layer?.frame.width)! / 2
            view.layer?.backgroundColor = NSColor.red.cgColor
            textField?.textColor = NSColor.white
        } else {
            view.layer?.cornerRadius = 0
            view.layer?.backgroundColor = CGColor.clear
            textField?.textColor = NSColor.textColor
        }
    }
    
    public func setIsParfOfSelectedMonth(isPart: Bool) {
        view.layer?.opacity = isPart ? 1 : 0.5
    }
    
    public func setBold(bold: Bool) {
        let fontSize = (textField?.font?.pointSize)!
        if bold {
            textField?.font = NSFont.boldSystemFont(ofSize: fontSize)
        } else {
            textField?.font = NSFont.systemFont(ofSize: fontSize)
        }
    }
    
    
    
    public func setDate(date: String) {
        textField?.stringValue = date
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        textField?.alignment = NSTextAlignment.center
    }
    
}
