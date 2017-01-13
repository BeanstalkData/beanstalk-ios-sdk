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

public class GCResponse : Mappable, GiftCardsResponse {
  private var status : Bool?
  
  private var response : GCDataResponse?
  
  required public init?(_ map: Map) {
    
  }
  
  public func mapping(map: Map) {
    status <- map["status"]
    response <- map["success"]
  }
  
  public func failed() -> Bool{
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
  
  public func getCards() -> [BEGiftCard]?{
    return response?.message?.response?.cards
  }
}

public class GCDataResponse : Mappable{
  
  var code : Int?
  var message : GCDataMessage?
  
  required public init?(_ map: Map) {
    
  }
  
  public func mapping(map: Map) {
    code <- map["code"]
    message <- map["message"]
  }
}

public class GCDataMessage : Mappable {
  var response : GCDataList?
  
  required public init?(_ map: Map) {
    
  }
  
  public func mapping(map: Map) {
    response <- map["response"]
  }
}

public class GCDataList : Mappable{
  var success : Bool?
  var cards : [BEGiftCard]?
  
  required public init?(_ map: Map) {
    
  }
  
  public func mapping(map: Map) {
    success <- map["success"]
    cards <- map["cards"]
  }
}

