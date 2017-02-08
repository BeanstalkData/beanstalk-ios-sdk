
//
//  BEGiftCard.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/12/17.
//
//

import Foundation

import ObjectMapper

public class BEGiftCard : Mappable {
  public static let kDefaultBalance = "$0.00"
  private static let kId = "BEGiftCard" + "_id"
  private static let kNumber = "BEGiftCard" + "_number"
  private static let kBalance = "BEGiftCard" + "_balance"
  public var id: String?
  public var number: String?
  public var balance: String?
  
  public init(id: String, number : String, balance : String){
    self.id = id
    self.number = number
    self.balance = balance
  }
  
  required public init?(_ map: Map) {
    self.mapping(map)
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
    id = storage.objectForKey(BEGiftCard.kId) as? String
    if id == nil {
      return nil
    }
    number = storage.objectForKey(BEGiftCard.kNumber) as? String
    balance = storage.objectForKey(BEGiftCard.kBalance) as? String
  }
  
  class func clear(storage : NSUserDefaults) {
    storage.setObject(nil, forKey: BEGiftCard.kId)
    if storage.objectForKey(BEGiftCard.kId) != nil {
      let nErr = 1
    }
    
    storage.setObject(nil, forKey: BEGiftCard.kNumber)
    storage.setObject(nil, forKey: BEGiftCard.kBalance)
    storage.synchronize()
  }
  
  func save(storage : NSUserDefaults) {
    storage.setObject(id, forKey: BEGiftCard.kId)
    storage.setObject(number, forKey: BEGiftCard.kNumber)
    storage.setObject(balance, forKey: BEGiftCard.kBalance)
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
      return BEGiftCard.kDefaultBalance
    }else {
      return balance!
    }
  }
}
