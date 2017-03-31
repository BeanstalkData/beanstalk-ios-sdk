//
//  ServerErrorResponse.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import ObjectMapper


open class ServerErrorResponse: Mappable {
  var codeValue: Int?
  var messageValue: String?
  
  
  required public init?(map: Map) {
    
  }
  
  public func mapping(map: Map) {
    codeValue <- map["code"]
    messageValue <- map["message"]
  }
}
