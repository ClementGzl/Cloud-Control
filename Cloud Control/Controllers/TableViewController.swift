//
//  ViewController.swift
//  Cloud Control
//
//  Created by Clément on 09/07/2018.
//  Copyright © 2018 Clément. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
import UserNotifications

class TableViewController: UITableViewController {

    var instancesArray = [Instance]()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Regions.plist")
    
    let defaults = UserDefaults.standard
    
    let instanceURL = secretInstanceURL
    let listURL = secretListURL
    let headers: HTTPHeaders = ["x-api-key": secretApiKey]
    var refresher: UIRefreshControl!
    var id : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.applicationIconBadgeNumber = 0

        tableView.register(UINib(nibName: "instanceCell", bundle: nil), forCellReuseIdentifier: "customInstanceCell")
        loadRegions()

        SVProgressHUD.setDefaultMaskType(.clear)
        
        refresher = UIRefreshControl()
        refresher.tintColor = .white
        refresher.addTarget(self, action: #selector(TableViewController.pullRefreshStatus), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refresher
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        showSVProgressHUD()
        loadRegions()
        getStatus(url: listURL)

    }
    
    @IBAction func goToinfo(_ sender: Any) {
        performSegue(withIdentifier: "goToInfo", sender: self)
    }
    
    //MARK: - Tableview data source
    
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
        
        let selectedRegions = regionsArray.filter { $0.isSelected == true }.map {$0.region}.joined(separator: ",")

        let params = ["regions" : selectedRegions]
        
        print("I am here")
        
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
    
    func actionInstance(url: String, region: String, id: String, action : String) {

        let actionParams : Parameters = [
            "region" : region,
            "id" : id,
            "action" : action
        ]

        SVProgressHUD.show()
        
        Alamofire.request(url, method: .patch, parameters: actionParams, encoding: URLEncoding.queryString, headers: headers).responseJSON { (response) in
            if response.result.isSuccess {

                let newStatusJSON = JSON(response.result.value!)
                print(newStatusJSON)
                var parameterType = ""
                
                if action == "start" {
                    parameterType = "StartingInstances"
                } else if action == "stop" {
                    parameterType = "StoppingInstances"
                }
                
                if let newStatus = newStatusJSON[parameterType][0]["CurrentState"]["Code"].int {
//                    instanceStatus = self.formatStatusCode(code: newStatus)
                    print("Success changing action instance \(id)")

                    SVProgressHUD.dismiss()
                    self.tableView.reloadData()
                } else {
//                    instanceStatus = "Error getting status"
                    print("Error updating status from actionInstance")

                    SVProgressHUD.dismiss()
                    self.tableView.reloadData()
                }
            }
        }
        self.refresher.endRefreshing()
    }
    
    //MARK: - JSON Parsing
    
    func updateInstancesArray(json: JSON) {
        
        instancesArray.removeAll()

        for (_, subJson):(String, JSON) in json {
            
            print("There is an object")

            if let id = subJson["InstanceId"].string {
                
                let temporaryInstance = Instance()
                
                var region : String = subJson["Placement"]["AvailabilityZone"].stringValue
                temporaryInstance.id = id
                temporaryInstance.launchTime = "Started: \(formatDate(date: subJson["LaunchTime"].stringValue))"
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
    
    func formatDate(date: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        guard let dateFromString = dateFormatter.date(from: date) else {return "Unable to format the date"}
        
        dateFormatter.dateFormat = "dd/MM/yyyy' at 'HH:mm"
        
        return dateFormatter.string(from: dateFromString)
        
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
    
    // UI Update
    
    func loadRegions() {
        
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                regionsArray = try decoder.decode([Region].self, from: data)
            } catch {
                print("Error decoding regionsArray \(error)")
            }
        }
        
    }
    
    func showSVProgressHUD() {
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }
    }
        
}

extension TableViewController: InstanceCellDelegate {
    
    func switchButton(_ cell: InstanceCell, didSwitchButton: UISwitch) {
        
        if let indexPath = tableView.indexPath(for: cell) {
        
            if cell.switchButton.isOn == true {
                
                instancesArray[indexPath.row].status = "Pending"
                self.actionInstance(url: instanceURL, region: instancesArray[indexPath.row].region, id: instancesArray[indexPath.row].id, action: "start")
                
                if defaults.bool(forKey: "notificationsSetting") {
                    createNotification(instance: self.instancesArray[indexPath.row])
                    print("Notification for instance \(self.instancesArray[indexPath.row].name) successfully added")
                }
                
            } else if cell.switchButton.isOn == false {
                
                instancesArray[indexPath.row].status = "Stopping"
                self.actionInstance(url: instanceURL, region: instancesArray[indexPath.row].region, id: instancesArray[indexPath.row].id, action: "stop")
                
                if defaults.bool(forKey: "notificationsSetting") {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.instancesArray[indexPath.row].name])
                    print("Notification for instance \(self.instancesArray[indexPath.row].name) successfully removed")
                }
            }
        }
    }
}

extension TableViewController: UNUserNotificationCenterDelegate {
    
    func createNotification(instance : Instance) {
        
        let userTimeInterval = TimeInterval(defaults.double(forKey: "timerInterval"))
        
        let content = UNMutableNotificationContent()
        UNUserNotificationCenter.current().delegate = self
        
//        let userInfo: [String : Any] = ["Instance": instance]

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
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
        
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
struct Notification {
    
    struct Category {
        static let tutorial = "tutorial"
    }
    
    struct Action {
        static let snooze = "snoozeInstance"
        static let showDetails = "showDetails"
        static let unsubscribe = "unsubscribe"
    }
    
}
