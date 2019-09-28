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
            statusLabel.textColor = .systemOrange
            switchButton.isOn = true
            switchButton.isEnabled = false
        case .running:
            statusLabel.text = status.description
            statusLabel.textColor = .systemGreen
            switchButton.isOn = true
            switchButton.isEnabled = true
        case .stopping, .shuttingDown:
            statusLabel.text = status.description
            statusLabel.textColor = .systemOrange
            switchButton.isOn = false
            switchButton.isEnabled = false
        default:
            statusLabel.text = status.description
            statusLabel.textColor = .label
            switchButton.isEnabled = true
            switchButton.isOn = false
        }
    }

    @IBAction func changeInstanceAction(_ sender: UISwitch) {
        didSwitch?(sender.isOn)
    }
}
