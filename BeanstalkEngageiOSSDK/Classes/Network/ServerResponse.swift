//
//  ServerResponse.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import ObjectMapper


/**
 Response model for typical server response. Contains server error response model if received.
 */
open class ServerResponse: Mappable {
  var statusValue: Any?
  var errorValue: ServerErrorResponse?
  
  
  required public init?(map: Map) {
    
  }
  
  public func mapping(map: Map) {
    statusValue <- map["status"]
    errorValue <- map["error"]
  }
  
  
  //MARK: - Public
  
  public func isSuccess() -> Bool {
    if let status = self.statusValue as? Bool {
      return status
    }
    
    if let status = self.statusValue as? String {
      return status == "success"
    }
    
    return false
  }
}
