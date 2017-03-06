//
//  GiftCardsResponse.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public protocol GiftCardsResponse {
  func failed() -> Bool
  
  func getCards() -> [BEGiftCard]?
  
}

open class GCResponse <GiftCardClass: BEGiftCard> : Mappable, GiftCardsResponse {
  fileprivate var status : Bool?
  
  fileprivate var response : GCDataResponse<GiftCardClass>?
  
  required public init?(map: Map) {
    self.mapping(map: map)
  }
  
  open func mapping(map: Map) {
    status <- map["status"]
    response <- map["success"]
  }
  
  open func failed() -> Bool{
    if status == nil || !(status!) {
      return true
    }
    if response == nil || response?.message == nil || response?.message?.response == nil {
      return true
    }
    
    let result  = response!.message!.response!
    if result.success == nil || !result.success! {
      return true
    }
    return false
  }
  
  open func getCards() -> [BEGiftCard]?{
    return response?.message?.response?.cards
  }
}

open class GCDataResponse <GiftCardClass: BEGiftCard> : Mappable{
  
  var code : Int?
  var message : GCDataMessage<GiftCardClass>?
  
  required public init?(map: Map) {
    self.mapping(map: map)
  }
  
  open func mapping(map: Map) {
    code <- map["code"]
    message <- map["message"]
  }
}

open class GCDataMessage <GiftCardClass: BEGiftCard> : Mappable {
  var response : GCDataList<GiftCardClass>?
  
  required public init?(map: Map) {
    self.mapping(map: map)
  }
  
  open func mapping(map: Map) {
    response <- map["response"]
  }
}

open class GCDataList <GiftCardClass: BEGiftCard>  : Mappable{
  var success : Bool?
  var cards : [GiftCardClass]?
  
  required public init?(map: Map) {
    self.mapping(map: map)
  }
  
  open func mapping(map: Map) {
    success <- map["success"]
    cards <- map["cards"]
  }
}

