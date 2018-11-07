//
//  NotificationsSettingsTableViewController.swift
//  Cloud Control
//
//  Created by Clément Gonzalvez on 07/09/2018.
//  Copyright © 2018 Clément. All rights reserved.
//

import UIKit

class NotificationsSettingsTableViewController: UITableViewController {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var notificationsSwitch: UISwitch!
    
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationsSwitch.isOn = defaults.bool(forKey: "notificationsSetting")
        
        timerLabel.text = formatTimer(timer: TimeInterval(defaults.double(forKey: "timerInterval")))

        datePicker.isHidden = true
        
        
    }
    
    @IBAction func dateChanged(_ sender: Any) {
        
        print("Value Changed!")
        
        defaults.set(Double(datePicker.countDownDuration), forKey: "timerInterval")
        
        timerLabel.text = formatTimer(timer: datePicker.countDownDuration)
        
        
    }
    
    @IBAction func notificationsToggle(_ sender: Any) {
        
        if notificationsSwitch.isOn == true {
            defaults.set(true, forKey: "notificationsSetting")
            print(defaults.bool(forKey: "notificationsSetting"))
        } else if notificationsSwitch.isOn == false {
            defaults.set(false, forKey: "notificationsSetting")
            print(defaults.bool(forKey: "notificationsSetting"))
            datePicker.isHidden = true
        }
        
        UIView.transition(with: tableView, duration: 0.35, options: .transitionCrossDissolve, animations: { () -> Void in
            self.tableView.reloadData()
            }, completion: nil);
        
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 1 && indexPath.row == 1 {
            let height: CGFloat = datePicker.isHidden ? 0.0 : 216.0
            return height
        }
        
        return tableView.rowHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let timerIndexPath = IndexPath(row: 0, section: 1)
        
        if timerIndexPath == indexPath {
            
            datePicker.isHidden.toggle()
            
            if datePicker.isHidden == false {
                DispatchQueue.main.async {
                    self.datePicker.countDownDuration = TimeInterval(self.defaults.double(forKey: "timerInterval"))
                }
                timerLabel.textColor = UIColor(red:0.04, green:0.26, blue:0.87, alpha:1.0)
            } else {
                timerLabel.textColor = UIColor.black
            }
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                
                self.tableView.beginUpdates()
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.datePicker.alpha = 1
                self.tableView.endUpdates()
                
            })
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if notificationsSwitch.isOn && section == 0 {
            return 0
        }
            return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        if notificationsSwitch.isOn && section == 0 {
            return ""
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
