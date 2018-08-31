//
//  RegionFilterTableViewController.swift
//  Cloud Control
//
//  Created by Clément Gonzalvez on 20/08/2018.
//  Copyright © 2018 Clément. All rights reserved.
//

import UIKit

class RegionFilterTableViewController: UITableViewController {

    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Regions.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func selectAllRegions(_ sender: Any) {
        for region in regionsArray {
            region.isSelected = true
        }
        saveRegions()
        tableView.reloadData()
    }
    
    @IBAction func deselectAllRegions(_ sender: Any) {
        for region in regionsArray {
            region.isSelected = false
        }
        saveRegions()
        tableView.reloadData()
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return regionsArray.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let region = regionsArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "regionCell", for: indexPath)
        
        cell.textLabel?.text = region.name
        cell.detailTextLabel?.text = region.region
        cell.accessoryType = region.isSelected ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let regionSelected = regionsArray[indexPath.row]
        
        regionSelected.isSelected = !regionSelected.isSelected
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.saveRegions()
        
    }
    
    func saveRegions() {

        let encoder = PropertyListEncoder()

        do {
            let data = try encoder.encode(regionsArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding regionsArray \(error)")
        }

        self.tableView.reloadData()
    }

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
    
}
