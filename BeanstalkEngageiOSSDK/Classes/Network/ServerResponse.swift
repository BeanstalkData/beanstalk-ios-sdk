//
//  ServerResponse.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import ObjectMapper


open class ServerResponse: Mappable {
  var statusValue: String?
  var errorValue: ServerErrorResponse?
  
  
  required public init?(map: Map) {
    
  }
  
  public func mapping(map: Map) {
    statusValue <- map["status"]
    errorValue <- map["error"]
  }
  
  
  //MARK: - Public
  
  public func isSuccess() -> Bool {
    return self.statusValue == Optional("success")
  }
}
