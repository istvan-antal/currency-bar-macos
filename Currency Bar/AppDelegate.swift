//
//  AppDelegate.swift
//  Currency Bar
//
//  Created by Antal István on 24/02/2017.
//  Copyright © 2017 Antal István. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {

    let statusItem = NSStatusBar.system().statusItem(withLength: -2)
    let menu = NSMenu()
    let lastUpdateIndicator = NSMenuItem()
    var mainWindow: NSWindow?
    
    override init() {
        super.init()
        menu.delegate = self
        
        statusItem.title = "..."
        lastUpdateIndicator.title = "Updated: never"
        
        menu.addItem(lastUpdateIndicator)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Open Chart", action: #selector(openRatesPage(sender:)), keyEquivalent: "o"))
        menu.addItem(NSMenuItem(title: "Settings", action: #selector(openSettings(sender:)), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(exitNow(sender:)), keyEquivalent: "q"))
        
        statusItem.menu = self.menu
    }
    
    public func menuWillOpen(_ menu: NSMenu) {
        lastUpdateIndicator.title = String(describing: Int(floor(-(DataFetcher.shared.lastUpdatedTime?.timeIntervalSinceNow)!))) + " seconds ago"
    }
    
    @IBAction func openSettings(sender: AnyObject) {
        if (mainWindow == nil) {
            mainWindow = NSApplication.shared().mainWindow
        }
        mainWindow!.setIsVisible(true)
    }

    @IBAction func openRatesPage(sender: AnyObject) {
        NSWorkspace.shared().open(URL(string: DataFetcher.shared.detailsUrl)!)
    }
    
    @IBAction func exitNow(sender: AnyObject) {
        NSApplication.shared().terminate(self)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApplication.shared().setActivationPolicy(NSApplicationActivationPolicy.accessory)
        
        
        DataFetcher.shared.onUpdate = { (rate) -> () in
            self.statusItem.title = rate
        }
    }

}

