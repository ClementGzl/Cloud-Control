//
//  Notification.swift
//  Cloud Control
//
//  Created by Clément Gonzalvez on 12/11/2018.
//  Copyright © 2018 Clément. All rights reserved.
//

import Foundation
import UserNotifications

class Notification {
    
    let content = UNMutableNotificationContent()
    
    func createNotification() {
        content.title = "Your instance is still running!"
        content.body = "adada"
        content.badge = 1
    }
    
}
