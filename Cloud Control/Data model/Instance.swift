//
//  Instance.swift
//  Cloud Control
//
//  Created by Clément Gonzalvez on 15/08/2018.
//  Copyright © 2018 Clément. All rights reserved.
//

import Foundation

class Instance {
    
    enum Status {
        case pending
        case running
        case shuttingDown
        case terminated
        case stopping
        case stopped
        
        init(code: Int) {
            switch code {
            case 0:
                self = .pending
            case 16:
                self = .running
            case 32:
                self = .shuttingDown
            case 48:
                self = .terminated
            case 64:
                self = .stopping
            case 80:
                self = .stopped
            default:
                self = .stopped
            }
        }
        
        var description: String {
            switch self {
            case .pending:
                return "Pending"
            case .running:
                return "Running"
            case .shuttingDown:
                return "Shutting Down"
            case .stopped:
                return "Stopped"
            case .stopping:
                return "Stopping"
            case .terminated:
                return "Terminated"
            }
        }
    }
    
    let region: String
    let id: String
    let name: String
    var status: Status
    let launchTime: String
    let type: String
    
    init(region: String, id: String, name: String?, statusCode: Int, launchTime: String, type: String) {
        self.region = region
        self.id = id
        self.name = name ?? id
        self.status = Status(code: statusCode)
        self.launchTime = launchTime
        self.type = type
    }
    
    var canBeAdded: Bool {
        return status != .terminated
    }
    
    var isLoading: Bool {
        return status == .pending || status == .stopping
    }
    
}
