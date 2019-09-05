//
//  InstanceCell.swift
//  Cloud Control
//
//  Created by Clément Gonzalvez on 16/08/2018.
//  Copyright © 2018 Clément. All rights reserved.
//

import UIKit

class InstanceCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var launchTimeLabel: UILabel!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var typeLabel: UILabel!
    
    var didSwitch: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.cornerRadius = 5
    }
    
    func updateStatus(fromStatus status: Instance.Status) {
        switch status {
        case .pending:
            statusLabel.text = status.description
            statusLabel.textColor = UIColor.orange
            switchButton.isOn = true
            switchButton.isEnabled = false
        case .running:
            statusLabel.text = status.description
            statusLabel.textColor = UIColor.green
            switchButton.isOn = true
            switchButton.isEnabled = true
        case .stopping, .shuttingDown:
            statusLabel.text = status.description
            statusLabel.textColor = UIColor.orange
            switchButton.isOn = false
            switchButton.isEnabled = false
        default:
            statusLabel.text = status.description
            statusLabel.textColor = UIColor.darkText
            switchButton.isEnabled = true
            switchButton.isOn = false
        }
    }
    
//    override func layoutSubviews() {
//
//        super.layoutSubviews()
//        if statusLabel.text == "Running" {
//            statusLabel.textColor = UIColor.green
//            switchButton.isOn = true
//            switchButton.isEnabled = true
//        } else if statusLabel.text == "Pending" {
//            statusLabel.textColor = UIColor.orange
//            switchButton.isOn = true
//            switchButton.isEnabled = false
//        } else if statusLabel.text == "Stopping" {
//            statusLabel.textColor = UIColor.orange
//            switchButton.isOn = false
//            switchButton.isEnabled = false
//        } else {
//            statusLabel.textColor = UIColor.darkText
//            switchButton.isEnabled = true
//            switchButton.isOn = false
//        }
//    }

    @IBAction func changeInstanceAction(_ sender: UISwitch) {
        didSwitch?(sender.isOn)
    }
}
