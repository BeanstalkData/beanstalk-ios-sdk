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
  @IBOutlet weak var envButton: UIButton!
  @IBOutlet weak var versionLabel: UILabel!
  
  private(set) var googleUser: GoogleUserInfo?
  private let envConfigurator = EnvironmetConfigurator.shared
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.coreService = AppDelegate.apiService()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    updateAuthStatus()
    versionLabel.text = version()
    envButton.setTitle("Env: \(envConfigurator.getCurrentEnv().rawValue.uppercased())", for: .normal)
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
      handler: { _ in
        self.processResetPasswordAction(alert.textFields?.first?.text)
    }))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  private func processResetPasswordAction(_ email: String?) {
    self.loadingHandler.showProgress("Reseting Password")
    self.coreService?.resetPassword(email: email, handler: { (success, error) in
      self.loadingHandler.handleError(success: success, error: error)
      if success {
        self.loadingHandler.showMessage("Password reset", message: nil)
      }
    })
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
  
  @IBAction func didSelectEnvButton(_ sender: Any) {
    showEnvPickerView()
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

extension MenuViewController: UIPickerViewDataSource, UIPickerViewDelegate {
  private class EnvPickerView: UIPickerView {
    var didSelectEnvironment: ((_ env: Environment) -> Void)?
  }
  
  private func showEnvPickerView() {
    let picker = EnvPickerView()
    picker.dataSource = self
    picker.delegate = self
    
    let dummy = UITextField(frame: CGRect.zero)
    view.addSubview(dummy)
    
    dummy.inputView = picker
    dummy.becomeFirstResponder()
    
    let currentEnv = envConfigurator.getCurrentEnv()
    let selectedRow = envConfigurator.getEnviromentList().index(of: currentEnv) ?? 0
    
    picker.selectRow(selectedRow, inComponent: 0, animated: false)
    
    picker.didSelectEnvironment = {[weak self] env in
      self?.envConfigurator.setEnvironment(env: env)
      
      self?.envButton.setTitle("Env: \(env.rawValue.uppercased()) (restart please)", for: .normal)
      self?.envButton.setTitleColor(UIColor.red, for: .normal)
      dummy.resignFirstResponder()
    }
  }
  
  // MARK: - UIPickerViewDataSource, UIPickerViewDelegate
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return  envConfigurator.getEnviromentList().count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    let env = EnvironmetConfigurator.shared.getEnviromentList()[row]
    
    return env.rawValue
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    let env = envConfigurator.getEnviromentList()[row]
    
    envConfigurator.setEnvironment(env: env)
    
    (pickerView as? EnvPickerView)?.didSelectEnvironment?(env)
  }
}
