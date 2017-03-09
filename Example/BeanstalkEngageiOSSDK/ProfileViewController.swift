//
//  ProfileViewController.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import UIKit
import BeanstalkEngageiOSSDK


class ProfileViewController: BaseViewController, CoreProtocol, EditProfileProtocol {
  var contact: ContactModel?
  var updateContactRequest: ContactRequest?
  
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var emailLabel: UILabel!
  @IBOutlet var genderSegment: UISegmentedControl!
  
  
  override func viewDidAppear(_ animated: Bool) {
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
    self.coreService?.getMyContact(self, handler: { (contact) in
      if contact != nil {
        self.contact = contact as? ContactModel
        
        self.updateProfile()
      }
    })
  }
  
  func updateProfile() {
    let updateRequest = ContactRequest(origin: self.contact)
    
    self.updateContactRequest = updateRequest
    
    self.nameLabel.text = self.contact?.getFullName()
    self.emailLabel.text = updateRequest.getEmail()
    
    if self.contact?.gender == "Male" {
      self.genderSegment.selectedSegmentIndex = 0
    }
    else if self.contact?.gender == "Female" {
      self.genderSegment.selectedSegmentIndex = 1
    }
    else {
      self.genderSegment.selectedSegmentIndex = 2
    }
  }
  
  
  //MARK: - Actions
  
  @IBAction func genderAction() {
    switch self.genderSegment.selectedSegmentIndex {
    case 0:
      self.updateContactRequest?.set(gender: "Male")
    case 1:
      self.updateContactRequest?.set(gender: "Female")
    default:
      self.updateContactRequest?.set(gender: "Unknown")
    }
  }
  
  @IBAction func saveContactAction() {
    if let cont = self.contact {
      if let upd = self.updateContactRequest {
        self.coreService?.updateContact(self, original: cont, request: upd, handler: { (success) in
          if success {
            self.loadProfile()
          }
        })
      }
    }
  }
}
