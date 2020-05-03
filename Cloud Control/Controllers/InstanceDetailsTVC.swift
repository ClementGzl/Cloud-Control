//
//  InstanceDetailsTVC.swift
//  Cloud Control
//
//  Created by Clement Gonzalvez on 05/11/2019.
//  Copyright © 2019 Clément. All rights reserved.
//

import UIKit
import MapKit

class InstanceDetailsTVC: UITableViewController, MKMapViewDelegate {
    
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
        tableView.register(UINib(nibName: "MapCell", bundle: nil), forCellReuseIdentifier: "MapCell")
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeTapped))
        navigationItem.leftBarButtonItem = closeButton
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 5
        default:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell") as! MapCell
        
        cell.mapView.delegate = self
        
        let coordinates = getCoordinates(fromRegion: instance.region)
        let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 700000, longitudinalMeters: 700000)
        
        let annotation = MKPointAnnotation()

        annotation.coordinate = coordinates
        annotation.title = instance.name
        
        cell.mapView.addAnnotation(annotation)
        cell.mapView.setRegion(region, animated: false)
        
        let mapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
        cell.mapView.addGestureRecognizer(mapGestureRecognizer)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "instance informations"
        case 1:
            return "instance location"
        default:
            return nil
        }
    }
    
    @objc private func mapTapped() {
        let coordinates = getCoordinates(fromRegion: instance.region)
        MKMapItem(placemark: MKPlacemark(coordinate: coordinates)).openInMaps()
    }
    
    private func getCoordinates(fromRegion region: String) -> CLLocationCoordinate2D {
        //todo: finish this
        switch region {
        case "us-east-1":
            return CLLocationCoordinate2D(latitude: 37.926868, longitude: -78.024902)
        case "us-east-2":
            return CLLocationCoordinate2D(latitude: 40.367474, longitude: -82.996216)
        case "us-west-1":
            return CLLocationCoordinate2D(latitude: 38.8375, longitude: -120.8958)
        case "eu-west-1":
            return CLLocationCoordinate2D(latitude: 53.350140, longitude: -6.266155)
        case "eu-west-2":
            return CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275)
        case "eu-west-3":
            return CLLocationCoordinate2D(latitude: 48.864716, longitude: 2.349014)
        default:
            return CLLocationCoordinate2D(latitude: 48.864716, longitude: 2.349014)
        }
    }
}
