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
    
    @IBOutlet weak var monthLabel: NSButton!
    
    @IBOutlet weak var buttonLeft: NSButton!
    
    @IBOutlet weak var buttonRight: NSButton!
    
    @IBOutlet weak var collectionView: NSCollectionView!
    
    @IBOutlet weak var settingsWindow: NSWindow!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    private func updateMenuTime() {
        statusItem.title = controller.getFormattedDate()
    }
    
    private func updateCalendar() {
        monthLabel.title = controller.getMonth()
        applyUIModifications()
        collectionView.reloadData()
    }
    
    private func getBasicAttributes(button: NSButton, color: NSColor, alpha: CGFloat) -> [NSAttributedStringKey : Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        return [
            NSAttributedStringKey.foregroundColor: color.withAlphaComponent(alpha),
            NSAttributedStringKey.font: NSFont.systemFont(ofSize: (button.font?.pointSize)!, weight: NSFont.Weight.light),
            NSAttributedStringKey.backgroundColor: NSColor.clear,
            NSAttributedStringKey.paragraphStyle: style,
            NSAttributedStringKey.kern: 0.5 // some additional character spacing
        ]
    }
    
    private func applyButtonHighlightSettings(button: NSButton, isAccented: Bool) {
        let color = (isAccented) ? NSColor.systemRed : NSColor.black
        
        let defaultAlpha: CGFloat = (isAccented) ? 1.0 : 0.75
        let pressedAlpha: CGFloat = (isAccented) ? 0.70 : 0.45
        
        let defaultAttributes = getBasicAttributes(button: button, color: color, alpha: defaultAlpha)
        let pressedAttributes = getBasicAttributes(button: button, color: color, alpha: pressedAlpha)
        
        button.attributedTitle = NSAttributedString(string: button.title, attributes: defaultAttributes)
        button.attributedAlternateTitle = NSAttributedString(string: button.title, attributes: pressedAttributes)
        button.alignment = .center
    }
    
    private func applyUIModifications() {
        statusItem.button?.font = NSFont.monospacedDigitSystemFont(ofSize: (statusItem.button?.font?.pointSize)!, weight: .regular)
        
        applyButtonHighlightSettings(button: monthLabel, isAccented: true)
        applyButtonHighlightSettings(button: buttonLeft, isAccented: false)
        applyButtonHighlightSettings(button: buttonRight, isAccented: false)
    }
    
    func refreshState() {
        statusItem.menu = statusMenu
        controller.subscribe(onTimeUpdate: updateMenuTime, onCalendarUpdate: updateCalendar)

    }
    
    func deactivate() {
        controller.pause()
    }
    
    @IBAction func openSettingsClicked(_ sender: NSMenuItem) {
        let settingsWindowController = NSWindowController.init(window: settingsWindow)
        settingsWindowController.showWindow(sender)
        
        // bring settings window to front
        NSApp.activate(ignoringOtherApps: true)
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
