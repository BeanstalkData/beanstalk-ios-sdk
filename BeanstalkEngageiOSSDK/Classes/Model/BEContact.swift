//
//  BEContact.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/13/17.
//
//

import Foundation

import ObjectMapper

open class BEContact : Mappable {
  
  fileprivate static let kId = "BEContact" + "_id"
  fileprivate static let kFirstName = "BEContact" + "_firstName"
  fileprivate static let kLastName = "BEContact" + "_lastName"
  fileprivate static let kZipCode = "BEContact" + "_zipCode"
  fileprivate static let kEmail = "BEContact" + "_email"
  fileprivate static let kProspect = "BEContact" + "_prospect"
  fileprivate static let kGender = "BEContact" + "_gender"
  fileprivate static let kBirthday = "BEContact" + "_birthday"
  fileprivate static let kFKey = "BEContact" + "_fKey"
  fileprivate static let kPhone = "BEContact" + "_phone"
  fileprivate static let kTextOptin = "BEContact" + "_textOptin"
  fileprivate static let kEmailOptin = "BEContact" + "_emailOptin"
  fileprivate static let kPushNotificationOptin = "BEContact" + "_pushNotificationOptin"
  fileprivate static let kInboxMessageOptin = "BEContact" + "_inboxMessageOptin"
  
  open var contactId: Int?
  open var firstName: String?
  open var lastName : String?
  open var zipCode : String?
  open var email : String?
  open var prospect : String?
  open var gender: String?
  open var birthday : String?
  open var fKey : String?
  open var phone : String?
  open var textOptin = 0
  open var emailOptin = 0
  open var pushNotificationOptin = 0
  open var inboxMessageOptin = 0
  
  required public init() {
    
  }
  
  required public init?(map: Map) {
  }
  
  open func isMale() -> Bool? {
    guard gender != nil else {
      return nil
    }
    
    guard gender != "Unknown" else {
      return nil
    }
    
    return (self.gender == "Male")
  }
  
  open func isEmailOptin() -> Bool {
    return emailOptin != 0
  }
  
  open func isPushNotificationOptin() -> Bool {
    return pushNotificationOptin != 0
  }
  
  open func isInboxMessageOptin() -> Bool {
    return inboxMessageOptin != 0
  }
  
  open func isTextOptin() -> Bool {
    return textOptin != 0
  }
  
  open func mapping(map: Map) {
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
  }
  
  // MARK: - Persistence store -
  
  required public init?(storage : UserDefaults){
    contactId = storage.object(forKey: BEContact.kId) as? Int
    if contactId == nil {
      return nil
    }
    
    firstName = storage.object(forKey: BEContact.kFirstName) as? String
    lastName = storage.object(forKey: BEContact.kLastName) as? String
    zipCode = storage.object(forKey: BEContact.kZipCode) as? String
    email = storage.object(forKey: BEContact.kEmail) as? String
    prospect = storage.object(forKey: BEContact.kProspect) as? String
    gender = storage.object(forKey: BEContact.kGender) as? String
    birthday = storage.object(forKey: BEContact.kBirthday) as? String
    fKey = storage.object(forKey: BEContact.kFKey) as? String
    phone = storage.object(forKey: BEContact.kPhone) as? String
    if let textOptin = storage.object(forKey: BEContact.kTextOptin) as? Int {
      self.textOptin = textOptin
    }
    if let emailOptin = storage.object(forKey: BEContact.kEmailOptin) as? Int {
      self.emailOptin = emailOptin
    }
    if let pushNotificationOptin = storage.object(forKey: BEContact.kPushNotificationOptin) as? Int {
      self.pushNotificationOptin = pushNotificationOptin
    }
    if let inboxMessageOptin = storage.object(forKey: BEContact.kInboxMessageOptin) as? Int {
      self.inboxMessageOptin = inboxMessageOptin
    }
  }
  
  class func clear(_ storage : UserDefaults) {
    storage.set(nil, forKey: BEContact.kId)
    storage.set(nil, forKey: BEContact.kFirstName)
    storage.set(nil, forKey: BEContact.kLastName)
    storage.set(nil, forKey: BEContact.kZipCode)
    storage.set(nil, forKey: BEContact.kEmail)
    storage.set(nil, forKey: BEContact.kProspect)
    storage.set(nil, forKey: BEContact.kGender)
    storage.set(nil, forKey: BEContact.kBirthday)
    storage.set(nil, forKey: BEContact.kFKey)
    storage.set(nil, forKey: BEContact.kPhone)
    storage.set(nil, forKey: BEContact.kTextOptin)
    storage.set(nil, forKey: BEContact.kEmailOptin)
    storage.set(nil, forKey: BEContact.kPushNotificationOptin)
    storage.set(nil, forKey: BEContact.kInboxMessageOptin)
    
    storage.synchronize()
  }
  
  func save(_ storage : UserDefaults) {
    storage.set(contactId, forKey: BEContact.kId)
    storage.set(firstName, forKey: BEContact.kFirstName)
    storage.set(lastName, forKey: BEContact.kLastName)
    storage.set(zipCode, forKey: BEContact.kZipCode)
    storage.set(email, forKey: BEContact.kEmail)
    storage.set(prospect, forKey: BEContact.kProspect)
    storage.set(gender, forKey: BEContact.kGender)
    storage.set(birthday, forKey: BEContact.kBirthday)
    storage.set(fKey, forKey: BEContact.kFKey)
    storage.set(phone, forKey: BEContact.kPhone)
    storage.set(textOptin, forKey: BEContact.kTextOptin)
    storage.set(emailOptin, forKey: BEContact.kEmailOptin)
    storage.set(pushNotificationOptin, forKey: BEContact.kPushNotificationOptin)
    storage.set(inboxMessageOptin, forKey: BEContact.kInboxMessageOptin)
    
    storage.synchronize()
  }
}
