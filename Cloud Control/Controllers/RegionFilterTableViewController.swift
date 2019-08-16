//
//  RegionFilterTableViewController.swift
//  Cloud Control
//
//  Created by Clément Gonzalvez on 20/08/2018.
//  Copyright © 2018 Clément. All rights reserved.
//

import UIKit
import CoreData

class RegionFilterTableViewController: UITableViewController {

    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Regions.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    let regions: [Region] = RegionFetcher.sharedInstance.regions
    
    @IBAction func selectAllRegions(_ sender: Any) {
        tableView.reloadData()
    }
    
    @IBAction func deselectAllRegions(_ sender: Any) {
        tableView.reloadData()
    }
    

    // MARK: - Tableview data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let region = regions[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "regionCell", for: indexPath)
        
        cell.textLabel?.text = region.friendlyName
        cell.detailTextLabel?.text = region.rawRegion
        cell.accessoryType = region.isSelected ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let region = regions[indexPath.row]
        
        region.isSelected.toggle()
        
        RegionFetcher.sharedInstance.save()
        
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.endUpdates()
    }
    
    // MARK: - Loading and saving Data
    
//    func saveRegions() {
//
//        let encoder = PropertyListEncoder()
//
//        do {
//            let data = try encoder.encode(regions)
//            try data.write(to: dataFilePath!)
//        } catch {
//            print("Error encoding regionsArray \(error)")
//        }
//
//        self.tableView.reloadData()
//    }

//    func loadRegions() {
//
//        if let data = try? Data(contentsOf: dataFilePath!) {
//            let decoder = PropertyListDecoder()
//            do {
//                regions = try decoder.decode([Region].self, from: data)
//            } catch {
//                print("Error decoding regionsArray \(error)")
//            }
//        }
//    }
}
