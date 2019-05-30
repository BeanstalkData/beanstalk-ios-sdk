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
  private let socialNetworksClient = SocialNetworksClient.sharedInstance
  
  var window: UIWindow?
  
  lazy var coreService = getApiService()
  var pushNotificationEnrollment: PushNotificationEnrollmentController?
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    if let session = self.coreService.getSession() {
      self.pushNotificationEnrollment = PushNotificationEnrollmentController(beanstalkCoreService: self.coreService, session: session)
    }
    
    // application handles remote push notification when it was terminated
    if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable : Any] {
      // is this case application should redirect to required screen silently
      self.pushNotificationEnrollment?.application(application, didReceiveRemoteNotification: remoteNotification)
    }
    
    GIDSignIn.sharedInstance().clientID = "938888404219-q3uklfftme7t0hdpu8gs1sij2duu001q.apps.googleusercontent.com"
    GIDSignIn.sharedInstance().delegate = socialNetworksClient
    
    return true
  }
  
  open func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
    
    return GIDSignIn.sharedInstance().handle(url,
                                             sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                             annotation: options[UIApplicationOpenURLOptionsKey.annotation])
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
  
  
  //MARK: -
  
  private func getApiService() -> ApiService {
    let configurator = EnvironmetConfigurator.shared
    let env = configurator.getCurrentEnv()
    print(env)
    let configuration = configurator.getConfiguration(env: env)
    
    let apiSrvice = ApiService(apiKey: configuration.getApiKey(),
                               session: BESession(),
                               apiUsername: nil,
                               beanstalkUrl: configuration.getBaseUrl())
    
    return apiSrvice
  }  
}
