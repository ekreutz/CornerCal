//
//  MainMenuController.swift
//  CornerCal
//
//  Created by Emil Kreutzman on 23/09/2017.
//  Copyright © 2017 Emil Kreutzman. All rights reserved.
//

import Cocoa

class MainMenuController: NSObject, NSCollectionViewDataSource {
    
    let controller = CalendarController()
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return controller.itemCount()
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let id = NSUserInterfaceItemIdentifier.init(rawValue: "CalendarDayItem")
        
        let item = collectionView.makeItem(withIdentifier: id, for: indexPath)
        guard let calendarItem = item as? CalendarDayItem else {
            return item
        }
        
        calendarItem.setBold(bold: false)
        calendarItem.setText(text: controller.getItemAt(index: indexPath.item))
        calendarItem.setPartlyTransparent(partlyTransparent: false)
        calendarItem.setHasRedBackground(hasRedBackground: false)
        
        return calendarItem
    }
    
    func setStatusMenuLabelToTime() {
        statusItem.title = controller.getFormattedDate()
    }
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    @IBOutlet weak var monthLabel: NSTextField!
    
    @IBOutlet weak var collectionView: NSCollectionView!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    override func awakeFromNib() {
        statusItem.menu = statusMenu
        setStatusMenuLabelToTime()
    }
    
    @IBAction func leftClicked(_ sender: NSButton) {
        controller.decrementMonth()
    }
    
    @IBAction func rightClicked(_ sender: NSButton) {
        controller.incrementMonth()
    }
    
    @IBAction func clearMonthHopping(_ sender: NSButton) {
        controller.resetMonth()
    }

}
