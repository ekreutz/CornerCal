//
//  TimeTabViewItem.swift
//  StatusCal
//
//  Created by Alexey Boldakov on 30.04.2020.
//  Copyright © 2020 Alex Boldakov. All rights reserved.
//

import Cocoa
import ServiceManagement


class GeneralTabViewItem: NSTabViewItem {
    
    private let defaultsManager = DefaultsManager.shared
    private let keysToViewMap: [String]!
    
    weak var delegate: TimeTabViewItemDelegate? = nil
    
    @IBOutlet weak var startAtLoginBox: NSButton! {
        didSet {
            let isLaunchAtLoginEnabled = defaultsManager.getBool(forKey: defaultsManager.keys.START_AT_LOGIN)
            startAtLoginBox.state = isLaunchAtLoginEnabled ? .on : .off
        }
    }
    
    @IBOutlet weak var styleSelectorButton: NSPopUpButton! {
        didSet {
            let isShowIcon = defaultsManager.getBool(forKey: defaultsManager.keys.SHOW_ICON)
            let isShowTimeLine = defaultsManager.getBool(forKey: defaultsManager.keys.SHOW_TIME_LINE)
            
            if isShowIcon && isShowTimeLine {
                styleSelectorButton.selectItem(at: 0)
            } else if isShowIcon {
                styleSelectorButton.selectItem(at: 1)
            } else {
                styleSelectorButton.selectItem(at: 2)
            }
        }
    }
    
    @IBOutlet weak var showSecondsBox: NSButton!
    
    @IBOutlet weak var use24HoursBox: NSButton!
    
    @IBOutlet weak var showAMPMBox: NSButton!
    
    @IBOutlet weak var showDateBox: NSButton!
    
    @IBOutlet weak var showDayOfWeekBox: NSButton!
    
    @IBAction func loginLaunchClicked(_ sender: NSButton) {
        let isAuto = sender.state == .on
        defaultsManager.setBool(isAuto, forKey: defaultsManager.keys.START_AT_LOGIN)
        SMLoginItemSetEnabled(Constants.launcherAppId as CFString, isAuto)
    }
    
    @IBAction func styleChecked(_ sender: NSPopUpButton) {
        switch sender.indexOfSelectedItem {
        case 0:
            enableTimeCheckboxes(true)
            defaultsManager.setBool(true, forKey: defaultsManager.keys.SHOW_ICON)
            defaultsManager.setBool(true, forKey: defaultsManager.keys.SHOW_TIME_LINE)
        case 1:
            enableTimeCheckboxes(false)
            defaultsManager.setBool(true, forKey: defaultsManager.keys.SHOW_ICON)
            defaultsManager.setBool(false, forKey: defaultsManager.keys.SHOW_TIME_LINE)
        default:
            defaultsManager.setBool(false, forKey: defaultsManager.keys.SHOW_ICON)
            defaultsManager.setBool(true, forKey: defaultsManager.keys.SHOW_TIME_LINE)
            enableTimeCheckboxes(true)
        }
        
        delegate?.menuBarStyleChanged()
    }
    
    @IBAction func checkBoxClicked(_ sender: NSButton) {
        if (sender.tag > 0 && sender.tag <= keysToViewMap.count) {
            let key = keysToViewMap[sender.tag - 1]
            defaultsManager.setBool(sender.state == .on, forKey: key)
            updateAMPMEnabled()
            delegate?.dateFormatChanged()
        }
    }
    
    required init?(coder: NSCoder) {
        keysToViewMap = [
            defaultsManager.keys.SHOW_SECONDS_KEY,
            defaultsManager.keys.USE_HOURS_24_KEY,
            defaultsManager.keys.SHOW_AM_PM_KEY,
            defaultsManager.keys.SHOW_DATE_KEY,
            defaultsManager.keys.SHOW_DAY_OF_WEEK_KEY
        ]
        
        super.init(coder: coder)
    }
    
    func initState() {
        let boxList: [NSButton] = [
            showSecondsBox,
            use24HoursBox,
            showAMPMBox,
            showDateBox,
            showDayOfWeekBox
        ]
        
        for (index, box) in boxList.enumerated() {
            box.state = defaultsManager.getBool(forKey: keysToViewMap[index]) ? .on : .off
        }
        
        updateAMPMEnabled()
    }
    
    private func updateAMPMEnabled() {
        showAMPMBox.isEnabled = use24HoursBox.state == .off
    }
    
    private func enableTimeCheckboxes(_ isEnabled: Bool) {
        let boxList: [NSButton] = [
            showSecondsBox,
            use24HoursBox,
            showAMPMBox,
            showDateBox,
            showDayOfWeekBox
        ]
        
        for box in boxList {
            box.isEnabled = isEnabled
        }
    }
}

protocol TimeTabViewItemDelegate: class {
    
    func dateFormatChanged()
    
    func menuBarStyleChanged()
}


