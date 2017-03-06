
//
//  BEGiftCard.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/12/17.
//
//

import Foundation

import ObjectMapper

open class BEGiftCard : Mappable {
  open static let kDefaultBalance = "$0.00"
  fileprivate static let kId = "BEGiftCard" + "_id"
  fileprivate static let kNumber = "BEGiftCard" + "_number"
  fileprivate static let kBalance = "BEGiftCard" + "_balance"
  open var id: String?
  open var number: String?
  open var balance: String?
  
  public init(id: String, number : String, balance : String){
    self.id = id
    self.number = number
    self.balance = balance
  }
  
  required public init?(map: Map) {
    self.mapping(map: map)
  }
  
  open func mapping(map: Map) {
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
  
  init?(storage : UserDefaults){
    id = storage.object(forKey: BEGiftCard.kId) as? String
    if id == nil {
      return nil
    }
    number = storage.object(forKey: BEGiftCard.kNumber) as? String
    balance = storage.object(forKey: BEGiftCard.kBalance) as? String
  }
  
  class func clear(_ storage : UserDefaults) {
    storage.set(nil, forKey: BEGiftCard.kId)
    storage.set(nil, forKey: BEGiftCard.kNumber)
    storage.set(nil, forKey: BEGiftCard.kBalance)
    
    storage.synchronize()
  }
  
  func save(_ storage : UserDefaults) {
    storage.set(id, forKey: BEGiftCard.kId)
    storage.set(number, forKey: BEGiftCard.kNumber)
    storage.set(balance, forKey: BEGiftCard.kBalance)
    
    storage.synchronize()
  }
  
  open func getDisplayNumber() -> String {
    if number != nil && number!.characters.count > 4{
      return "XXXXXXXXXXXX\(number!.substring(from: number!.characters.index(number!.endIndex, offsetBy: -4)))"
    }else {
      return "XXXXXXXXXXXXXXXX"
    }
  }
  
  open func getDisplayBalanse() -> String {
    if balance == nil{
      return BEGiftCard.kDefaultBalance
    }else {
      return balance!
    }
  }
}
