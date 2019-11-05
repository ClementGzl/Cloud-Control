//
//  InstanceDetailsTVC.swift
//  Cloud Control
//
//  Created by Clement Gonzalvez on 05/11/2019.
//  Copyright © 2019 Clément. All rights reserved.
//

import UIKit

class InstanceDetailsTVC: UITableViewController {
    
    let instance: Instance

    init(instance: Instance) {
        self.instance = instance
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = instance.name
        
        tableView.allowsSelection = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Region"
            cell.detailTextLabel?.text = instance.region
        case 1:
            cell.textLabel?.text = "ID"
            cell.detailTextLabel?.text = instance.id
        case 2:
            cell.textLabel?.text = "Launch Time"
            cell.detailTextLabel?.text = instance.launchTime
        case 3:
            cell.textLabel?.text = "Type"
            cell.detailTextLabel?.text = instance.type
        case 4:
            cell.textLabel?.text = "Status"
            cell.detailTextLabel?.text = instance.status.description
        default:
            fatalError("wrong index path on detailed cell tvc")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "instance informations"
        }
        
        return nil
    }
}
