//
//  InstanceCell.swift
//  Cloud Control
//
//  Created by Clément Gonzalvez on 16/08/2018.
//  Copyright © 2018 Clément. All rights reserved.
//

import UIKit

class InstanceCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var statusLabel: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
