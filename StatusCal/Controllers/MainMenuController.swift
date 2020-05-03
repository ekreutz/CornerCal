//
//  MainMenuController.swift
//  CornerCal
//
//  Created by Alex Boldakov on 23/09/2017.
//  Copyright © 2020 Alex Boldakov. All rights reserved.
//

import Cocoa

class MainMenuController: NSObject {
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    @IBOutlet weak var appMenu: NSMenu!
    
    @IBOutlet weak var monthLabel: NSButton!
    
    @IBOutlet weak var buttonLeft: NSButton! 
    
    @IBOutlet weak var buttonRight: NSButton!
    
    @IBOutlet weak var collectionView: NSCollectionView!
    
    @IBOutlet weak var controller: CalendarController!
    
    @IBOutlet weak var settingsController: SettingsController!
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let defaultsManager = DefaultsManager.shared
    
    @IBAction func openSettingsClicked(_ sender: NSMenuItem) {
        settingsController.showWindow(sender)
        NSApp.activate(ignoringOtherApps: true)
        settingsController.activateGeneralTab()
    }
    
    @IBAction func openCalendarClick(_ sender: NSMenuItem) {
        NSWorkspace.shared.launchApplication(String("Calendar"))
    }
    
    @IBAction func aboutClicked(_ sender: NSMenuItem) {
        settingsController.showWindow(sender)
        NSApp.activate(ignoringOtherApps: true)
        settingsController.activateAboutTab()
    }
    
    @IBAction func donateClick(_ sender: NSMenuItem) {
        let url = URL(string: Constants.donateURL)!
        if NSWorkspace.shared.open(url) {
            print("default browser was successfully opened")
        }
    }
    
    @IBAction func checkUpdatesClicked(_ sender: NSMenuItem) {
        settingsController.showWindow(sender)
        NSApp.activate(ignoringOtherApps: true)
        settingsController.activateUpdatesTab()
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApp.terminate(self)
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
    
    private func updateMenuTime() {
        let isShowIcon = defaultsManager.getBool(forKey: defaultsManager.keys.SHOW_ICON)
        let isShowTimeLine = defaultsManager.getBool(forKey: defaultsManager.keys.SHOW_TIME_LINE)
        
        if isShowIcon {
            statusItem.button?.image = NSImage.init(named: "status-icon")
            statusItem.button?.image?.size = NSMakeSize(16.0, 16.0)
            statusItem.button?.imagePosition = isShowTimeLine ? .imageLeft : .imageOnly
        } else {
            statusItem.button?.image = nil
        }
        
        if isShowTimeLine {
            let prefix =  isShowIcon ? " " : ""
            statusItem.button?.title = prefix + controller.getFormattedDate()
        } else {
            statusItem.button?.title = ""
        }
    }
    
    private func updateCalendar() {
        monthLabel.title = controller.getMonth()
        applyUIModifications()
        updateMonthLabelState()
        collectionView.reloadData()
    }
    
    private func getBasicAttributes(button: NSButton, color: NSColor, alpha: CGFloat) -> [NSAttributedString.Key : Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        return [
            NSAttributedString.Key.foregroundColor: color.withAlphaComponent(alpha),
            NSAttributedString.Key.backgroundColor: NSColor.clear,
            NSAttributedString.Key.paragraphStyle: style,
        ]
    }
    
    private func applyButtonHighlightSettings(button: NSButton) {
        let pressedColor = NSColor.gray
        let pressedAlpha: CGFloat = 1
        let pressedAttributes = getBasicAttributes(button: button, color: pressedColor, alpha: pressedAlpha)
        button.attributedAlternateTitle = NSAttributedString(string: button.title, attributes: pressedAttributes)
        button.alignment = .center
    }
    
    private func applyUIModifications() {
        statusItem.button?.font = NSFont.monospacedDigitSystemFont(ofSize: (statusItem.button?.font?.pointSize)!, weight: .regular)
    }
    
    private func updateMonthLabelState() {
        applyButtonHighlightSettings(button: monthLabel)
        applyButtonHighlightSettings(button: buttonLeft)
        applyButtonHighlightSettings(button: buttonRight)
    }
    
    func refreshState() {
        if let button = statusItem.button {
            button.target = self
            button.action = #selector(statusBarButtonClicked(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        controller.subscribe(onTimeUpdate: updateMenuTime, onCalendarUpdate: updateCalendar)
    }
    
    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        let point = NSPoint(x: sender.frame.origin.x, y: sender.frame.origin.y - (sender.frame.height / 4))
        
        if event.type == NSEvent.EventType.leftMouseUp {
            statusMenu.popUp(positioning: nil, at: point, in: sender.superview)
        } else {
            appMenu.popUp(positioning: nil, at: point, in: sender.superview)
        }
    }
    
    func deactivate() {
        controller.pause()
    }
}

extension MainMenuController: NSCollectionViewDataSource, NSCollectionViewDelegate {
    
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
        calendarItem.setHasBackground(hasBackground: day.isToday)
        calendarItem.hasEvents(day.hasEvents)
        
        return calendarItem
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        if let indexPath = indexPaths.first {
            let day = controller.getItemAt(index: indexPath.item)
            if day.hasEvents {
                NSWorkspace.shared.launchApplication(String("Calendar"))
            }
        }
    }
}
