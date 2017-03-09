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
  let session: BESession
  
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
  
  var pushNotificationInfo: Dictionary<NSObject, AnyObject>?
  
  
  init(beanstalkCoreService: ApiService, session: BESession) {
    self.coreService = beanstalkCoreService
    self.session = session
    
    super.init()
    
    if #available(iOS 10, *) {
      let center = UNUserNotificationCenter.current()
      center.delegate = self
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
  
  func unregisterForPushNotification(_ completionHandler: @escaping (_ error: ApiError?) -> Void) {
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
  
  func sendDeviceToken(_ completionHandler: @escaping (_ error: ApiError?) -> Void) {
    if !self.isDeviceTokenRequested() || !self.coreService.isAuthenticated() {
      return
    }
    
    let tokenString = self.deviceToken!
    
    self.coreService.pushNotificationEnroll(tokenString, handler: { (success, error) in
      completionHandler(error)
    })
  }
  
  func updateContactForPushNotifications(_ completionHandler: @escaping (_ success: Bool) -> Void) {
    self.coreService.getMyContact(nil, handler: { (contact) in
      if let cont = contact {
        let updateRequest = ContactRequest(origin: cont)
        
        updateRequest.set(pushNotificationOptin: true)
        updateRequest.set(inboxMessageOptin: true)
        
        let validator = ProfileUpdateValidator()
        
        self.coreService.updateContact(
          validator,
          original: cont,
          request: updateRequest,
          handler: { (success) in
            completionHandler(success)
          }
        )
      }
      else {
        completionHandler(false)
      }
    })
  }
  
  func sendDeviceTokenAndUpdateContact(_ completionHandler: @escaping (_ success: Bool) -> Void) {
    self.sendDeviceToken { (error) in
      if let _ = error {
        completionHandler(false)
      }
      else {
        self.updateContactForPushNotifications({ (success) in
          completionHandler(success)
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
  
  
  //MARK: - UIApplicationDleegate methods
  
  func applicationDidBecomeActive() {
    if self.pushNotificationInfo != nil {
      // opened from a push notification when the app was on background
      self.handlePushNotification(self.pushNotificationInfo!)
      self.pushNotificationInfo = nil
    }
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
    switch application.applicationState {
    case .active:
      self.handlePushNotification(userInfo as Dictionary<NSObject, AnyObject>)
      break
    default:
      self.pushNotificationInfo = userInfo as Dictionary<NSObject, AnyObject>?
      
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
        if UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL) {
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
  
  fileprivate func handlePushNotification(_ pushNotificationInfo: Dictionary<NSObject, AnyObject>) {
    // TODO: Handle remote notification
    
    NSLog("handlePushNotification: \(pushNotificationInfo)")
  }
}


extension PushNotificationEnrollmentController: UNUserNotificationCenterDelegate {
  @available(iOS 10, *)
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
  {
    completionHandler(.alert)
  }
  
  @available(iOS 10, *)
  func userNotificationCenter(
    _ center: UNUserNotificationCenter, didReceive
    response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
    ) {
    
  }
}
