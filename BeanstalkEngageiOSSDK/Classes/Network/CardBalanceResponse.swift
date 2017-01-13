//
//  CardBalanceResponse.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import ObjectMapper


public protocol GiftCardBalanceResponse {
  func getCardBalance() -> String
}


public class GCBResponse: Mappable, GiftCardBalanceResponse {
  private var status: Bool?
  
  private var response: GCBDataResponse?
  
  required public init?(_ map: Map) {
    
  }
  
  public func mapping(map: Map) {
    status <- map["status"]
    response <- map["success"]
  }
  
  
  public func getCardBalance() -> String {
    guard let amount = response?.message?.response?.cardBalance?.balanceAmount?.amount else {
      return BEGiftCard.kDefaultBalance
    }
    
    return String(format : "$%.2f", amount)
  }
}


public class GCBDataResponse: Mappable {
  var code: Int?
  var message: GCBDataMessage?
  
  required public init?(_ map: Map) {
    
  }
  
  public func mapping(map: Map) {
    code <- map["code"]
    message <- map["message"]
  }
}


public class GCBDataMessage: Mappable {
  var response: GCBMResponse?
  
  required public init?(_ map: Map) {
    
  }
  
  public func mapping(map: Map) {
    response <- map["response"]
  }
}


public class GCBMResponse: Mappable {
  var message: String?
  var cardBalance: BEGiftCardBalance?
  
  required public init?(_ map: Map) {
    
  }
  
  public func mapping(map: Map) {
    message <- map["message"]
    cardBalance <- map["balanceInquiryReturn"]
  }
}

