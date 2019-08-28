//
//  InstanceCell.swift
//  Cloud Control
//
//  Created by Clément Gonzalvez on 16/08/2018.
//  Copyright © 2018 Clément. All rights reserved.
//

import UIKit

protocol InstanceCellDelegate: class {
    func switchButton(_ cell: InstanceCell, didSwitchButton: UISwitch)
}

class InstanceCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var launchTimeLabel: UILabel!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    weak var delegate: InstanceCellDelegate?
    
    var didSwitch: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.cornerRadius = 5
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        if statusLabel.text == "Running" {
            statusLabel.textColor = UIColor.green
            switchButton.isOn = true
            switchButton.isEnabled = true
        } else if statusLabel.text == "Pending" {
            statusLabel.textColor = UIColor.orange
            switchButton.isOn = true
            switchButton.isEnabled = false
        } else if statusLabel.text == "Stopping" {
            statusLabel.textColor = UIColor.orange
            switchButton.isOn = false
            switchButton.isEnabled = false
        } else {
            statusLabel.textColor = UIColor.darkText
            switchButton.isEnabled = true
            switchButton.isOn = false
            launchTimeLabel.text = ""
        }
    }

    @IBAction func changeInstanceAction(_ sender: UISwitch) {
        didSwitch?(sender.isOn)
    }
}
