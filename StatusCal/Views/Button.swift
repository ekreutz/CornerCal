//
//  Button.swift
//  StatusCal
//
//  Created by Alexey Boldakov on 30.04.2020.
//  Copyright © 2020 Alex Boldakov. All rights reserved.
//

import Cocoa

class Button: NSButton {

    @IBInspectable var horizontalPadding : CGFloat = 0
    @IBInspectable var verticalPadding : CGFloat = 0

    override var intrinsicContentSize: NSSize {
        var size = super.intrinsicContentSize
        size.width += self.horizontalPadding
        size.height += self.verticalPadding
        return size;
    }
}
