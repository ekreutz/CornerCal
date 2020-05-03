//
//  CalendarDayItem.swift
//  CornerCal
//
//  Created by Alex Boldakov on 24/09/2017.
//  Copyright © 2020 Alex Boldakov. All rights reserved.
//

import Cocoa

class CalendarDayItem: NSCollectionViewItem {
    
    public func setHasBackground(hasBackground: Bool) {
        if (hasBackground) {
            view.layer?.cornerRadius = (view.layer?.frame.width)! / 2
            
            if #available(OSX 10.14, *) {
                view.layer?.backgroundColor = NSColor.controlAccentColor.cgColor
            } else {
                view.layer?.backgroundColor = NSColor.controlColor.cgColor
            }
            textField?.textColor = NSColor.white
        } else {
            view.layer?.cornerRadius = 0
            view.layer?.backgroundColor = CGColor.clear
            textField?.textColor = NSColor.textColor
        }
    }
    
    public func setPartlyTransparent(partlyTransparent: Bool) {
        view.layer?.opacity = partlyTransparent ? 0.5 : 1.0
    }
    
    public func setBold(bold: Bool) {
        let fontSize = (textField?.font?.pointSize)!
        if bold {
            textField?.font = NSFont.boldSystemFont(ofSize: fontSize)
        } else {
            textField?.font = NSFont.systemFont(ofSize: fontSize)
        }
    }
    
    public func setText(text: String) {
        textField?.stringValue = text
    }
    
    public func hasEvents(_ has: Bool) {
        imageView?.isHidden = !has
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        textField?.alignment = NSTextAlignment.center
    }
}
