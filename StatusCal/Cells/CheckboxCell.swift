//
//  CheckboxCell.swift
//  StatusCal
//
//  Created by Alexey Boldakov on 21.04.2020.
//  Copyright © 2020 Alex Boldakov. All rights reserved.
//

import Cocoa
import EventKit


class CheckboxCell: NSTableCellView {
    
    @IBOutlet weak var chekbox: NSButton!
    
    @IBAction func chekboxClicked(_ sender: NSButton) {
        if let calendar = calendar {
            delegate?.checkboxChecked(isChecked: sender.state == .on, calendarItem: calendar)
        }
    }
    
    var delegate: CheckboxCellViewDelegate? = nil
    var calendar: EKCalendar? = nil
    
}

protocol CheckboxCellViewDelegate {
    func checkboxChecked(isChecked: Bool, calendarItem: EKCalendar)
}
