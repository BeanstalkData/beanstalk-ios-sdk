//
//  ProfileViewController.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import UIKit
import BeanstalkEngageiOSSDK


class ProfileViewController: BaseViewController, CoreProtocol {
  var contact: ContactModel?
  
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var emailLabel: UILabel!
  
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    if self.contact == nil {
      self.contact = self.coreService?.getSession()?.getContact()
      self.updateProfile()
      
      self.loadProfile()
    }
    else {
      self.updateProfile()
    }
  }
  
  //MARK: - Private
  
  func loadProfile() {
    self.coreService?.getContact(self, handler: { (contact) in
      if contact != nil {
        self.contact = contact as? ContactModel
        
        self.updateProfile()
      }
    })
  }
  
  func updateProfile() {
    self.nameLabel.text = self.contact?.getFullName()
    self.emailLabel.text = self.contact?.email
  }
}
