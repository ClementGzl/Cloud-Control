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

class ViewController: UIViewController {

    let statusURL = secretStatusURL
    let startURL = secretStartURL
    let stopURL = secretStopURL
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getStatus(url: statusURL)
        refreshButton.showLoading()
        onOff.isEnabled = false
    }
    
    @IBOutlet var statusLabel: UILabel!
    
    @IBOutlet weak var onOff: UISwitch!
    
    @IBAction func onOffVPN(_ sender: Any) {
        
        if onOff.isOn == true {
            print("ON")
            startInstance(url: startURL)
        } else {
            print("OFF")
            stopInstance(url: stopURL)
        }
        
    }
    //MARK: - Networking
    
    func getStatus(url : String) {
        
        Alamofire.request(url, method: .get).responseJSON {
            response in
            
            if response.result.isSuccess {
                print("Sucess, got the status")

                let statusJSON = JSON(response.result.value!)
                self.updateStatus(json: statusJSON)
                self.refreshButton.hideLoading()
                self.onOff.isEnabled = true
            }

            else {
                print("Error geting status, \(response.result.error!)")
                self.refreshButton.hideLoading()
                self.statusLabel.text = "Error getting status"
                self.onOff.isEnabled = false
            }
            
        }
        
    }
   
    @IBOutlet weak var refreshButton: LoadingButton!
    

    @IBAction func refreshStatus(_ sender: Any) {
        refreshButton.showLoading()
        statusLabel.text = "..."
        getStatus(url: statusURL)
    }
    
    func startInstance(url : String) {
        
        Alamofire.request(url, method: .get)
        getStatus(url: secretStatusURL)
        
    }
    
    func stopInstance(url : String) {
        
        Alamofire.request(url, method: .get)
        getStatus(url: secretStatusURL)
        
    }
    
    
    
    //MARK: - JSON Parsing
    
    func updateStatus(json: JSON) {
        
        if let status = json["InstanceStatuses"][0]["InstanceState"]["Name"].string {
            
            print(status)
            
            self.statusLabel.text = status
            
            
        } else {

            print("Error parsing JSON")
            self.statusLabel.text = "Error getting status"
        }
        
    }
}

