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

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layer.cornerRadius = 5

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
            launchTimeLabel.text = ""
        }
    }
    
    weak var delegate: InstanceCellDelegate?
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var launchTimeLabel: UILabel!
    @IBOutlet weak var switchButton: UISwitch!
    @IBAction func changeInstanceAction(_ sender: UISwitch) {

        self.delegate?.switchButton(self, didSwitchButton: sender)
        
    }
    
    

    
}
