//
//  PushNotificationResponse.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

/**
 Response model for push notifications request.
 */
open class PushNotificationResponse : Mappable {
 
  fileprivate var status100 : AnyObject?
  fileprivate var status : AnyObject?
  fileprivate var messages : [BEPushNotificationMessage]?
  fileprivate var success : Bool?
  
  required public init?(map: Map) {
    
  }
  
  open func mapping(map: Map) {
    status100 <- map["error"]
    status <- map["error100"]
    success <- map["success"]
  }
  
  open func failed() -> Bool{
    if let success = self.success {
      if success {
        return false
      }
    }
    
    if (status != nil || status100 != nil) {
      return true
    }
    
    return false
  }
  
  open func getMessages() -> [BEPushNotificationMessage]? {
    return messages
  }
}
