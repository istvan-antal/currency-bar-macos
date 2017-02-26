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
    var timer: DispatchSourceTimer?
    var lastUpdatedTime: Date?
    let menu = NSMenu()
    let lastUpdateIndicator = NSMenuItem()
    let currencyPair = "gbphuf"
    let detailsUrl: String
    let dataUrl: String
    let request: URLRequest
    
    override init() {
        dataUrl = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20csv%20where%20url%3D%22http%3A%2F%2Ffinance.yahoo.com%2Fd%2Fquotes.csv%3Fe%3D.csv%26f%3Dnl1d1t1%26s%3D\(currencyPair)%3DX%22%3B&format=json&callback="
        detailsUrl = String(format: "https://uk.finance.yahoo.com/quote/%@=X?p=%@=X", currencyPair, currencyPair)
        request = URLRequest(url: URL(string: dataUrl)!)
        
        super.init()
        
        menu.delegate = self
        
        statusItem.title = "..."
        lastUpdateIndicator.title = "Updated: never"
        
        menu.addItem(lastUpdateIndicator)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Open Chart", action: #selector(openRatesPage(sender:)), keyEquivalent: "P"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(exitNow(sender:)), keyEquivalent: "q"))
        
        statusItem.menu = self.menu
    }
    
    public func menuWillOpen(_ menu: NSMenu) {
        lastUpdateIndicator.title = String(describing: Int(floor(-(lastUpdatedTime?.timeIntervalSinceNow)!))) + " seconds ago"
    }
    
    @IBAction func openRatesPage(sender: AnyObject) {
        NSWorkspace.shared().open(URL(string: detailsUrl)!)
    }
    
    @IBAction func exitNow(sender: AnyObject) {
        NSApplication.shared().terminate(self)
    }
    
    func performUpdate() {
        URLSession.shared.dataTask(with: request) {data, response, err in
            do {
                guard let result = try JSONSerialization.jsonObject(with: data!) as? [String: [String: Any]] else {
                    print("error trying to convert data to JSON")
                    return
                }
                let results = result["query"]?["results"] as! [String: [String: Any]]
                let rate = String(describing: results["row"]!["col1"]!)
                self.statusItem.title = rate
                self.lastUpdatedTime = Date()
                self.lastUpdateIndicator.title = "Updated: " + (self.lastUpdatedTime?.description)!
                print("Update complete")
            } catch {
                print("error trying to convert data to JSON")
                return
            }
        }.resume()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        NSApplication.shared().setActivationPolicy(NSApplicationActivationPolicy.accessory)
        
        let queue = DispatchQueue(label: "xyz.istvan.timer")  // you can also use `DispatchQueue.main`, if you want
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer!.scheduleRepeating(deadline: .now(), interval: .seconds(60))
        timer!.setEventHandler(handler: self.performUpdate)
        timer!.resume()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        timer?.cancel()
        timer = nil
    }


}

