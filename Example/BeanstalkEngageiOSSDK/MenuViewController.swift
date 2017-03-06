//
//  MenuViewController.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import UIKit
import BeanstalkEngageiOSSDK

class MenuViewController: UIViewController, CoreProtocol, AuthenticationProtocol {
  @IBOutlet var registerButton: UIButton!
  @IBOutlet var signInButton: UIButton!
  @IBOutlet var signOutButton: UIButton!
  @IBOutlet var profileButton: UIButton!
  @IBOutlet var availableRewardsButton: UIButton!
  @IBOutlet var userProgressButton: UIButton!
  @IBOutlet var giftCardsButton: UIButton!
  
  
  let coreService = ApiService(apiKey: "1234-4321-ABCD-DCBA", session: BESession())
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.updateAuthStatus()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    if let vc = segue.destination as? BaseViewController {
      vc.coreService = self.coreService
    }
    
    if let vc = segue.destination as? RegisterViewController {
      vc.completionBlock = { (success) in
        if success {
          self.navigationController?.popToRootViewController(animated: true)
        }
        
        self.updateAuthStatus()
      }
    }
    else if let vc = segue.destination as? SignInViewController {
      vc.completionBlock = { (success) in
        if success {
          self.navigationController?.popToRootViewController(animated: true)
        }
        
        self.updateAuthStatus()
      }
    }
  }
  
  
  //MARK: - Actions
  
  @IBAction func signOutAction() {
    let alert = UIAlertController(title: "Sign Out",
                                  message: "Would you like to Sign Out?",
                                  preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    alert.addAction(UIAlertAction(title: "Sign Out", style: .default, handler: { (_) in
      self.coreService.logout(self, handler: { (success) in
        self.updateAuthStatus()
      })
    }))
    self.present(alert, animated: true, completion: nil)
  }
  
  @IBAction func resetPasswordAction() {
    let alert = UIAlertController(title: "Reset Password",
                                  message: "",
                                  preferredStyle: .alert)
    alert.addTextField { (tf) in
      
    }
    
    alert.addAction(UIAlertAction(
      title: "Cancel",
      style: .cancel,
      handler: nil))
    
    alert.addAction(UIAlertAction(
      title: "Reset",
      style: .default,
      handler: { (_) in
        if let email = alert.textFields?.first?.text {
          self.coreService.resetPassword(self, email: email, handler: { (success) in
            
          })
        }
    }))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  
  //MARK: - Private
  
  private func updateAuthStatus() {
    let isAuthenticated = self.coreService.isAuthenticated()
    
    self.registerButton.isEnabled = !isAuthenticated
    self.signInButton.isEnabled = !isAuthenticated
    self.signOutButton.isEnabled = isAuthenticated
    self.profileButton.isEnabled = isAuthenticated
    self.availableRewardsButton.isEnabled = isAuthenticated
    self.userProgressButton.isEnabled = isAuthenticated
    self.giftCardsButton.isEnabled = isAuthenticated
  }
}
