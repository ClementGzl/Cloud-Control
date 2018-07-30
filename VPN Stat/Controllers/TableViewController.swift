//
//  ViewController.swift
//  VPN Stat
//
//  Created by Clément on 09/07/2018.
//  Copyright © 2018 Clément. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

class TableViewController: UITableViewController {

    let statusURL = secretStatusURL
    let startURL = secretStartURL
    let stopURL = secretStopURL
    let headers: HTTPHeaders = ["x-api-key": secretApiKey]

    override func viewDidLoad() {
        super.viewDidLoad()

        getStatus(url: statusURL)
        SVProgressHUD.show()
        onOff.isEnabled = false
        uptimeLabel.text = ""
    }
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var uptimeLabel: UILabel!
    
    @IBOutlet weak var onOff: UISwitch!
    
    @IBAction func onOffVPN(_ sender: Any) {
        
        if onOff.isOn == true {
        print("ON")
        startInstance(url: startURL)
    } else {
        print("OFF")
        stopInstance(url: stopURL)
        onOff.isOn = false
        }
        
    }
   
    //MARK: - Networking
    
    func getStatus(url : String) {
        
        Alamofire.request(url, method: .get, headers: headers).responseJSON {
            response in
            
            if response.result.isSuccess {
                print("Sucess, got the status")

                let statusJSON = JSON(response.result.value!)
                self.updateStatus(json: statusJSON)
                self.updateUptime(json: statusJSON)
                SVProgressHUD.dismiss()
            }

            else {
                print("Error geting status, \(response.result.error!)")
                SVProgressHUD.dismiss()
                self.statusLabel.text = "Error getting status"
            }
            
        }
        
    }
   
//    @IBOutlet weak var refreshButton: LoadingButton!
    

    @IBAction func refreshStatus(_ sender: Any) {
        SVProgressHUD.show()
        statusLabel.text = "..."
        statusLabel.textColor = UIColor.darkText
        getStatus(url: statusURL)
    }
    
    func startInstance(url : String) {

        Alamofire.request(url, method: .get, headers: headers)
        SVProgressHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Your code with delay
            self.getStatus(url: secretStatusURL)
        }
        
        
    }
    
    func stopInstance(url : String) {
        
        Alamofire.request(url, method: .get, headers: headers)
        SVProgressHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Your code with delay
            self.getStatus(url: secretStatusURL)
        }
        
    }
    
    
    
    //MARK: - JSON Parsing
    
    func updateStatus(json: JSON) {
        
        if let status = json["Reservations"][0]["Instances"][0]["State"]["Name"].string {
            
            print(status)
            
            self.statusLabel.text = status.capitalized
            
            if self.statusLabel.text == "Running" {
                self.statusLabel.textColor = UIColor.green
                self.onOff.isOn = true
                self.onOff.isEnabled = true
            } else if self.statusLabel.text == "Pending" {
                self.statusLabel.textColor = UIColor.orange
                self.onOff.isOn = true
                self.onOff.isEnabled = false
            } else if self.statusLabel.text == "Stopping" {
                self.statusLabel.textColor = UIColor.orange
                self.onOff.isOn = false
                self.onOff.isEnabled = false
            } else {
                self.statusLabel.textColor = UIColor.darkText
                self.onOff.isEnabled = true
                self.uptimeLabel.text = ""
            }
            
            tableView.reloadData()
            
        } else {
            
            print("Error parsing JSON")
            self.statusLabel.text = "Error getting status"
            self.statusLabel.textColor = UIColor.red
        }
        
    }
    
    func updateUptime(json: JSON) {
        
        if let uptime = json["Reservations"][0]["Instances"][0]["LaunchTime"].string {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

            guard let dateFromString = dateFormatter.date(from: uptime) else {return}

            dateFormatter.dateFormat = "dd/MM/yyyy' at 'HH:mm"
            
            self.uptimeLabel.text = "Started: \(dateFormatter.string(from: dateFromString))"
            
            if self.statusLabel.text == "Stopped" {
                self.uptimeLabel.text = ""
            }
            
        } else {
            
            print("Error parsing JSON")
            self.statusLabel.text = "Error getting uptime"
        }
        
    }
    
}
