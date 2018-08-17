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

        tableView.register(UINib(nibName: "instanceCell", bundle: nil), forCellReuseIdentifier: "customInstanceCell")
        
        getStatus(url: listURL)

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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instancesArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "instanceCell", for: indexPath) as! InstanceCell
        cell.nameLabel.text = instancesArray[indexPath.row].name
        cell.statusLabel.text = instancesArray[indexPath.row].status
        cell.launchTimeLabel.text = instancesArray[indexPath.row].launchTime

        cell.delegate = self

        return cell
    }

    //MARK: - Networking
    
    @objc func pullRefreshStatus() {
        
        instancesArray = []
        
        self.getStatus(url: listURL)
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
    
    func actionInstance(url: String, instance: Instance, action : String) -> String {
        
        let instance = instance
        print(instance.id)
        let actionParams : Parameters = [
            "region" : instance.region,
            "id" : instance.id,
            "action" : action
        ]
        
        SVProgressHUD.show()
        
        let requestInstance = Alamofire.request(url, method: .patch, parameters: actionParams, encoding: URLEncoding.queryString, headers: headers).responseJSON { (response) in
            if response.result.isSuccess {

                let newStatusJSON = JSON(response.result.value!)
                
                var parameterType = ""
                
                if action == "start" {
                    parameterType = "StartingInstances"
                } else {
                    parameterType = "StoppingInstances"
                }
                
                if let newStatus = newStatusJSON[parameterType][0]["CurrentState"]["Name"].string?.capitalized {
                    instance.status = newStatus
                    print("Success changing action instance \(instance.id)")
                    SVProgressHUD.dismiss()
                    self.tableView.reloadData()
                } else {
                    instance.status = "Error getting status"
                    print("Error updating status from actionInstance")
                    SVProgressHUD.dismiss()
                    self.tableView.reloadData()
                }
                
            }
    
        }
        
        self.refresher.endRefreshing()
        print(requestInstance)
        return instance.status
        
    }
    
    //MARK: - JSON Parsing
    
    func updateInstancesArray(json: JSON) {
        

        for (key,subJson):(String, JSON) in json {
            
            print("There is an object")

            if let id = subJson["InstanceId"].string {
                
                let temporaryInstance = Instance()
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                
                guard let dateFromString = dateFormatter.date(from: subJson["LaunchTime"].stringValue) else {return}
                
                dateFormatter.dateFormat = "dd/MM/yyyy' at 'HH:mm"
                
                var region : String = subJson["Placement"]["AvailabilityZone"].stringValue
                temporaryInstance.id = id
                temporaryInstance.launchTime = "Started: \(dateFormatter.string(from: dateFromString))"
                temporaryInstance.name = id
                region.remove(at: region.index(before: region.endIndex))
                temporaryInstance.region = region
                var statusCode = Int()
                statusCode = subJson["State"]["Code"].intValue
                
                for (_,value) in subJson["Tags"] {

                    if value["Key"] == "Name" {
                        temporaryInstance.name = value["Value"].string!
                    }
                }
                
                temporaryInstance.status = formatStatusCode(code: statusCode)
                
                if temporaryInstance.status != "Terminated" {
                    instancesArray.append(temporaryInstance)
                }
                
                print("Success updating instances array")
                
            } else {
                print("Error updating instances array")
            }
            
        }
            
    }
    
    func formatStatusCode(code: Int) -> String {
        
        var stringStatus = ""
        
        switch code {
        case 0 :
            stringStatus = "Pending"
        case 16 :
            stringStatus = "Running"
        case 32 :
            stringStatus = "Shutting down"
        case 48 :
            stringStatus = "Terminated"
        case 64 :
            stringStatus = "Stopping"
        case 80 :
            stringStatus = "Stopped"
        default:
            stringStatus = "Error getting status"
        }
        
        return stringStatus
        
    }
        
}

extension TableViewController: InstanceCellDelegate {
    
    func switchButton(_ cell: InstanceCell, didSwitchButton: UISwitch) {
        if let indexPath = tableView.indexPath(for: cell) {
        
            if cell.switchButton.isOn == true {
                cell.statusLabel.text = self.actionInstance(url: self.instanceURL, instance: self.instancesArray[indexPath.row], action: "start")
            } else if cell.switchButton.isOn == false {
                cell.statusLabel.text = self.actionInstance(url: self.instanceURL, instance: self.instancesArray[indexPath.row], action: "stop")
            }
        }
    }
}
