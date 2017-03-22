//
//  PushNotificationResponse.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import ObjectMapper


public enum PushNotificationStatus: String {
  case read = "READ"
  case unread = "UNREAD"
  case deleted = "DELETED"
}


open class PushNotificationResponse : Mappable {
 
  fileprivate var status100 : AnyObject?
  fileprivate var status : AnyObject?
  fileprivate var messages : [BEPushNotificationMessage]?
  
  required public init?(map: Map) {
    
  }
  
  open func mapping(map: Map) {
    status100 <- map["error"]
    status <- map["error100"]
  }
  
  open func failed() -> Bool{
    if (status != nil || status100 != nil) {
      return true
    }
    
    return false
  }
  
  open func getMessages() -> [BEPushNotificationMessage]? {
    return messages
  }
}
