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

    var instancesArray = [Instance]()
    
    let instanceURL = secretInstanceURL
    let listURL = secretListURL
    let headers: HTTPHeaders = ["x-api-key": secretApiKey]
    var refresher: UIRefreshControl!
    var id : String = ""
    
    let params = ["regions" : "eu-west-1,eu-west-2,eu-west-3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "InstanceCell", bundle: nil), forCellReuseIdentifier: "customInstanceCell")
        
        getStatus(url: listURL)
        
        var testObject = Test()
        
        testObject.name = "blabla"
        
        print(testObject)

        SVProgressHUD.show()

        refresher = UIRefreshControl()
        refresher.tintColor = .white
        refresher.addTarget(self, action: #selector(TableViewController.pullRefreshStatus), for: UIControlEvents.valueChanged)
        tableView.refreshControl = refresher
        
    }
    
    @IBAction func goToinfo(_ sender: Any) {
        performSegue(withIdentifier: "goToInfo", sender: self)
    }
    
    //MARK: - Tableview Datasource
    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return instancesArray.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "InstanceCell", for: indexPath) as! InstanceCell
//        cell.statusLabel.text = instancesArray[indexPath.row].status
//
//        return cell
//    }
   
    //MARK: - Networking
    
    @objc func pullRefreshStatus() {
//        self.getStatus(url: self.statusURL)
    }
    
    func getInstancesList(url: String) {
        
        Alamofire.request(url, method: .get, headers: headers).responseJSON {
            response in
            
            if response.result.isSuccess {
                
                print("Success, got the instances list")
                
                let instancesListJSON = JSON(response.result.value!)
                
                print(instancesListJSON)
                SVProgressHUD.dismiss()
                
            } else {
                print("Error getting instances list, \(response.result.error!)")
                SVProgressHUD.dismiss()
            }
            
        }
        
    }
    
    @objc func getStatus(url : String) {
        
        Alamofire.request(url, method: .get, parameters: params, headers: headers).responseJSON {
            response in
            
            if response.result.isSuccess {
                print("Sucess, got the status")

                let statusJSON = JSON(response.result.value!)

                self.updateInstancesArray(json:statusJSON)
                self.tableView.reloadData()
                
                SVProgressHUD.dismiss()
                self.refresher.endRefreshing()
            }

            else {
                print("Error getting status, \(response.result.error!)")
                SVProgressHUD.dismiss()
                self.refresher.endRefreshing()

            }
            
        }
        
    }
    
    func startInstance(url : String) {

        Alamofire.request(url, method: .get, headers: headers)
        SVProgressHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Your code with delay
            self.getStatus(url: self.instanceURL)
        }
        
        
    }
    
    func stopInstance(url : String) {
        
        Alamofire.request(url, method: .get, headers: headers)
        SVProgressHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {

            self.getStatus(url: self.instanceURL)
        }
        
    }
    
    
    
    //MARK: - JSON Parsing
    
    func updateInstancesArray(json: JSON) {
        
        var temporaryInstance = Instance()
        
        for (key,subJson):(String, JSON) in json {
            // Do something you want
            print("There is an object")
            if let id = subJson["InstanceId"].string {
                temporaryInstance.id = id
                temporaryInstance.launchTime = subJson["LaunchTime"].stringValue
                temporaryInstance.name = id
                var statusCode = Int()
                statusCode = subJson["State"]["Code"].intValue
                
                switch statusCode {
                case 0 :
                    temporaryInstance.status = "Pending"
                case 16 :
                    temporaryInstance.status = "Running"
                case 32 :
                    temporaryInstance.status = "Shutting down"
                case 48 :
                    temporaryInstance.status = "Terminated"
                case 64 :
                    temporaryInstance.status = "Stopping"
                case 80 :
                    temporaryInstance.status = "Stopped"
                default:
                    temporaryInstance.status = "Error getting status"
                }
                
                instancesArray.append(temporaryInstance)
                
                print("Success updating instances array")
                
            } else {
                print("Error updating instances array")
            }
            
        }
        print(instancesArray)
            
        }
        
    }
    
//    func updateStatus(json: JSON) {
//
//        if let status = json["Reservations"][0]["Instances"][0]["State"]["Name"].string {
//
//            print(status)
//
////            self.statusLabel.text = status.capitalized
////
////            if self.statusLabel.text == "Running" {
////                self.statusLabel.textColor = UIColor.green
////                self.onOff.isOn = true
////                self.onOff.isEnabled = true
////            } else if self.statusLabel.text == "Pending" {
////                self.statusLabel.textColor = UIColor.orange
////                self.onOff.isOn = true
////                self.onOff.isEnabled = false
////            } else if self.statusLabel.text == "Stopping" {
////                self.statusLabel.textColor = UIColor.orange
////                self.onOff.isOn = false
////                self.onOff.isEnabled = false
////            } else {
////                self.statusLabel.textColor = UIColor.darkText
////                self.onOff.isEnabled = true
////                self.uptimeLabel.text = ""
////            }
//
//            tableView.reloadData()
//
//        } else {
//
//            print("Error parsing JSON")
////            self.statusLabel.text = "Error getting status"
////            self.statusLabel.textColor = UIColor.red
//        }
//
//    }
    
//    func updateUptime(json: JSON) {
//
//        if let uptime = json["Reservations"][0]["Instances"][0]["LaunchTime"].string {
//
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
//
//            guard let dateFromString = dateFormatter.date(from: uptime) else {return}
//
//            dateFormatter.dateFormat = "dd/MM/yyyy' at 'HH:mm"
//
////            self.uptimeLabel.text = "Started: \(dateFormatter.string(from: dateFromString))"
////
////            if self.statusLabel.text == "Stopped" {
////                self.uptimeLabel.text = ""
//            }
//
//        } else {
//
//            print("Error parsing JSON")
////            self.statusLabel.text = "Error getting uptime"
//        }
//
//    }

