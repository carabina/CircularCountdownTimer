//
//  AppDelegate.swift
//  CountdownTimerView Mac
//
//  Created by Paul on 30/07/2016.
//  Copyright © 2016 Paul Sneddon. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // Setup the global timer which will send notications every second, minute, and hour
    var globalTimer = GlobalTimer()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

