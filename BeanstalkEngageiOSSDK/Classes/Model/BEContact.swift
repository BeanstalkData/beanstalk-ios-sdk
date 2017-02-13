//
//  BEContact.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/13/17.
//
//

import Foundation

import ObjectMapper

public class BEContact : Mappable {
  
  private static let kId = "BEContact" + "_id"
  private static let kFirstName = "BEContact" + "_firstName"
  private static let kLastName = "BEContact" + "_lastName"
  private static let kZipCode = "BEContact" + "_zipCode"
  private static let kEmail = "BEContact" + "_email"
  private static let kProspect = "BEContact" + "_prospect"
  private static let kGender = "BEContact" + "_gender"
  private static let kBirthday = "BEContact" + "_birthday"
  private static let kFKey = "BEContact" + "_fKey"
  private static let kPhone = "BEContact" + "_phone"
  private static let kTextOptin = "BEContact" + "_textOptin"
  private static let kEmailOptin = "BEContact" + "_emailOptin"
  private static let kPushNotificationOptin = "BEContact" + "_pushNotificationOptin"
  private static let kInboxMessageOptin = "BEContact" + "_inboxMessageOptin"
  private static let kNovadine = "BEContact" + "_novadine"
  
  public var contactId: Int?
  public var firstName: String?
  public var lastName : String?
  public var zipCode : String?
  public var email : String?
  public var prospect : String?
  public var gender: String?
  public var birthday : String?
  public var fKey : String?
  public var phone : String?
  public var textOptin = 0
  public var emailOptin = 0
  public var pushNotificationOptin = 0
  public var inboxMessageOptin = 0
  public var novadine = false
  
  required public init() {
    
  }
  
  required public init?(_ map: Map) {
  }
  
  public func isMale() -> Bool? {
    guard gender != nil else {
      return nil
    }
    
    return (self.gender == "Male")
  }
  
  public func isEmailOptin() -> Bool {
    return emailOptin != 0
  }
  
  public func isPushNotificationOptin() -> Bool {
    return pushNotificationOptin != 0
  }
  
  public func mapping(map: Map) {
    contactId <- map["contactId"]
    firstName <- map["contactFirstName"]
    lastName <- map["contactLastName"]
    zipCode <- map["contactZipCode"]
    email <- map["contactEmail"]
    prospect <- map["Prospect"]
    gender <- map["gender"]
    birthday <- map["contactBirthday"]
    fKey <- map["FKey"]
    phone <- map["Cell_Number"]
    textOptin <- map["Txt_Optin"]
    emailOptin <- map["Email_Optin"]
    pushNotificationOptin <- map["PushNotification_Optin"]
    inboxMessageOptin <- map["InboxMessage_Optin"]
    novadine <- map["Novadine_User"]
  }
  
  // MARK: - Persistence store -
  
  required public init?(storage : NSUserDefaults){
    contactId = storage.objectForKey(BEContact.kId) as? Int
    if contactId == nil {
      return nil
    }
    
    firstName = storage.objectForKey(BEContact.kFirstName) as? String
    lastName = storage.objectForKey(BEContact.kLastName) as? String
    zipCode = storage.objectForKey(BEContact.kZipCode) as? String
    email = storage.objectForKey(BEContact.kEmail) as? String
    prospect = storage.objectForKey(BEContact.kProspect) as? String
    gender = storage.objectForKey(BEContact.kGender) as? String
    birthday = storage.objectForKey(BEContact.kBirthday) as? String
    fKey = storage.objectForKey(BEContact.kFKey) as? String
    phone = storage.objectForKey(BEContact.kPhone) as? String
    if let textOptin = storage.objectForKey(BEContact.kTextOptin) as? Int {
      self.textOptin = textOptin
    }
    if let emailOptin = storage.objectForKey(BEContact.kEmailOptin) as? Int {
      self.emailOptin = emailOptin
    }
    if let pushNotificationOptin = storage.objectForKey(BEContact.kPushNotificationOptin) as? Int {
      self.pushNotificationOptin = pushNotificationOptin
    }
    if let inboxMessageOptin = storage.objectForKey(BEContact.kInboxMessageOptin) as? Int {
      self.inboxMessageOptin = inboxMessageOptin
    }
    if let novadine = storage.objectForKey(BEContact.kNovadine) as? Bool {
      self.novadine = novadine
    }
  }
  
  class func clear(storage : NSUserDefaults) {
    storage.setObject(nil, forKey: BEContact.kId)
    storage.setObject(nil, forKey: BEContact.kFirstName)
    storage.setObject(nil, forKey: BEContact.kLastName)
    storage.setObject(nil, forKey: BEContact.kZipCode)
    storage.setObject(nil, forKey: BEContact.kEmail)
    storage.setObject(nil, forKey: BEContact.kProspect)
    storage.setObject(nil, forKey: BEContact.kGender)
    storage.setObject(nil, forKey: BEContact.kBirthday)
    storage.setObject(nil, forKey: BEContact.kFKey)
    storage.setObject(nil, forKey: BEContact.kPhone)
    storage.setObject(nil, forKey: BEContact.kTextOptin)
    storage.setObject(nil, forKey: BEContact.kEmailOptin)
    storage.setObject(nil, forKey: BEContact.kPushNotificationOptin)
    storage.setObject(nil, forKey: BEContact.kInboxMessageOptin)
    storage.setObject(nil, forKey: BEContact.kNovadine)
    
    storage.synchronize()
  }
  
  func save(storage : NSUserDefaults) {
    storage.setObject(contactId, forKey: BEContact.kId)
    storage.setObject(firstName, forKey: BEContact.kFirstName)
    storage.setObject(lastName, forKey: BEContact.kLastName)
    storage.setObject(zipCode, forKey: BEContact.kZipCode)
    storage.setObject(email, forKey: BEContact.kEmail)
    storage.setObject(prospect, forKey: BEContact.kProspect)
    storage.setObject(gender, forKey: BEContact.kGender)
    storage.setObject(birthday, forKey: BEContact.kBirthday)
    storage.setObject(fKey, forKey: BEContact.kFKey)
    storage.setObject(phone, forKey: BEContact.kPhone)
    storage.setObject(textOptin, forKey: BEContact.kTextOptin)
    storage.setObject(emailOptin, forKey: BEContact.kEmailOptin)
    storage.setObject(pushNotificationOptin, forKey: BEContact.kPushNotificationOptin)
    storage.setObject(inboxMessageOptin, forKey: BEContact.kInboxMessageOptin)
    storage.setObject(novadine, forKey: BEContact.kNovadine)
    
    storage.synchronize()
  }
}
