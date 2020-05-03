//
//  SettingsController.swift
//  CornerCal
//
//  Created by Alex Boldakov on 21/10/2017.
//  Copyright © 2020 Alex Boldakov. All rights reserved.
//

import Cocoa
import EventKit
import ServiceManagement


class SettingsController: NSWindowController, NSWindowDelegate {
    
    private var currentSelectedTabIndex = 0
    
    @IBOutlet weak var tabView: NSTabView! {
        didSet {
            tabView.delegate = self
        }
    }
    
    @IBOutlet weak var calendarController: CalendarController! {
        didSet {
            calendarController.refreshEventsState()
        }
    }

    @IBOutlet weak var generalTab: GeneralTabViewItem! {
        didSet {
            generalTab.delegate = self
        }
    }
    
    @IBOutlet weak var calendarTab: CalendarTabViewItem! {
        didSet {
            calendarTab.delegate = self
        }
    }
    
    @IBOutlet weak var updatesTab: UpdatesTabViewItem! {
        didSet {
            updatesTab.stastCheckIfNeed()
        }
    }
    
    @IBOutlet weak var aboutTab: NSTabViewItem!
    
    func activateGeneralTab() {
        currentSelectedTabIndex = 0
        
        if tabView != nil {
            tabView.selectTabViewItem(at: currentSelectedTabIndex)
            currentSelectedTabIndex = 0
        }
    }
    
    func activateUpdatesTab() {
        currentSelectedTabIndex = 2
        
        if tabView != nil {
            tabView.selectTabViewItem(at: currentSelectedTabIndex)
            currentSelectedTabIndex = 0
            updatesTab.startCheckForce()
        }
    }
    
    func activateAboutTab() {
        currentSelectedTabIndex = 3
        
        if tabView != nil {
            tabView.selectTabViewItem(at: currentSelectedTabIndex)
            currentSelectedTabIndex = 0
        }
    }
}

extension SettingsController: NSTabViewDelegate {
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        if let identifier = tabViewItem?.identifier as? String, let currentTab = SettingsTabs(rawValue: identifier) {
            switch currentTab {
            case SettingsTabs.general:
                generalTab.initState()
            case SettingsTabs.calendar:
                calendarTab.initState()
            default:
                break
            }
        }
    }
}

extension SettingsController: TimeTabViewItemDelegate {
    
    func dateFormatChanged() {
        //calendarController.setMenuBarButton()
        calendarController.setDateFormat()
    }
    
    func menuBarStyleChanged() {
        calendarController.setDateFormat()
    }
}

extension SettingsController: CalendarTabViewItemDelegate {
    func calendarSettingsChanged() {
        calendarController.refreshEventsState()
    }
}

enum SettingsTabs: String {
    case general
    case calendar
    case updates
    case about
}
