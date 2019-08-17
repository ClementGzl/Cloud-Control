//
//  Biometric Authentification.swift
//  Cloud Control
//
//  Created by Clément Gonzalvez on 12/11/2018.
//  Copyright © 2018 Clément. All rights reserved.
//

import Foundation
import LocalAuthentication

class BiometricIDAuth {
    
    enum BiometricType {
        case none
        case touchID
        case faceID
    }
    
    let context = LAContext()
    
    func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func biometricType() -> BiometricType {
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        default:
            return .none
        }
    }
}
