//
//  CoreExtensions.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import Alamofire

open class HTTPAlamofireManager: Alamofire.SessionManager {
  open class func getSharedInstance() -> Alamofire.SessionManager {
    return Alamofire.SessionManager.default
  }
  
  open class func defaultSessionConfiguration() -> URLSessionConfiguration {
    return URLSessionConfiguration.default
  }
}

open class HTTPTimberjackManager: HTTPAlamofireManager {
  static internal let shared: Alamofire.SessionManager = {
    let configuration = HTTPTimberjackManager.defaultSessionConfiguration()
    let manager = HTTPTimberjackManager(configuration: configuration)
    return manager
  }()
  
  open override class func getSharedInstance() -> Alamofire.SessionManager {
    return shared
  }
  
  open override class func defaultSessionConfiguration() -> URLSessionConfiguration {
    return Timberjack.defaultSessionConfiguration()
  }
}

