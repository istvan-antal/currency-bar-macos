//
//  DataFetcher.swift
//  Currency Bar
//
//  Created by Antal István on 26/02/2017.
//  Copyright © 2017 Antal István. All rights reserved.
//

import Foundation

class DataFetcher {
    private var request: URLRequest
    private var timer: DispatchSourceTimer?
    private var dataUrl: String
    private var currencyPair: String
    
    static var shared = DataFetcher()
    
    var selectedCurrencyPair: String {
        get {
            return currencyPair
        }
        set(newValue) {
            print("Update currency pair: \(newValue)")
            currencyPair = newValue
            dataUrl = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20csv%20where%20url%3D%22http%3A%2F%2Ffinance.yahoo.com%2Fd%2Fquotes.csv%3Fe%3D.csv%26f%3Dnl1d1t1%26s%3D\(currencyPair)%3DX%22%3B&format=json&callback="
            detailsUrl = String(format: "https://uk.finance.yahoo.com/quote/%@=X?p=%@=X", currencyPair, currencyPair)
            request = URLRequest(url: URL(string: dataUrl)!)
        }
    }
    var detailsUrl: String
    var lastUpdatedTime: Date?
    var onUpdate: (String) -> ()
    
    init() {
        currencyPair = "gbphuf"
        dataUrl = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20csv%20where%20url%3D%22http%3A%2F%2Ffinance.yahoo.com%2Fd%2Fquotes.csv%3Fe%3D.csv%26f%3Dnl1d1t1%26s%3D\(currencyPair)%3DX%22%3B&format=json&callback="
        detailsUrl = String(format: "https://uk.finance.yahoo.com/quote/%@=X?p=%@=X", currencyPair, currencyPair)
        request = URLRequest(url: URL(string: dataUrl)!)

        self.onUpdate = { (_) -> () in }
        
        let queue = DispatchQueue(label: "xyz.istvan.timer")  // you can also use `DispatchQueue.main`, if you want
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer!.scheduleRepeating(deadline: .now(), interval: .seconds(60))
        timer!.setEventHandler(handler: self.performUpdate)
        timer!.resume()
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
                
                self.lastUpdatedTime = Date()
                
                self.onUpdate(rate)
                
                print("Update complete")
            } catch {
                print("error trying to convert data to JSON")
                return
            }
            }.resume()
    }
    
    deinit {
        timer?.cancel()
        timer = nil
    }
}
