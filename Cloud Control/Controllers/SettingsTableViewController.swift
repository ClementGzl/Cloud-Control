//
//  SettingsTableViewController.swift
//  Cloud Control
//
//  Created by Clément Gonzalvez on 20/08/2018.
//  Copyright © 2018 Clément. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Settings.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
