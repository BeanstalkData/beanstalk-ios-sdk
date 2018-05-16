//
//  AlamofireSessionManager.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyRSA

let serverPublicKey = """
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsuDZEQbwq5HIPgEsWqkS
cu1ad1SvF0qox9sNs4IBSheij3wR7Zh3q2KIdYkf+g59qsQ/JoA1bzJV+UuGhAWD
P/VfQr2kpD7kuab5aKKmETUsE78+NgsWT1Ra1Jf9eSDGpVBk6tJpNAvt6B10AwIm
NrfVDctFDA8vSRSsCvbOlxciHXKw+VZTx1BCL5zD1rXzWAFxHxmfSh1xGV0aA+Bd
rnBh2vX//5sunw5SVsD60Zy66AGAKKU4LKAg22NkS3WTSk7/+cYwhlD8CXTgC0u+
PVDcRV4ihsS64beN05bkcyIvfq7Hys6Xv/x03UO10k0snjuU2KyLAlJSFaj4GLIM
hwIDAQAB
-----END PUBLIC KEY-----
"""

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
  
  static internal func getServerTrustPolicyManager() -> ServerTrustPolicyManager {
    let publicKey = try? PublicKey(pemEncoded: serverPublicKey)
    var publicKeys = [SecKey]()
    if let key = publicKey?.reference {
      publicKeys.append(key)
    }
    
    let trustPolicy = ServerTrustPolicy.pinPublicKeys(
      publicKeys: publicKeys,
      validateCertificateChain: true,
      validateHost: true)
    
    return ServerTrustPolicyManager(policies: [beanstalkPoint : trustPolicy])
  }
  
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

