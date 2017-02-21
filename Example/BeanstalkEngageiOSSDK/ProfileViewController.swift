//
//  ProfileViewController.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import UIKit
import BeanstalkEngageiOSSDK


class ProfileViewController: BaseViewController, CoreProtocol, EditProfileProtocol {
  var contact: ContactModel?
  var updateContactRequest: UpdateContactRequest?
  
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var emailLabel: UILabel!
  @IBOutlet var genderSegment: UISegmentedControl!
  
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    if self.contact == nil {
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
    let updateRequest = UpdateContactRequest(contact: self.contact)
    
    self.updateContactRequest = updateRequest
    
    self.nameLabel.text = self.contact?.getFullName()
    self.emailLabel.text = updateRequest.email
    
    if self.updateContactRequest?.gender == "Male" {
      self.genderSegment.selectedSegmentIndex = 0
    }
    else if self.updateContactRequest?.gender == "Female" {
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
      self.updateContactRequest?.gender = "Male"
    case 1:
      self.updateContactRequest?.gender = "Female"
    default:
      self.updateContactRequest?.gender = "Unknown"
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
