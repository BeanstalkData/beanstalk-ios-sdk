//
//  ContactManagementViewController.swift
//  BeanstalkEngageiOSSDK
//
//  Created by Dmytro Nadtochyy on 3/30/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import BeanstalkEngageiOSSDK


class ContactManagementViewController: BaseViewController {
  @IBOutlet var contactIdLabel: UILabel!
  @IBOutlet var createContactButton: UIButton!
  @IBOutlet var deleteContactButton: UIButton!
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let contact = self.coreService?.getSession()?.getContact()
    self.setupFor(contact: contact)
  }
  
  
  //MARK: - Actions
  
  @IBAction func onCreateContactAction() {
    let request = ContactRequest()
    
    weak var weakSelf = self
    self.loadingHandler.showProgress("Creating Empty Contact")
    self.coreService?.createContact(
      request,
      contactClass: BEContact.self,
      fetchContact: true,
      handler: { (success, contactId, contact, error) in
        weakSelf?.loadingHandler.handleError(success: success, error: error)
        
        weakSelf?.setupFor(contact: contact)
    })
  }
  
  @IBAction func onDeleteContactAction() {
    guard let contactId = self.coreService?.getSession()?.getContactId() else {
      return
    }
    
    weak var weakSelf = self
    self.loadingHandler.showProgress("Deleting Current Contact")
    self.coreService?.deleteContact(
      contactId: contactId,
      handler: { (success, error) in
        weakSelf?.loadingHandler.handleError(success: success, error: error)
        
        let contact = weakSelf?.coreService?.getSession()?.getContact()
        weakSelf?.setupFor(contact: contact)
    })
  }
  
  
  //MARK: - Private
  
  private func setupFor(contact: BEContact?) {
    if let contactId = contact?.contactId {
      self.contactIdLabel.text = "Contact ID: \(contactId)"
    }
    else {
      self.contactIdLabel.text = "No contact in session"
    }
    
    self.createContactButton.isEnabled = contact == nil
    self.deleteContactButton.isEnabled = contact != nil
  }
}
