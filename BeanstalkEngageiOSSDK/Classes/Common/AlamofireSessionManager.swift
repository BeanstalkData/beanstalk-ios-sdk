//
//  AlamofireSessionManager.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyRSA

let beanstalkPoint = "proc.beanstalkdata.com"

open class HTTPAlamofireManager: Alamofire.SessionManager  {
  
  static internal let sessionManager: SessionManager = {
    let configuration = defaultSessionConfiguration()
    configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
    
    let delegate: SessionDelegate = SessionDelegate()
    delegate.dataTaskWillCacheResponseWithCompletion = { (session, dataTask, proposedResponse, completionHandler) -> Void in
      completionHandler(nil)
    }
    
    return SessionManager(configuration: configuration,
                          delegate: delegate,
                          serverTrustPolicyManager: getServerTrustPolicyManager())
  }()
  
  open class func getSharedInstance() -> Alamofire.SessionManager {
    return sessionManager
  }
  
  open class func defaultSessionConfiguration() -> URLSessionConfiguration {
    return URLSessionConfiguration.default
  }
}

open class HTTPTimberjackManager: HTTPAlamofireManager {
  static internal let shared: Alamofire.SessionManager = {
    let configuration = HTTPTimberjackManager.defaultSessionConfiguration()
    
    let delegate: SessionDelegate = SessionDelegate()
    delegate.dataTaskWillCacheResponseWithCompletion = { (session, dataTask, proposedResponse, completionHandler) -> Void in
      completionHandler(nil)
    }
    
    let manager = HTTPTimberjackManager(configuration: configuration, delegate: delegate)
    return manager
  }()
  
  open override class func getSharedInstance() -> Alamofire.SessionManager {
    return shared
  }
  
  open override class func defaultSessionConfiguration() -> URLSessionConfiguration {
    return Timberjack.defaultSessionConfiguration()
  }
}

private func getServerTrustPolicyManager() -> ServerTrustPolicyManager? {
  let frameworkBundle = Bundle(for: BeanstalkEngageiOSSDKClass.self)
  
  guard let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("BeanstalkEngageiOSSDK.bundle"),
    let resourceBundle = Bundle(url: bundleURL) else {
      return nil
  }
  
  let publicKeys = ServerTrustPolicy.publicKeys(in: resourceBundle)
  
  let trustPolicy = ServerTrustPolicy.pinPublicKeys(
    publicKeys: publicKeys,
    validateCertificateChain: true,
    validateHost: true)
  
  return ServerTrustPolicyManager(policies: [beanstalkPoint: trustPolicy])
}

class BeanstalkEngageiOSSDKClass {}
