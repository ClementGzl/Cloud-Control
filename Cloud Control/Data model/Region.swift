//
//  Region.swift
//  Cloud Control
//
//  Created by Clément Gonzalvez on 20/08/2018.
//  Copyright © 2018 Clément. All rights reserved.
//

import UIKit
import CoreData

class RegionFetcher {
    
    var regions: [Region] = []
    
    static let sharedInstance = RegionFetcher()
    
    init() {
        fetch()
    }
    
    private func fetch() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Region>(entityName: "Region")
        
        do {
            let regions = try managedContext.fetch(fetchRequest)
            
            if regions.isEmpty {
                generateInitialRegions()
                fetch()
                return
            } else {
                self.regions = regions
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func save() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        do {
            try managedContext.save()
        } catch {
            print("Error saving regions: \(error)")
        }
        
    }
    
    private func generateInitialRegions() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        guard let userEntity = NSEntityDescription.entity(forEntityName: "Region", in: managedContext) else {
            return
        }
        
        let usEast1 = Region(entity: userEntity, insertInto: managedContext)
        usEast1.rawRegion = "us-East-1"
        usEast1.friendlyName = "US East (N. Virginia)"
        
        let usEast2 = Region(entity: userEntity, insertInto: managedContext)
        usEast2.rawRegion = "us-East-2"
        usEast2.friendlyName = "US East (Ohio)"
        
        let usWest1 = Region(entity: userEntity, insertInto: managedContext)
        usWest1.rawRegion = "us-West-1"
        usWest1.friendlyName = "US West (N. California)"
        
        let usWest2 = Region(entity: userEntity, insertInto: managedContext)
        usWest2.rawRegion = "us-West-2"
        usWest2.friendlyName = "US West (Oregon)"
        
        let apNorthEast1 = Region(entity: userEntity, insertInto: managedContext)
        apNorthEast1.rawRegion = "ap-NorthEast-1"
        apNorthEast1.friendlyName = "Asia Pacific (Tokyo)"
        
        let apNorthEast2 = Region(entity: userEntity, insertInto: managedContext)
        apNorthEast2.rawRegion = "ap-NorthEast-2"
        apNorthEast2.friendlyName = "Asia Pacific (Seoul)"
        
        let apSouth1 = Region(entity: userEntity, insertInto: managedContext)
        apSouth1.rawRegion = "ap-South-1"
        apSouth1.friendlyName = "Asia Pacific (Mumbai)"
        
        let apSouthEast1 = Region(entity: userEntity, insertInto: managedContext)
        apSouthEast1.rawRegion = "ap-SouthEast-1"
        apSouthEast1.friendlyName = "Asia Pacific (Singapore)"
        
        let apSouthEast2 = Region(entity: userEntity, insertInto: managedContext)
        apSouthEast2.rawRegion = "ap-SouthEast-2"
        apSouthEast2.friendlyName = "Asia Pacific (Sydney)"
        
        let caCentral1 = Region(entity: userEntity, insertInto: managedContext)
        caCentral1.rawRegion = "ca-Central-1"
        caCentral1.friendlyName = "Canada (Central)"
        
        let euCentral1 = Region(entity: userEntity, insertInto: managedContext)
        euCentral1.rawRegion = "eu-Central-1"
        euCentral1.friendlyName = "EU (Frankfurt)"
        
        let euWest1 = Region(entity: userEntity, insertInto: managedContext)
        euWest1.rawRegion = "eu-West-1"
        euWest1.friendlyName = "EU (Ireland)"
        
        let euWest2 = Region(entity: userEntity, insertInto: managedContext)
        euWest2.rawRegion = "eu-West-2"
        euWest2.friendlyName = "EU (London)"
        
        let euWest3 = Region(entity: userEntity, insertInto: managedContext)
        euWest3.rawRegion = "eu-West-3"
        euWest3.friendlyName = "EU (Paris)"
        
        let eunorth1 = Region(entity: userEntity, insertInto: managedContext)
        eunorth1.rawRegion = "eu-north-1"
        eunorth1.friendlyName = "EU (Stockholm)"
        
        let saEast1 = Region(entity: userEntity, insertInto: managedContext)
        saEast1.rawRegion = "sa-East-1"
        saEast1.friendlyName = "South America (São Paulo)"
        
        do {
            try managedContext.save()
        } catch {
            print("Error saving inital regions: \(error)")
        }
    }
    
}
