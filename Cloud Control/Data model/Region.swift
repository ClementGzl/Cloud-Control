//
//  Region.swift
//  Cloud Control
//
//  Created by Clément Gonzalvez on 20/08/2018.
//  Copyright © 2018 Clément. All rights reserved.
//

import UIKit

class Region: Codable {
    
    var name: String = ""
    var region: String = ""
    var isSelected: Bool = false
    
    init(name forName : String, region forRegion : String) {
        name = forName
        region = forRegion
    }
    
}

    var regionsArray : [Region] = [
        
        Region(name:"US East (Ohio)", region:"us-east-2"),
        Region(name: "US East (N. Virginia)", region: "us-east-1"),
        Region(name: "US West (N. California)", region: "us-west-1"),
        Region(name: "US West (Oregon)", region: "us-west-2"),
        Region(name: "Asia Pacific (Tokyo)", region: "ap-northeast-1"),
        Region(name: "Asia Pacific (Seoul)", region: "ap-northeast-2"),
        Region(name: "Asia Pacific (Mumbai)", region: "ap-south-1"),
        Region(name: "Asia Pacific (Singapore)", region: "ap-southeast-1"),
        Region(name: "Asia Pacific (Sydney)", region: "ap-southeast-2"),
        Region(name: "Canada (Central)", region: "ca-central-1"),
        Region(name: "EU (Frankfurt)", region: "eu-central-1"),
        Region(name: "EU (Ireland)", region: "eu-west-1"),
        Region(name: "EU (London)", region: "eu-west-2"),
        Region(name: "EU (Paris)", region: "eu-west-3"),
        Region(name: "South America (São Paulo)", region: "sa-east-1")
        
    ]
