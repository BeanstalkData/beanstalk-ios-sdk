//
//  PushNotificationEnrollmentController.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import BeanstalkEngageiOSSDK
import UserNotifications


typealias PushNotificationsRequestBlock = (_ isGranted: Bool, _ error: NSError?) -> (Void)


final class PushNotificationEnrollmentController: NSObject {
  let coreService: ApiService
  let session: BESessionProtocol
  
  fileprivate var authorizationRequestedPreviously: Bool {
    set (newValue) {
      UserDefaults.standard.set(newValue, forKey: "push_authorization_requested")
    }
    
    get {
      return UserDefaults.standard.bool(forKey: "push_authorization_requested")
    }
  }
  fileprivate var systemPreferencesRequested = false
  
  fileprivate var requestHandler: PushNotificationsRequestBlock?
  
  
  fileprivate var deviceToken: String?
  
  var pushNotificationInfo: [AnyHashable : Any]?
  
  
  init(beanstalkCoreService: ApiService, session: BESessionProtocol) {
    self.coreService = beanstalkCoreService
    self.session = session
    
    super.init()
    
    if #available(iOS 10, *) {
    }
  }
  
  
  //MARK: - Public
  
  func isRegisteredForPushNotifications() -> Bool {
    return UIApplication.shared.isRegisteredForRemoteNotifications
  }
  
  func requestPushNotificationPermissions(_ handler: @escaping PushNotificationsRequestBlock) {
    self.requestHandler = handler
    
    self.requestPushNotificationPermissions(true)
  }
  
  func unregisterForPushNotification(_ completionHandler: @escaping (_ error: BEErrorType?) -> Void) {
    if self.coreService.isAuthenticated() {
      weak var weakSelf = self
      
      self.coreService.pushNotificationDelete { (success, error) in
        if success {
          weakSelf?.deviceToken = nil
          UIApplication.shared.unregisterForRemoteNotifications()
        }
        
        completionHandler(error)
      }
    }
    else {
      self.deviceToken = nil
      UIApplication.shared.unregisterForRemoteNotifications()
      completionHandler(nil)
    }
  }
  
  func isDeviceTokenRequested() -> Bool {
    return self.deviceToken != nil
  }
  
  func sendDeviceToken(_ completionHandler: @escaping (_ error: BEErrorType?) -> Void) {
    if !self.isDeviceTokenRequested() || !self.coreService.isAuthenticated() {
      return
    }
    
    let tokenString = self.deviceToken!
    
    self.coreService.pushNotificationEnroll(tokenString, handler: { (success, error) in
      completionHandler(error)
    })
  }
  
  func updateContactForPushNotifications(_ completionHandler: @escaping (_ success: Bool, _ error: BEErrorType?) -> Void) {
    weak var weakSelf = self
    
    self.coreService.getMyContact(handler: { (success, contact, error) in
      if let cont = contact {
        let updateRequest = ContactRequest(origin: cont)
        
        updateRequest.set(inboxMessageOptin: true)
        
        weakSelf?.coreService.updateContact(
          request: updateRequest,
          contactClass: ContactModel.self,
          handler: { (success, _, error) in
            completionHandler(success, error)
        })
      }
      else {
        completionHandler(false, nil)
      }
    })
  }
  
  func sendDeviceTokenAndUpdateContact(_ completionHandler: @escaping (_ error: BEErrorType?) -> Void) {
    self.sendDeviceToken { (error) in
      if let err = error {
        completionHandler(err)
      }
      else {
        self.updateContactForPushNotifications({ (success, error) in
          completionHandler(error)
        })
      }
    }
  }
  
  func applicationWillEnterForeground() {
    if self.systemPreferencesRequested {
      self.systemPreferencesRequested = false
      
      self.requestPushNotificationPermissions(false)
    }
  }
  
  func onSignIn(contact: BEContact) {
    let deviceRegistered = self.isRegisteredForPushNotifications()
    
    let contactPushOptIn = contact.pushNotificationOptin > 0
    let contactInboxOptIn = contact.inboxMessageOptin > 0
    
    if contactPushOptIn && contactInboxOptIn {
      if !deviceRegistered {
        self.requestPushNotificationPermissions({ (granted, error) -> (Void) in
          if granted {
            self.sendDeviceTokenAndUpdateContact({ (error) in
              // handle error
            })
          } else {
            // handle error
          }
        })
      }
    }
  }
  
  
  //MARK: - UIApplicationDleegate methods
  
  func applicationDidBecomeActive() {
    if self.pushNotificationInfo != nil {
      // opened from a push notification when the app was on background
      self.handlePushNotification(info: self.pushNotificationInfo!)
      self.pushNotificationInfo = nil
    }
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
    switch application.applicationState {
    case .active:
      self.handlePushNotification(info: userInfo)
      break
    default:
      self.pushNotificationInfo = userInfo
      
      break
    }
  }
  
  func didFailToRegisterForRemoteNotificationsWithError(_ error: NSError) {
    self.requestHandler?(false, error)
    
    self.requestHandler = nil
  }
  
  func didRegisterForRemoteNotificationsWithDeviceToken(_ deviceToken: Data) {
    let tokenString = deviceToken.map { String(format: "%02hhx", $0) }.joined()
    
    self.deviceToken = tokenString
    self.session.setAPNSToken(tokenString)
    
    self.requestHandler?(true, nil)
    self.requestHandler = nil
  }
  
  func didRegisterUserNotificationSettings(_ notificationSettings: UIUserNotificationSettings) {
    UIApplication.shared.registerForRemoteNotifications()
  }
  
  
  //MARK: - Private
  
  fileprivate func requestPushNotificationPermissions(_ handleNotGranted: Bool) {
    if #available(iOS 10, *) {
      let center = UNUserNotificationCenter.current()
      
      center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { (granted, error) in
        if granted {
          UIApplication.shared.registerForRemoteNotifications()
        }
        else {
          if self.authorizationRequestedPreviously && handleNotGranted {
            self.handleAuthrozationNotGranted()
          }
          else {
            self.requestHandler?(granted, error as NSError?)
            
            self.requestHandler = nil
          }
        }
        
        self.authorizationRequestedPreviously = true
      })
    }
    else {
      UIApplication.shared.registerForRemoteNotifications()
    }
  }
  
  fileprivate func handleAuthrozationNotGranted() {
    let alert = UIAlertController(
      title: "Push Notifications Disabled",
      message: "It you want to receive push notifications - enable them from system preferences",
      preferredStyle: .alert)
    
    let settingsAction = UIAlertAction(
      title: "Settings",
      style: .default,
      handler: { (_) in
        if UIApplication.shared.openURL(NSURL(string: UIApplication.openSettingsURLString)! as URL) {
          self.systemPreferencesRequested = true
        }
    })
    
    let cancelAction = UIAlertAction(
      title: "Cancel",
      style: .cancel,
      handler: { (_) in
        self.requestHandler?(false, nil)
        
        self.requestHandler = nil
    })
    
    alert.addAction(cancelAction)
    alert.addAction(settingsAction)
    
    AppDelegate.rootViewController().present(alert, animated: true, completion: nil)
  }
  
  fileprivate func handlePushNotification(info: [AnyHashable : Any]) {
    guard let aps = info["aps"] as? [AnyHashable: Any] else {
      return
    }
    
    guard let alert = aps["alert"] as? String else {
      return
    }
    
    guard let rootController = UIApplication.shared.keyWindow?.rootViewController else {
      return
    }
    
    let alertController = UIAlertController(
      title: nil,
      message: alert,
      preferredStyle: .alert
    )
    
    alertController.addAction(UIAlertAction(
      title: "Cancel",
      style: .cancel,
      handler: nil))
    
    rootController.present(alertController, animated: true, completion: nil)
  }
}


extension PushNotificationEnrollmentController: UNUserNotificationCenterDelegate {
  @available(iOS 10, *)
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
  {
    completionHandler([.badge, .alert, .sound])
  }
  
  @available(iOS 10, *)
  func userNotificationCenter(
    _ center: UNUserNotificationCenter, didReceive
    response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
    ) {
    
  }
}
