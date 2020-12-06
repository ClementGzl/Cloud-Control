//
//  NotificationsSettingsTableViewController.swift
//  Cloud Control
//
//  Created by Clément Gonzalvez on 07/09/2018.
//  Copyright © 2018 Clément. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationsSettingsTableViewController: UITableViewController {
    let defaults = UserDefaults.standard
    let defaultNotificationsSetting = UserDefaults.standard.bool(forKey: "notificationsSetting")
    var userTimerInterval = TimeInterval(UserDefaults.standard.double(forKey: "timerInterval"))
    
    @IBOutlet weak var notificationsSwitch: UISwitch!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userTimerInterval == 0 {
            defaults.set(Double(300), forKey: "timerInterval")
        }
        
        notificationsSwitch.isOn = defaultNotificationsSetting
        
        DispatchQueue.main.async {
            self.datePicker.countDownDuration = self.userTimerInterval
            self.timerLabel.text = self.formatTimer(timer: self.datePicker.countDownDuration)
        }
    }
    
    @IBAction func dateChanged(_ sender: Any) {
        defaults.set(Double(datePicker.countDownDuration), forKey: "timerInterval")
        timerLabel.text = formatTimer(timer: datePicker.countDownDuration)
    }
    
    @IBAction func notificationsToggle(_ sender: Any) {
        if notificationsSwitch.isOn == true {
            defaults.set(true, forKey: "notificationsSetting")
        } else if notificationsSwitch.isOn == false {
            defaults.set(false, forKey: "notificationsSetting")
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in})
    }
    
    // MARK: - Tableview data source
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if notificationsSwitch.isOn && section == 0 {
            return nil
        } else if notificationsSwitch.isOn == false && section == 0 {
            return "Send a reminder notification that the instance is still running."
        }
        return "Choose the time interval you want to be notified."
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if notificationsSwitch.isOn {
            return 2
        } else {
            return 1
        }
    }
    
    func formatTimer(timer: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [ .hour, .minute ]
        formatter.zeroFormattingBehavior = [ .pad ]
        
        return formatter.string(from: timer)!
    }
}
