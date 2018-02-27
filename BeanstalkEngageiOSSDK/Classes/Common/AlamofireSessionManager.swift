//
//  AlamofireSessionManager.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import Alamofire

open class HTTPAlamofireManager: Alamofire.SessionManager  {
  
  static internal let sessionManager: SessionManager = {
    let configuration = defaultSessionConfiguration()
    configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
    
    let delegate: SessionDelegate = SessionDelegate()
    delegate.dataTaskWillCacheResponseWithCompletion = { (session, dataTask, proposedResponse, completionHandler) -> Void in
      completionHandler(nil)
    }
    
    return SessionManager(configuration: configuration, delegate: delegate)
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
    configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
    
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

