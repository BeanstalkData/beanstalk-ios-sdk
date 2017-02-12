//
//  MenuViewController.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import UIKit
import BeanstalkEngageiOSSDK

class MenuViewController: UIViewController, CoreProtocol {
    @IBOutlet var registerButton: UIButton!
    @IBOutlet var signInButton: UIButton!
    @IBOutlet var signOutButton: UIButton!
    @IBOutlet var profileButton: UIButton!
    @IBOutlet var availableRewardsButton: UIButton!
    @IBOutlet var userProgressButton: UIButton!
    @IBOutlet var giftCardsButton: UIButton!
    
    
    let coreService = CoreService(apiKey: "1234-4321-ABCD-DCBA", session: BESession())
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      coreService.register(ContactModel.self)
      
        self.updateAuthStatus()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if let vc = segue.destinationViewController as? BaseViewController {
            vc.coreService = self.coreService
        }
        
        if let vc = segue.destinationViewController as? RegisterViewController {
            vc.completionBlock = { (success) in
                if success {
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
                
                self.updateAuthStatus()
            }
        }
        else if let vc = segue.destinationViewController as? SignInViewController {
            vc.completionBlock = { (success) in
                if success {
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
                
                self.updateAuthStatus()
            }
        }
    }
    
    
    //MARK: - Actions
    
    @IBAction func signOutAction() {
        let alert = UIAlertController(title: "Sign Out",
                                      message: "Would you like to Sign Out?",
                                      preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .Default, handler: { (_) in
            self.coreService.logout(self, handler: { (success) in
                self.updateAuthStatus()
            })
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Private
    
    private func updateAuthStatus() {
        let isAuthenticated = self.coreService.isAuthenticated()
        
        self.registerButton.enabled = !isAuthenticated
        self.signInButton.enabled = !isAuthenticated
        self.signOutButton.enabled = isAuthenticated
        self.profileButton.enabled = isAuthenticated
        self.availableRewardsButton.enabled = isAuthenticated
        self.userProgressButton.enabled = isAuthenticated
        self.giftCardsButton.enabled = isAuthenticated
    }
}
