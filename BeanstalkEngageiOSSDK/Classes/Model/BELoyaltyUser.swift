//
//  BELoyaltyUser.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/13/17.
//
//

import Foundation

import ObjectMapper

public class BELoyaltyUser : Mappable {
  public var contactId: String?
  public var sessionToken: String?
  public var giftCardNumber : String?
  public var giftCardPin : String?
  public var giftCardRegistrationStatus : Bool?
  public var giftCardTrack2 : String?
  
  required public init?(_ map: Map) {
    
  }
  
  public func mapping(map: Map) {
    contactId <- map["contactId"]
    sessionToken <- map["sessionToken"]
    giftCardNumber <- map["giftCardNumber"]
    giftCardPin <- map["giftCardPin"]
    giftCardRegistrationStatus <- map["giftCardRegistrationStatus"]
    giftCardTrack2 <- map["giftCardTrack2"]
  }
}
