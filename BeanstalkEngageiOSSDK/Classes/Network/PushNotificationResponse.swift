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


/*
 {
    "messages":{
       "56bb8110a7c8761839ce28c0":{
          "_id":{
             "__className":"MongoId",
             "$id":"56bb8110a7c8761839ce28c0"
          },
          "CustomerId":"258",
          "CampaignId":"12345",
          "StepId":"1233553",
          "ContactId":"12344454",
          "DateSent":"2014-05-08T18:51:12.840Z",
          "Status":"READ",
          "StatusLastUpdated":"2014-06-08T18:51:12.840Z",
          "Category":"Offer",
          "notification":[
             {
                "OS":"iOS",
                "Type":"Standard",
                "Title":"Free Tacos this week.",
                "TitleImage":"https:\/\/placeholdit.imgix.net\/~text?txtsize=33&txt=tacos&w=150&h=150",
                "Image":"https:\/\/placeholdit.imgix.net\/~text?txtsize=33&txt=Tacos&w=250&h=150",
                "Image_Type":"SMALL_ICON",
                "body":"Formated text about this offer.",
                "AppHook":"someAppMethod()"
             },
             {
                "OS":"Android",
                "Type":"HTML",
                "Title":"Free Tacos this week.",
                "TitleImage":"https:\/\/placeholdit.imgix.net\/~text?txtsize=33&txt=tacos&w=150&h=150",
                "Image_Type":"LARGE",
                "Content":"https:\/\/linktoCDN",
                "AppHook":"someAppMethod()"
             }
          ]
       }
    }
 }
 */
