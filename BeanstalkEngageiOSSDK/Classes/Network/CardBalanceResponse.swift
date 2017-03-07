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


open class GCBResponse: Mappable, GiftCardBalanceResponse {
  fileprivate var status: Bool?
  
  fileprivate var response: GCBDataResponse?
  
  required public init?(map: Map) {
    
  }
  
  open func mapping(map: Map) {
    status <- map["status"]
    response <- map["success"]
  }
  
  
  open func getCardBalance() -> String {
    guard let amount = response?.message?.response?.cardBalance?.balanceAmount?.amount else {
      return BEGiftCard.kDefaultBalance
    }
    
    return String(format : "$%.2f", amount)
  }
}


open class GCBDataResponse: Mappable {
  var code: Int?
  var message: GCBDataMessage?
  
  required public init?(map: Map) {
    
  }
  
  open func mapping(map: Map) {
    code <- map["code"]
    message <- map["message"]
  }
}


open class GCBDataMessage: Mappable {
  var response: GCBMResponse?
  
  required public init?(map: Map) {
    
  }
  
  open func mapping(map: Map) {
    response <- map["response"]
  }
}


open class GCBMResponse: Mappable {
  var message: String?
  var cardBalance: BEGiftCardBalance?
  
  required public init?(map: Map) {
    
  }
  
  open func mapping(map: Map) {
    message <- map["message"]
    cardBalance <- map["balanceInquiryReturn"]
  }
}

