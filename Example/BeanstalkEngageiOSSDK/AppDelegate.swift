//
//  AppDelegate.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import UIKit
import BeanstalkEngageiOSSDK


public enum PushNotificationsKeys: String {
  case DidReceiveToken = "DidReceiveToken"
  case TokenKey = "token" // userInfo key
  
  case FailToRegister = "FailToRegister"
  case ErrorKey = "error" // userInfo key
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  let coreService = ApiService(apiKey: "1234-4321-ABCD-DCBA", session: BESession())
  
  var pushNotificationEnrollment: PushNotificationEnrollmentController?
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    if let session = self.coreService.getSession() {
      self.pushNotificationEnrollment = PushNotificationEnrollmentController(beanstalkCoreService: self.coreService, session: session)
    }
    
    return true
  }
  
  class func apiService() -> ApiService {
    return (UIApplication.shared.delegate as! AppDelegate).coreService
  }
  
  class func pushNotificationsEnrollment() -> PushNotificationEnrollmentController? {
    return (UIApplication.shared.delegate as! AppDelegate).pushNotificationEnrollment
  }
  
  class func rootViewController() -> UIViewController {
    return UIApplication.shared.delegate!.window!!.rootViewController!
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
    self.pushNotificationEnrollment?.application(application, didReceiveRemoteNotification: userInfo)
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    self.pushNotificationEnrollment?.applicationDidBecomeActive()
  }
  
  
  // MARK: - 
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    self.pushNotificationEnrollment?.applicationWillEnterForeground()
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    self.pushNotificationEnrollment?.didFailToRegisterForRemoteNotificationsWithError(error as NSError)
  }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    self.pushNotificationEnrollment?.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
  }
  
  func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
    self.pushNotificationEnrollment?.didRegisterUserNotificationSettings(notificationSettings)
  }
}
