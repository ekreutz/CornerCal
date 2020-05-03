//
//  UpdatesTabViewItem.swift
//  StatusCal
//
//  Created by Alexey Boldakov on 30.04.2020.
//  Copyright © 2020 Alex Boldakov. All rights reserved.
//

import Cocoa


class UpdatesTabViewItem: NSTabViewItem {
    
    private let locale = NSLocale.autoupdatingCurrent
    private let defaultsManager = DefaultsManager.shared
    private var isChecked = false
    
    @IBOutlet weak var ckeckStatusMessage: NSTextField! {
        didSet {
            
        }
    }
    
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
    @IBOutlet weak var checkUpdatesButton: NSButton!
    
    @IBOutlet weak var loadButton: NSButton!
    
    @IBOutlet weak var checkAutomaticallyCheckbox: NSButton! {
        didSet {
            let isAuto = defaultsManager.getBool(forKey: defaultsManager.keys.CHECK_UPDATES_AUTO)
            checkAutomaticallyCheckbox.state = isAuto ? .on : .off
        }
    }
    
    private var state: UpdateState = .startCheck {
        didSet {
            updateViewByState()
        }
    }
    
    @IBAction func loadClicked(_ sender: NSButton) {
        openUrl(link: Constants.lastVersionDownloadURL)
    }
    
    @IBAction func checkForUpdatesClicked(_ sender: NSButton) {
        checkForUpdates()
    }
    
    @IBAction func checkAutoClicked(_ sender: NSButton) {
        defaultsManager.setBool(sender.state == .on, forKey: defaultsManager.keys.CHECK_UPDATES_AUTO)
    }
    
    func startCheckForce() {
        checkForUpdates()
    }
    
    func stastCheckIfNeed() {
        let isAuto = defaultsManager.getBool(forKey: defaultsManager.keys.CHECK_UPDATES_AUTO)
        if isAuto {
            checkForUpdates()
        }
     }
    
    private func checkForUpdates() {
        state = .startCheck
        
        NetworkManager.shared.checkLastVersion(completion: { (version, error) in
            let dictionary = Bundle.main.infoDictionary!
            let current = dictionary["CFBundleShortVersionString"] as! String
            let currentVersion = Float(current)
            
            if let lastVersion = version?.lastVersion, let currentVersion = currentVersion {
                if currentVersion < lastVersion {
                    self.state = .newVersionAvailable
                } else {
                    self.state = .currentIsLatest
                }
            }
        })
    }
    
    private func updateViewByState() {
        switch state {
            case .startCheck:
                showLoadingState()
            case .newVersionAvailable:
                showNewVersionAvailable()
            case .currentIsLatest:
                showCurrentIsLatest()
        }
    }
    
    private func showLoadingState() {
        DispatchQueue.main.async {
            self.ckeckStatusMessage.stringValue = NSLocalizedString("updates.checking.message", comment: "")
            self.ckeckStatusMessage.stringValue = "updates.checking.message".localized
            self.loadButton.isHidden = true
            self.progressBar.startAnimation(nil)
        }
    }
    
    private func showNewVersionAvailable() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.ckeckStatusMessage.stringValue = "updates.checking.available".localized
            self.loadButton.isHidden = false
            self.progressBar.stopAnimation(nil)
        }
    }
    
    private func showCurrentIsLatest() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.ckeckStatusMessage.stringValue = "updates.checking.newest".localized
            self.loadButton.isHidden = true
            self.progressBar.stopAnimation(nil)
        }
    }
    
    private func openUrl(link: String) {
        let url = URL(string: link)!
        if NSWorkspace.shared.open(url) {
            print("Start download link opened")
        }
    }    
}
