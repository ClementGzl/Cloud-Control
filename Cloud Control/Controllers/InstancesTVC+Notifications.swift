//
//  InstancesTVC+Notifications.swift
//  Cloud Control
//
//  Created by Clément Gonzalvez on 17/08/2019.
//  Copyright © 2019 Clément. All rights reserved.
//

import UIKit
import UserNotifications

extension InstancesTVC: UNUserNotificationCenterDelegate {
    
    func createNotification(instance : Instance) {
        
        let defaults = UserDefaults.standard
        
        let userTimeInterval = TimeInterval(defaults.double(forKey: "timerInterval"))
        
        let content = UNMutableNotificationContent()
        UNUserNotificationCenter.current().delegate = self
        
        content.title = "Your instance \(instance.name) is still running"
        content.body = "You may want to turn it off"
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        content.userInfo = ["region" : instance.region, "id" : instance.id]
        
        let actionStopInstance = UNNotificationAction(identifier: "stopInstance", title: "Stop Instance", options: [.destructive, .authenticationRequired, .foreground])
        let actionSnoozeInstance = UNNotificationAction(identifier: "snoozeInstance", title: "Snooze", options: [])
        
        let reminderCategory = UNNotificationCategory(identifier: "reminderNotification", actions: [actionSnoozeInstance, actionStopInstance], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([reminderCategory])
        
        content.categoryIdentifier = "reminderNotification"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: userTimeInterval, repeats: false)
        
        let request = UNNotificationRequest(identifier: "\(instance.name)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        print("the notification is actually created")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.actionIdentifier {
        case "stopInstance":
            let userInfo = response.notification.request.content.userInfo
            actionInstance(url: self.instanceURL, region: userInfo["region"] as! String, id: userInfo["id"] as! String, action: "stop")
            
        case "snoozeInstance":
            UNUserNotificationCenter.current().add(response.notification.request, withCompletionHandler: nil)
            break
        default:
            print("ERROR")
            break
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([UNNotificationPresentationOptions.alert, UNNotificationPresentationOptions.badge, UNNotificationPresentationOptions.sound])
    }
}

