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
  @IBOutlet var pushNotificationsSwitch: UISwitch!
  
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
    
    if self.updateContactRequest?.getGender() == "Male" {
      self.genderSegment.selectedSegmentIndex = 0
    }
    else if self.updateContactRequest?.getGender() == "Female" {
      self.genderSegment.selectedSegmentIndex = 1
    }
    else {
      self.genderSegment.selectedSegmentIndex = 2
    }
    
    var pushEnabled = false
    
    if let pushOn = self.updateContactRequest?.isPushNotificationOptin() {
      if let inboxOn = self.updateContactRequest?.isInboxMessageOptin() {
        pushEnabled = pushOn && inboxOn
      }
    }
    self.pushNotificationsSwitch.isOn = pushEnabled
    
    self.pushNotificationsSwitch.isEnabled = self.pushNotificationEnrollment != nil
  }
  
  private func showPushNotificationsError(error: ApiError) {
    self.showMessage("Push Notifications Error", message: error.errorMessage())
    
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
        pushEnrollment.sendDeviceTokenAndUpdateContact({ (success) in
          if success {
            weakSelft?.showMessage("Push Notifications Enabled", message: nil)
            weakSelft?.loadProfile()
          }
          else {
            weakSelft?.showPushNotificationsError(error: ApiError.updateProfileError(reason: "Failed to enable push notifications"))
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
