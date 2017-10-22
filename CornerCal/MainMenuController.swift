//
//  MainMenuController.swift
//  CornerCal
//
//  Created by Emil Kreutzman on 23/09/2017.
//  Copyright © 2017 Emil Kreutzman. All rights reserved.
//

import Cocoa

class MainMenuController: NSObject, NSCollectionViewDataSource {
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return controller.itemCount()
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let id = NSUserInterfaceItemIdentifier.init(rawValue: "CalendarDayItem")
        
        let item = collectionView.makeItem(withIdentifier: id, for: indexPath)
        guard let calendarItem = item as? CalendarDayItem else {
            return item
        }
        
        let day = controller.getItemAt(index: indexPath.item)
        
        calendarItem.setBold(bold: !day.isNumber)
        calendarItem.setText(text: day.text)
        calendarItem.setPartlyTransparent(partlyTransparent: !day.isCurrentMonth)
        calendarItem.setHasRedBackground(hasRedBackground: day.isToday)
        
        return calendarItem
    }
    
    @IBOutlet weak var controller: CalendarController!
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    @IBOutlet weak var monthLabel: NSTextField!
    
    @IBOutlet weak var collectionView: NSCollectionView!
    
    @IBOutlet weak var settingsWindow: NSWindow!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    private func updateMenuTime() {
        statusItem.title = controller.getFormattedDate()
        
        // notice how we're setting the parent length smaller than the actual item length
        // this, combined with a little hack in CalendarController forces the label
        // to be left-aligned in its parent, hence reducing wobble when showing seconds in the clock
        let desiredLength = (statusItem.button?.fittingSize.width)! - 15
        let observedLength = statusItem.length
        if (abs(desiredLength - observedLength) > 10) {
            statusItem.length = desiredLength
        }
    }
    
    private func updateCalendar() {
        monthLabel.stringValue = controller.getMonth()
        collectionView.reloadData()
    }
    
    func updateState() {
        statusItem.menu = statusMenu
        controller.subscribe(onTimeUpdate: updateMenuTime, onCalendarUpdate: updateCalendar)
    }
    
    @IBAction func openSettingsClicked(_ sender: NSMenuItem) {
        let settingsWindowController = NSWindowController.init(window: settingsWindow)
        settingsWindowController.showWindow(sender)
    }
    
    @IBAction func leftClicked(_ sender: NSButton) {
        controller.decrementMonth()
    }
    
    @IBAction func rightClicked(_ sender: NSButton) {
        controller.incrementMonth()
    }
    
    @IBAction func clearMonthHopping(_ sender: Any) {
        controller.resetMonth()
    }

}
