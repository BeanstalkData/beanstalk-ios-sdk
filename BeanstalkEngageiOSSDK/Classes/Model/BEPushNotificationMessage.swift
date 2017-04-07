//
//  BEPushNotificationMessage.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

/**
 Model of push notification message.
 */
open class BEPushNotificationMessage: Mappable {
  
  open var messageIdInfo: [String: Any]?
  open var messageId: String?
  open var contactId: String?
  open var title: String?
  open var subtitle: String?
  open var status: String?
  open var appHook: String?
  open var msgImage: String?
  open var category: String?
  open var campaignId: String?
  open var customerId: String?
  open var msgType: String?
  open var updatedAtInfo: [String: Any]?
  open var updatedAt: Int?
  open var stepId: String?
  open var inboxTitle: String?
  open var messageBody: String?
  open var thumbnailUrl: String?
  open var messageUrl: String?
  
  
  required public init?(map: Map) {
    
  }
  
  open func mapping(map: Map) {
    messageIdInfo <- map["_id"]
    contactId <- map["ContactId"]
    title <- map["title"]
    subtitle <- map["subtitle"]
    status <- map["status"]
    appHook <- map["AppHook"]
    msgImage <- map["MsgImage"]
    category <- map["Category"]
    campaignId <- map["CampaignId"]
    customerId <- map["CustomerId"]
    msgType <- map["MsgType"]
    updatedAtInfo <- map["updated_at"]
    stepId <- map["StepId"]
    inboxTitle <- map["inboxTitle"]
    messageBody <- map["MessageBody"]
    thumbnailUrl <- map["thumbnailUrl"]
    messageUrl <- map["messageUrl"]
    
    messageId = messageIdInfo?["$id"] as? String
    updatedAt = updatedAtInfo?["sec"] as? Int
  }
  
  open func updatedDate() -> Date? {
    guard let updatedStr = self.updatedAt else {
      return nil
    }
    
    let updatedSec = TimeInterval(Double(updatedStr))
    
    let date = Date(timeIntervalSince1970: updatedSec)
    
    return date
  }
  
  open func getStatus() -> PushNotificationStatus? {
    guard let statusStr = self.status else {
      return nil
    }
    
    let status = PushNotificationStatus(rawValue: statusStr)
    
    return status
  }
}

/**
 Push notification message status enum.
 */
public enum PushNotificationStatus: String {
  /// Status READ
  case read = "READ"
  /// Status UNREAD
  case unread = "UNREAD"
  /// Status DELETED
  case deleted = "DELETED"
}
