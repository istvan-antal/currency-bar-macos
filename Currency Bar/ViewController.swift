//
//  ViewController.swift
//  Currency Bar
//
//  Created by Antal István on 24/02/2017.
//  Copyright © 2017 Antal István. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSWindowDelegate, NSTextFieldDelegate {
    
    @IBOutlet weak var currencyPairField: NSTextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear() {
        self.view.window?.delegate = self
        currencyPairField.delegate = self
        currencyPairField.stringValue = DataFetcher.shared.selectedCurrencyPair
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        DataFetcher.shared.selectedCurrencyPair = currencyPairField.stringValue
    }
    
    func windowShouldClose(_ sender: Any) -> Bool {
        self.view.window?.setIsVisible(false)
        return false
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    

}

