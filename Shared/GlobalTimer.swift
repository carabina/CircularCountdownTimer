//
//  GlobalTimer.swift
//  Tokens
//
//  Created by Paul on 15/02/2016.
//  Copyright © 2016 Paul Sneddon. All rights reserved.
//

import Foundation

public class GlobalTimer {
    
    public enum Notifications: String {
        case Second = "com.paulsneddon.global_timer.second_timer"
        case Minute = "com.paulsneddon.global_timer.minute_timer"
        case Hour = "com.paulsneddon.global_timer.hour_timer"
    }
    
    //This prevents others from using the default '()' initializer for this class.
    public init() {
        triggerEachSecond()
        print("*** Initialised Global Timer")
    }

    // Time triggers every second
    private func triggerEachSecond() {
        let date = Date()
        let timeSinceLastSecond = date.timeIntervalSince1970 - floor(date.timeIntervalSince1970)
        let timetoNextSecond = 1.0 - timeSinceLastSecond
        
        // Second
        let delayTime = DispatchTime.now() + Double(Int64(timetoNextSecond * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            // debugPrint("Second timer triggered")
            self.triggerEachSecond()
            NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.Second.rawValue), object: self)
        }
        
        // Minute
        if floor(date.timeIntervalSince1970.truncatingRemainder(dividingBy: 60)) == 0 {
            debugPrint("Minute timer triggered")
            NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.Minute.rawValue), object: self)
        }
        
        // Hour
        if floor(date.timeIntervalSince1970.truncatingRemainder(dividingBy: 60*60)) == 0 {
            debugPrint("Hour timer triggered")
            NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.Hour.rawValue), object: self)
        }
    }

}
