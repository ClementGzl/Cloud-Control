//
//  AuthViewController.swift
//  VPN Stat
//
//  Created by Clément Gonzalvez on 20/07/2018.
//  Copyright © 2018 Clément. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthViewController: UIViewController {

    
    let touchMe = BiometricIDAuth()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        touchIDButton.isHidden = !touchMe.canEvaluatePolicy()
        
        if touchIDButton.isHidden == true {
            loginText.text = "Your device isn't compatible"
        }
        
        switch touchMe.biometricType() {
        case .faceID:
            touchIDButton.setImage(UIImage(named: "FaceIcon"),  for: .normal)
        default:
            touchIDButton.setImage(UIImage(named: "Touch-icon-lg"),  for: .normal)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let touchBool = touchMe.canEvaluatePolicy()
        if touchBool {
            touchIDLoginAction()
        }
    }
    
    @IBOutlet weak var loginText: UILabel!
    
    @IBOutlet weak var touchIDButton: UIButton!
    
    @IBAction func touchIDLoginAction() {
        // 1
        touchMe.authenticateUser() { [weak self] message in
            // 2
            if let message = message {
                // if the completion is not nil show an alert
                let alertView = UIAlertController(title: "Error",
                                                  message: message,
                                                  preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Darn!", style: .default)
                alertView.addAction(okAction)
                self?.present(alertView, animated: true)
            } else {
                // 3
                self?.performSegue(withIdentifier: "goToVPN", sender: self)
            }
        }
    }
    
}

