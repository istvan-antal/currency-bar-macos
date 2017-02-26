//
//  AppDelegate.swift
//  Currency Bar
//
//  Created by Antal István on 24/02/2017.
//  Copyright © 2017 Antal István. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system().statusItem(withLength: -2)
    var timer: DispatchSourceTimer?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        NSApplication.shared().setActivationPolicy(NSApplicationActivationPolicy.accessory)
        statusItem.title = "..."
        let menu = NSMenu()
        let lastUpdateIndicator = NSMenuItem()
        lastUpdateIndicator.title = "Updated: never"
        menu.addItem(lastUpdateIndicator)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Open Chart", action: #selector(openRatesPage(sender:)), keyEquivalent: "P"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(exitNow(sender:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
        
        let queue = DispatchQueue(label: "xyz.istvan.timer")  // you can also use `DispatchQueue.main`, if you want
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer!.scheduleRepeating(deadline: .now(), interval: .seconds(60))
        timer!.setEventHandler { [weak self] in
            var request = URLRequest(url: URL(string: "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20csv%20where%20url%3D%22http%3A%2F%2Ffinance.yahoo.com%2Fd%2Fquotes.csv%3Fe%3D.csv%26f%3Dnl1d1t1%26s%3Dgbphuf%3DX%22%3B&format=json&callback=")!)
            request.httpMethod = "POST"
            let session = URLSession.shared
            
            session.dataTask(with: request) {data, response, err in
                do {
                    guard let result = try JSONSerialization.jsonObject(with: data!) as? [String: [String: Any]] else {
                        print("error trying to convert data to JSON")
                        return
                    }
                    let results = result["query"]?["results"] as! [String: [String: Any]]
                    let rate = String(describing: results["row"]!["col1"]!)
                    self?.statusItem.title = rate
                    lastUpdateIndicator.title = "Updated: " + Date().description
                    print("Update complete")
                } catch {
                    print("error trying to convert data to JSON")
                    return
                }
                }.resume()
        }
        timer!.resume()
    }
    
    @IBAction func openRatesPage(sender: AnyObject) {
        NSWorkspace.shared().open(URL(string: "https://uk.finance.yahoo.com/quote/GBPHUF=X?p=GBPHUF=X")!)
    }
    
    @IBAction func exitNow(sender: AnyObject) {
        NSApplication.shared().terminate(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        timer?.cancel()
        timer = nil
    }


}

