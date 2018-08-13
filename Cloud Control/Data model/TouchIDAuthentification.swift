//
//  TouchIDAuthentification.swift
//  VPN Stat
//
//  Created by Clément Gonzalvez on 20/07/2018.
//  Copyright © 2018 Clément. All rights reserved.
//

import Foundation
import LocalAuthentication

class BiometricIDAuth {
    
    let context = LAContext()
    var loginReason = "Logging in with Touch ID"
    
    func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func biometricType() -> BiometricType {
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .none:
            return .none
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        }
    }
    
    enum BiometricType {
        case none
        case touchID
        case faceID
    }
    
    func authenticateUser(completion: @escaping (String?) -> Void) { // 1
        // 2
        guard canEvaluatePolicy() else {
            completion("Touch ID not available")
            return
        }
        
        // 3
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
           localizedReason: loginReason) { (success, evaluateError) in
            // 4
            if success {
                DispatchQueue.main.async {
                    // User authenticated successfully, take appropriate action
                    completion(nil)
                }
            } else {
                // 1
                let message: String
                
                // 2
                switch evaluateError {
                // 3
                case LAError.authenticationFailed?:
                    message = "There was a problem verifying your identity."
                case LAError.userCancel?:
                    message = "You pressed cancel."
                case LAError.userFallback?:
                    message = "You pressed password."
                case LAError.biometryNotAvailable?:
                    message = "Face ID/Touch ID is not available."
                case LAError.biometryNotEnrolled?:
                    message = "Face ID/Touch ID is not set up."
                case LAError.biometryLockout?:
                    message = "Face ID/Touch ID is locked."
                default:
                    message = "Face ID/Touch ID may not be configured"
                }
                // 4
                completion(message)
            }
        }
    }
}
