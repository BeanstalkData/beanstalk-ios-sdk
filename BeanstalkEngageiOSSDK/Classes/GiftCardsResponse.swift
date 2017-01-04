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
  
  func getCards() -> [GiftCard]?
  
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
  
  public func getCards() -> [GiftCard]?{
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
  var cards : [GiftCard]?
  
  required public init?(_ map: Map) {
    
  }
  
  public func mapping(map: Map) {
    success <- map["success"]
    cards <- map["cards"]
  }
}

public class GiftCard : Mappable {
  public static let kDefaultBalance = "$0.00"
  private static let kId = "_id"
  private static let kNumber = "_number"
  private static let kBalance = "_balance"
  public var id: String?
  public var number: String?
  public var balance: String?
  
  public init(id: String, number : String, balance : String){
    self.id = id
    self.number = number
    self.balance = balance
  }
  
  required public init?(_ map: Map) {
    
  }
  
  public func mapping(map: Map) {
    id <- map["Id"]
    if id == nil {
      var numberId: NSNumber?
      numberId <- map["Id"]
      
      if numberId != nil {
        id = numberId?.stringValue
      }
    }
    number <- map["cardNumber"]
    balance <- map["balance"]
  }
  
  init?(storage : NSUserDefaults){
    id = storage.valueForKey(GiftCard.kId) as? String
    if id == nil {
      return nil
    }
    number = storage.valueForKey(GiftCard.kNumber) as? String
    balance = storage.valueForKey(GiftCard.kBalance) as? String
  }
  
  func save(storage : NSUserDefaults){
    storage.setValue(id, forKey: GiftCard.kId)
    storage.setValue(number, forKey: GiftCard.kNumber)
    storage.setValue(balance, forKey: GiftCard.kBalance)
    storage.synchronize()
  }
  
  public func getDisplayNumber() -> String {
    if number != nil && number!.characters.count > 4{
      return "XXXXXXXXXXXX\(number!.substringFromIndex(number!.endIndex.advancedBy(-4)))"
    }else {
      return "XXXXXXXXXXXXXXXX"
    }
  }
  
  public func getDisplayBalanse() -> String {
    if balance == nil{
      return GiftCard.kDefaultBalance
    }else {
      return balance!
    }
  }
}
