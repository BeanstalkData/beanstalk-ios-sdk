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
      style: .plain,
      target: self,
      action: #selector(signIn))
  }
  
  //MARK: - Actions
  
  func signIn() {
    self.view.endEditing(true)
    
    if let email = self.emailTextField.text {
      if let password = self.passwordTextField.text {
        self.coreService?.authenticateMe(self, email: email, password: password, handler: { (success) in
          self.completionBlock?(success)
        })
      }
    }
  }
  
  
  //MARK: - UITextFieldDelegate
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    
    return false
  }
}
