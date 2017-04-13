//
//  SignInViewController.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import UIKit
import BeanstalkEngageiOSSDK

class SignInViewController: BaseViewController, UITextFieldDelegate {
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
        self.loadingHandler.showProgress("Attempting to Login")
        self.coreService?.authenticateMe(email: email, password: password, handler: { (success, error) in
          self.loadingHandler.handleError(success: success, error: error)
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
