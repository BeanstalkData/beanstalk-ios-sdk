//
//  BELoyaltyUser.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation

import ObjectMapper

open class BELoyaltyUser : Mappable {
  open var contactId: String?
  open var sessionToken: String?
  open var giftCardNumber : String?
  open var giftCardPin : String?
  open var giftCardRegistrationStatus : Bool?
  open var giftCardTrack2 : String?
  
  required public init?(map: Map) {
    
  }
  
  open func mapping(map: Map) {
    contactId <- map["contactId"]
    sessionToken <- map["sessionToken"]
    giftCardNumber <- map["giftCardNumber"]
    giftCardPin <- map["giftCardPin"]
    giftCardRegistrationStatus <- map["giftCardRegistrationStatus"]
    giftCardTrack2 <- map["giftCardTrack2"]
  }
}
