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
    
    let regions: [Region] = RegionFetcher.sharedInstance.regions
    
    @IBAction func selectAllRegions(_ sender: Any) {
        
        let rows = tableView.numberOfRows(inSection: 0)
        
        for row in 0..<rows {
            regions[row].isSelected = true
        }
        
        tableView.reloadData()
    }
    
    @IBAction func deselectAllRegions(_ sender: Any) {
        let rows = tableView.numberOfRows(inSection: 0)
        
        for row in 0..<rows {
            regions[row].isSelected = false
        }
        
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        RegionFetcher.sharedInstance.save()
    }
    

    // MARK: - Tableview data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let region = regions[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "regionCell", for: indexPath)
        
        cell.textLabel?.text = (region.flagEmoji ?? "") + " " + (region.friendlyName ?? "")
        cell.detailTextLabel?.text = region.rawRegion
        cell.accessoryType = region.isSelected ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let region = regions[indexPath.row]
        
        region.isSelected.toggle()
        
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.endUpdates()
    }
}
