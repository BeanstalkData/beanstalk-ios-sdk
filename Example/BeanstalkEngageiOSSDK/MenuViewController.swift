//
//  MenuViewController.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import UIKit
import BeanstalkEngageiOSSDK

class MenuViewController: BaseViewController, GIDSignInUIDelegate  {
  
  @IBOutlet var registerButton: UIButton!
  @IBOutlet var signInButton: UIButton!
  @IBOutlet var signOutButton: UIButton!
  @IBOutlet var profileButton: UIButton!
  @IBOutlet var availableRewardsButton: UIButton!
  @IBOutlet var userProgressButton: UIButton!
  @IBOutlet var giftCardsButton: UIButton!
  @IBOutlet var contactManagementButton: UIButton!
  @IBOutlet var trackTransactionButton: UIButton!
  @IBOutlet var transactionsListButton: UIButton!
  @IBOutlet weak var versionLabel: UILabel!
  
  private(set) var googleUser: GoogleUserInfo?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.coreService = AppDelegate.apiService()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    updateAuthStatus()
    versionLabel.text = version()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    if let vc = segue.destination as? BaseViewController {
      vc.coreService = self.coreService
    }
    
    if let vc = segue.destination as? RegisterViewController {
      vc.completionBlock = { (success) in
        if success {
          _ = self.navigationController?.popToRootViewController(animated: true)
        }
        
        self.updateAuthStatus()
      }
    }
    else if let vc = segue.destination as? SignInViewController {
      vc.completionBlock = { (success) in
        if success {
          _ = self.navigationController?.popToRootViewController(animated: true)
        }
        
        self.updateAuthStatus()
      }
    }
    else if let vc = segue.destination as? TransactionsListTableViewController {
      vc.coreService = self.coreService
    }
  }
  
  
  //MARK: - Actions
  
  @IBAction func signOutAction() {
    let alert = UIAlertController(title: "Sign Out",
                                  message: "Would you like to Sign Out?",
                                  preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    alert.addAction(UIAlertAction(title: "Sign Out", style: .default, handler: { (_) in
      self.loadingHandler.showProgress("Logout...")
      self.coreService?.logout(handler: { (success, error) in
        self.loadingHandler.hideProgress()
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
          self.loadingHandler.showProgress("Reseting Password")
          self.coreService?.resetPassword(email: email, handler: { (success, error) in
            self.loadingHandler.handleError(success: true, error: error)
            if success {
              self.loadingHandler.showMessage("Password reset", message: nil)
            }
          })
        }
    }))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  
  @IBAction func onGoogleSignIn(_ sender: Any) {
    onLoginByGoogleAction(vc: self)
  }
  
  func onLoginByGoogleAction(vc: UIViewController) {
    GIDSignIn.sharedInstance().uiDelegate = self
    SocialNetworksClient.sharedInstance.loginWithGoogle {[weak self] (user, error) in
      guard let user = user else {
        self?.loadingHandler.hideProgress()
        return
      }
      
      self?.googleUser = user
      self?.loadingHandler.handleError(success: error == nil, error: error as? BEErrorType)

      self?.coreService?.authWithGoogleUser(googleId: user.user.userID,
                                            googleToken: user.user.authentication.idToken,
                                            contactClass: ContactModel.self,
                                            handler: { success, error in
                                              self?.loadingHandler.hideProgress()

//                                              if let contact = self?.coreService?.getSession()?.getContact() {
//                                                self?.pushEnrollment?.onSignIn(contact: contact)
//                                              }
      })
    }
  }
  
  //MARK: - Private
  
  private func updateAuthStatus() {
    var isAuthenticated = false
    var isContactAvailableInSession = false
    
    if let isAuth = self.coreService?.isAuthenticated() {
      isAuthenticated = isAuth
    }
    if let _ = self.coreService?.getSession()?.getContact() {
      isContactAvailableInSession = true
    }
    
    self.registerButton.isEnabled = !isAuthenticated
    self.signInButton.isEnabled = !isAuthenticated
    self.signOutButton.isEnabled = isAuthenticated
    self.profileButton.isEnabled = isContactAvailableInSession
    self.availableRewardsButton.isEnabled = isAuthenticated
    self.userProgressButton.isEnabled = isAuthenticated
    self.giftCardsButton.isEnabled = isAuthenticated
  }
  
  private func version() -> String {
    let dictionary = Bundle.main.infoDictionary!
    let version = dictionary["CFBundleShortVersionString"] as! String
    let build = dictionary["CFBundleVersion"] as! String
    return "Version: \(version) build \(build)"
  }
}
