//
//  ViewController.swift
//  CountdownTimerView Mac
//
//  Created by Paul on 30/07/2016.
//  Copyright © 2016 Paul Sneddon. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var countdownTimerView: CountdownTimerView!
    @IBOutlet weak var randomColorButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        countdownTimerView.progressColor = NSColor.blue

    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

