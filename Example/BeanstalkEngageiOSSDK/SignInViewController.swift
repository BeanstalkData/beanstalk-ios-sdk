//
//  SignInViewController.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import UIKit
import BeanstalkEngageiOSSDK

class SignInViewController: BaseViewController, AuthenticationProtocol, UITextFieldDelegate {
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Sign In",
            style: .Plain,
            target: self,
            action: #selector(signIn))
    }
    
    //MARK: - Actions
    
    func signIn() {
        self.view.endEditing(true)
        
        if let email = self.emailTextField.text {
            if let password = self.passwordTextField.text {
                self.coreService?.authenticate(self, email: email, password: password, handler: { (success, additionalInfo) in
                    self.completionBlock?(success: success)
                })
            }
        }
    }
    
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return false
    }
}
