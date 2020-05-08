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
import UserNotifications

class InstancesTVC: UITableViewController {
    
    var instances = [Instance]() {
        didSet {
            instances = instances.sorted(by: { (lhs, rhs) -> Bool in
                return lhs.region < rhs.region
            })
        }
    }
    
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
        
        refresher = UIRefreshControl()
        refresher.tintColor = .white
        refresher.addTarget(self, action: #selector(InstancesTVC.pullRefreshStatus), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refresher
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        addOrRemoveNoContentViewIfNecessary(type: .noInstance)
        
        setNavigationBarColorIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getStatus(url: listURL)
    }
    
    private func setNavigationBarColorIfNeeded() {
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.backgroundColor = #colorLiteral(red: 0.03921568627, green: 0.2588235294, blue: 0.8745098039, alpha: 1)
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
    }
    
    //MARK: - Tableview data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instances.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let instance = instances[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InstanceCell", for: indexPath) as! InstanceCell
        
        cell.nameLabel.text = instance.name
        cell.launchTimeLabel.text = instance.launchTime
        cell.typeLabel.text = "Type: \(instance.type)"
        
        cell.updateStatus(fromStatus: instance.status)
        
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let instance = instances[indexPath.row]
        
        let instanceDetailsTVC = InstanceDetailsTVC(instance: instance)
        let nc = UINavigationController(rootViewController: instanceDetailsTVC)
        nc.modalPresentationStyle = .formSheet
        present(nc, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
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
    //            } else {
    //                print("Error getting instances list, \(response.result.error!)")
    //            }
    //        }
    //    }
    
    @objc func getStatus(url : String) {
        
        let selectedRegions = regions.filter({$0.isSelected}).map({$0.rawRegion ?? ""}).joined(separator: ",")
        
        let params: Parameters = ["regions" : selectedRegions]
        
        Alamofire.request(url, method: .get, parameters: params, headers: headers).responseJSON {
            response in
            
            if response.result.isSuccess {
                
                let statusJSON = JSON(response.result.value!)
                
                self.updateInstancesArray(json: statusJSON)
                self.tableView.reloadData()
                
                self.refresher.endRefreshing()
                
            } else {
                print("Error getting status, \(response.result.error!)")
                
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
                    
                    self.tableView.reloadData()
                    self.addOrRemoveNoContentViewIfNecessary(type: .noInstance)
                } else {
                    print("Error updating status from actionInstance")
                    
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
                let launchTime = "Last started: \(formatDate(date: subJson["LaunchTime"].stringValue))"
                region.remove(at: region.index(before: region.endIndex))
                let statusCode = subJson["State"]["Code"].intValue
                let type = subJson["InstanceType"].stringValue
                
                var instanceName: String? = nil
                
                for (_, value) in subJson["Tags"] {
                    if let name = value["Value"].string, value["Key"] == "Name" {
                        instanceName = name
                    }
                }
                
                let newInstance = Instance(region: region, id: id, name: instanceName, statusCode: statusCode, launchTime: launchTime, type: type)
                
                if newInstance.canBeAdded {
                    instances.append(newInstance)
                }
                
                addOrRemoveNoContentViewIfNecessary()
                
            } else {
                if regions.filter({$0.isSelected}).isEmpty {
                    self.addOrRemoveNoContentViewIfNecessary(type: .noRegionSelected)
                }
                print("Error updating instances array: \(json.description)")
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
        
        let defaults = UserDefaults.standard
        
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
