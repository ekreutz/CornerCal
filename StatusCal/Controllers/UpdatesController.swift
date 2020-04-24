//
//  UpdatesController.swift
//  StatusCal
//
//  Created by Alexey Boldakov on 23.04.2020.
//  Copyright © 2020 Alex Boldakov. All rights reserved.
//

import Cocoa


class UpdatesController: NSWindowController, NSWindowDelegate {
    
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
    @IBOutlet weak var loadButton: NSButton!
    
    @IBOutlet weak var ckeckStatusMessage: NSTextField!
    
    let locale = NSLocale.autoupdatingCurrent
    
    @IBAction func loadClicked(_ sender: NSButton) {
        openUrl(link: Constants.lastVersionDownloadURL)
    }
    
    private var state: UpdateState = .startCheck {
        didSet {
            updateViewByState()
        }
    }
    
    override init(window: NSWindow?) {
        super.init(window: window)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func windowDidBecomeMain(_ notification: Notification) {
        self.state = .startCheck
        checkForUpdates()
    }
    
    private func checkForUpdates() {
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
//            self.ckeckStatusMessage.stringValue = NSLocalizedString("updates.checking.message", comment: "")
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
