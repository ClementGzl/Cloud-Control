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

class InstancesTVC: UITableViewController {

    var instances = [Instance]() {
        didSet {
            instances = instances.sorted(by: { (lhs, rhs) -> Bool in
                return lhs.region < rhs.region
            })
        }
    }

    let defaults = UserDefaults.standard
    
    let instanceURL = secretInstanceURL
    let listURL = secretListURL
    let headers: HTTPHeaders = ["x-api-key": secretApiKey]
    var refresher: UIRefreshControl!
    var regions: [Region] = RegionFetcher.sharedInstance.regions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: .zero, style: .grouped)
        
        UIApplication.shared.applicationIconBadgeNumber = 0

        tableView.register(UINib(nibName: "InstanceCell", bundle: nil), forCellReuseIdentifier: "InstanceCell")

        SVProgressHUD.setDefaultMaskType(.clear)
        
        refresher = UIRefreshControl()
        refresher.tintColor = .white
        refresher.addTarget(self, action: #selector(InstancesTVC.pullRefreshStatus), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refresher
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        addOrRemoveNoContentViewIfNecessary(type: .noInstance)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getStatus(url: listURL)
    }
    
    //MARK: - Tableview data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instances.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let instance = instances[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InstanceCell", for: indexPath) as! InstanceCell
        
        cell.nameLabel.text = instance.name
        cell.statusLabel.text = instance.status.description
        cell.launchTimeLabel.text = instance.launchTime
        
        if instance.isLoading {
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
        } else {
            cell.activityIndicator.isHidden = true
            cell.activityIndicator.stopAnimating()
        }
        
        cell.didSwitch = { [unowned self] (isOn) in
            self.didSwitchInstance(at: indexPath, isOn: isOn)
        }

        return cell
    }

    //MARK: - Networking
    
    @objc func pullRefreshStatus() {
        self.getStatus(url: listURL)
    }
    
//    func getInstancesList(url: String) {
//
//        Alamofire.request(url, method: .get, headers: headers).responseJSON {
//            response in
//
//            if response.result.isSuccess {
//
//                print("Success, got the instances list")
//
//                let instancesListJSON = JSON(response.result.value!)
//
//                SVProgressHUD.dismiss()
//
//            } else {
//                print("Error getting instances list, \(response.result.error!)")
//
//                SVProgressHUD.dismiss()
//            }
//        }
//    }
    
    @objc func getStatus(url : String) {
        
        showSVProgressHUD()
        
        let selectedRegions = regions.filter({$0.isSelected}).map({$0.rawRegion ?? ""}).joined(separator: ",")

        let params: Parameters = ["regions" : selectedRegions]
        
        Alamofire.request(url, method: .get, parameters: params, headers: headers).responseJSON {
            response in
            
            if response.result.isSuccess {

                let statusJSON = JSON(response.result.value!)
                
                self.updateInstancesArray(json:statusJSON)
                self.tableView.reloadData()

                SVProgressHUD.dismiss()
                self.refresher.endRefreshing()
                
            } else {
                print("Error getting status, \(response.result.error!)")
                
                SVProgressHUD.dismiss()
                self.addOrRemoveNoContentViewIfNecessary(type: .error)
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
                
                if let _ = newStatusJSON[parameterType][0]["CurrentState"]["Code"].int {
                    print("Success changing action instance \(id)")

                    SVProgressHUD.dismiss()
                    self.tableView.reloadData()
                    self.addOrRemoveNoContentViewIfNecessary(type: .noInstance)
                } else {
                    print("Error updating status from actionInstance")

                    SVProgressHUD.dismiss()
                    self.tableView.reloadData()
                    
                    self.addOrRemoveNoContentViewIfNecessary(type: .error)
                }
            } else {
                self.addOrRemoveNoContentViewIfNecessary(type: .error)
            }
        }
        self.refresher.endRefreshing()
    }
    
    //MARK: - JSON Parsing
    
    func updateInstancesArray(json: JSON) {
        
        instances.removeAll()
        
        if json.isEmpty {
            addOrRemoveNoContentViewIfNecessary(type: .noInstance)
            print("No Instance")
        }

        for (_, subJson):(String, JSON) in json {

            if let id = subJson["InstanceId"].string {
                
                var region : String = subJson["Placement"]["AvailabilityZone"].stringValue
                let launchTime = "Started: \(formatDate(date: subJson["LaunchTime"].stringValue))"
                region.remove(at: region.index(before: region.endIndex))
                let statusCode = subJson["State"]["Code"].intValue
                
                var instanceName: String? = nil
                
                for (_, value) in subJson["Tags"] {
                    if let name = value["Value"].string, value["Key"] == "Name" {
                        instanceName = name
                    }
                }
                
                let newInstance = Instance(region: region, id: id, name: instanceName, statusCode: statusCode, launchTime: launchTime)
                
                if newInstance.canBeAdded {
                    instances.append(newInstance)
                }
                
                addOrRemoveNoContentViewIfNecessary()
                
            } else {
                if regions.filter({$0.isSelected}).isEmpty {
                    self.addOrRemoveNoContentViewIfNecessary(type: .noRegionSelected)
                }
                print("Error updating instances array")
            }
        }
    }
    
    private func formatDate(date: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        guard let dateFromString = dateFormatter.date(from: date) else {
            return "Unable to format the date"
        }
        
        dateFormatter.dateFormat = "dd/MM/yyyy' at 'HH:mm"
        
        return dateFormatter.string(from: dateFromString)
    }
    
    private func showSVProgressHUD() {
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }
    }
    
    private func addOrRemoveNoContentViewIfNecessary(type: NoContentView.ViewType = .noInstance) {
        
        if let existingNoContentView = view.subviews.first(where: {$0 is NoContentView}) {
            existingNoContentView.removeFromSuperview()
        }
        
        if instances.isEmpty {
            let noContentView = NoContentView(type: type)
            noContentView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(noContentView)
            
            NSLayoutConstraint.activate([
                noContentView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
                noContentView.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 250)
                ])
        }
    }
    
    private func didSwitchInstance(at indexPath: IndexPath, isOn: Bool) {
        if isOn {
            instances[indexPath.row].status = .pending
            self.actionInstance(url: instanceURL, region: instances[indexPath.row].region, id: instances[indexPath.row].id, action: "start")
            
            if defaults.bool(forKey: "notificationsSetting") {
                createNotification(instance: self.instances[indexPath.row])
                print("Notification for instance \(self.instances[indexPath.row].name) successfully added")
            }
            
        } else {
            
            instances[indexPath.row].status = .stopping
            self.actionInstance(url: instanceURL, region: instances[indexPath.row].region, id: instances[indexPath.row].id, action: "stop")
            
            if defaults.bool(forKey: "notificationsSetting") {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.instances[indexPath.row].name])
                print("Notification for instance \(self.instances[indexPath.row].name) successfully removed")
            }
        }
    }
}
