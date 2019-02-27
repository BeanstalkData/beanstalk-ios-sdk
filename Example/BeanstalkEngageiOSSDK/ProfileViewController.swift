//
//  ProfileViewController.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import UIKit
import BeanstalkEngageiOSSDK


class ProfileViewController: BaseViewController {
  var contact: ContactModel?
  var updateContactRequest: ContactRequest?
  
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var emailLabel: UILabel!
  @IBOutlet weak var birthdayLabel: UILabel!
  @IBOutlet var genderSegment: UISegmentedControl!
  @IBOutlet var pushNotificationsSwitch: UISwitch!
  @IBOutlet weak var phoneLabel: UILabel!
  
  var pushNotificationEnrollment: PushNotificationEnrollmentController?
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.pushNotificationEnrollment = AppDelegate.pushNotificationsEnrollment()
  }
  
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
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    if let vc = segue.destination as? BaseViewController {
      vc.coreService = self.coreService
    }
    if let vc = segue.destination as? PushNotificationMessagesTableViewController {
      vc.coreService = self.coreService
      
      if let contactId = self.contact?.contactId {
        vc.contactId = String(contactId)
      }
    }
  }
  
  //MARK: - Private
  
  func loadProfile() {
    self.loadingHandler.showProgress("Retrieving Profile")
    self.coreService?.getMyContact(handler: { (success, contact, error) in
      self.loadingHandler.handleError(success: success, error: error)
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
    self.phoneLabel.text = contact?.phone
    self.birthdayLabel.text = contact?.birthday
    
    if self.updateContactRequest?.getGender() == "Male" {
      self.genderSegment.selectedSegmentIndex = 0
    }
    else if self.updateContactRequest?.getGender() == "Female" {
      self.genderSegment.selectedSegmentIndex = 1
    }
    else {
      self.genderSegment.selectedSegmentIndex = 2
    }
    
    self.pushNotificationsSwitch.isEnabled = self.pushNotificationEnrollment != nil
    
    guard let pushEnrollment = self.pushNotificationEnrollment else {
      return
    }
    
    var pushEnabled = false
    let deviceRegistered = pushEnrollment.isRegisteredForPushNotifications()
    
    if let pushOn = self.updateContactRequest?.isPushNotificationOptin() {
      if let inboxOn = self.updateContactRequest?.isInboxMessageOptin() {
        pushEnabled = pushOn && inboxOn && deviceRegistered
      }
    }
    self.pushNotificationsSwitch.isOn = pushEnabled
  }
  
  private func showPushNotificationsError(error: BEErrorType) {
    self.loadingHandler.showMessage("Push Notifications Error", message: error.errorMessage())
    
    self.loadProfile()
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
  
  @IBAction func pushNotificationsAction() {
    weak var weakSelft = self
    
    guard let pushEnrollment = weakSelft?.pushNotificationEnrollment else {
      return
    }
    
    if self.pushNotificationsSwitch.isOn {
      // turn ON
      
      let sendToken = {
        pushEnrollment.sendDeviceTokenAndUpdateContact({ (error) in
          if let err = error {
            weakSelft?.showPushNotificationsError(error: err)
          }
          else {
            weakSelft?.loadingHandler.showMessage("Push Notifications Enabled", message: nil)
            weakSelft?.loadProfile()
          }
        })
      }
      
      if pushEnrollment.isRegisteredForPushNotifications() { // already granted
        if pushEnrollment.isDeviceTokenRequested() {
          // send token
          
          sendToken()
        }
        else {
          // request token
          
          pushEnrollment.requestPushNotificationPermissions({ (isGranted, error) -> (Void) in
            if isGranted {
              sendToken()
            }
            else {
              weakSelft?.showPushNotificationsError(error: ApiError.updateProfileError(reason: "Failed to enable push notifications"))
            }
          })
        }
      }
      else { // not granted yet or denied
        pushEnrollment.requestPushNotificationPermissions({ (isGranted, error) -> (Void) in
          if isGranted {
            sendToken()
          }
          else {
            weakSelft?.showPushNotificationsError(error: ApiError.updateProfileError(reason: "Failed to enable push notifications"))
          }
        })
      }
    }
    else {
      // turn OFF
      
      pushEnrollment.unregisterForPushNotification({ (error) in
        weakSelft?.loadProfile()
      })
    }
  }
  
  @IBAction func saveContactAction() {
    guard let request = self.updateContactRequest else {
      return
    }
    
    weak var weakSelf = self
    self.loadingHandler.showProgress("Updating Profile")
    self.coreService?.updateContact(
      request: request,
      contactClass: ContactModel.self,
      fetchContact: true,
      handler: { (success, fetchedContact, error) in
        weakSelf?.loadingHandler.handleError(success: success, error: error)
        
        if success {
          if let contact = fetchedContact {
            weakSelf?.contact = contact
            
            weakSelf?.updateProfile()
          } else {
            weakSelf?.loadProfile()
          }
        }
    })
  }
}
