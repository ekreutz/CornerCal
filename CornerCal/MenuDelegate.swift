//
//  MenuDelegate.swift
//  CornerCal
//
//  Created by Emil Kreutzman on 26/09/2017.
//  Copyright © 2017 Emil Kreutzman. All rights reserved.
//

import Cocoa

class MenuDelegate: NSObject, NSMenuDelegate {
    
    public func menuWillOpen(_ menu: NSMenu) {
        print("Menu will open")
    }
    
    public func menuDidClose(_ menu: NSMenu) {
        print("Menu did close")
    }

}
