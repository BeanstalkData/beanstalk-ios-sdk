//
//  CreateContactRequest.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/16/17.
//
//

import Foundation

import ObjectMapper

public class ContactRequest: Mappable{
  
  public private(set) var contactId: Int?
  public private(set) var firstName : String?
  public private(set) var lastName : String?
  public private(set) var phone: String?
  public private(set) var email: String?
  public private(set) var password : String?
  public private(set) var zipCode : String?
  public private(set) var birthday: String?
  public private(set) var gender: String?
  public private(set) var emailOptin: Bool?
  public private(set) var textOptin: Bool?
  public private(set) var pushNotificationOptin: Bool?
  public private(set) var inboxMessageOptin: Bool?
  public private(set) var novadine: String?
  public private(set) var prospect : String?
  
  public private(set) var origin: BEContact?
  
  public init(origin: BEContact? = nil, prospect: String = "loyalty") {
    self.origin = origin
    self.contactId = origin?.contactId
    self.prospect = prospect
  }
  
  public required init?(_ map: Map) {
  }
  
  public func set(password password: String?) {
    self.password = password
  }
  
  public func set(firstName firstName: String?) {
    guard firstName?.characters.count > 0 else {
      return
    }

    guard origin?.firstName?.caseInsensitiveCompare(firstName!) != NSComparisonResult.OrderedSame else {
      return
    }
    
    self.firstName = firstName
  }
  
  public func set(lastName lastName: String?) {
    guard lastName?.characters.count > 0 else {
      return
    }
    
    guard origin?.lastName?.caseInsensitiveCompare(lastName!) != NSComparisonResult.OrderedSame else {
      return
    }
    
    self.lastName = lastName
  }
  
  public func set(zipCode zipCode: String?) {
    guard zipCode?.characters.count > 0 else {
      return
    }
    
    guard origin?.zipCode?.caseInsensitiveCompare(zipCode!) != NSComparisonResult.OrderedSame else {
      return
    }
    
    self.zipCode = zipCode
  }
  
  public func set(email email: String?) {
    guard email?.characters.count > 0 else {
      return
    }
    
    guard origin?.email?.caseInsensitiveCompare(email!) != NSComparisonResult.OrderedSame else {
      return
    }
    
    self.email = email
  }
  
  public func set(phone phone: String?) {
    guard phone?.characters.count > 0 else {
      return
    }
    
    guard origin?.phone?.caseInsensitiveCompare(phone!) != NSComparisonResult.OrderedSame else {
      return
    }
    
    self.phone = phone
  }
  
  public func set(birthday birthday: String?) {
    guard birthday?.characters.count > 0 else {
      return
    }
    
    guard origin?.birthday?.caseInsensitiveCompare(birthday!) != NSComparisonResult.OrderedSame else {
      return
    }
    
    self.birthday = birthday
  }
  
  public func set(gender gender: String?) {
    guard gender != nil else {
      return
    }
    
    guard origin?.gender?.caseInsensitiveCompare(gender!) != NSComparisonResult.OrderedSame else {
      return
    }
    
    self.gender = gender
  }
  
  public func set(emailOptin emailOptin: Bool?) {
    guard emailOptin != nil else {
      return
    }
    
    guard origin?.emailOptin != (emailOptin! ? 1 : 0) else {
      return
    }
    
    self.emailOptin = emailOptin
  }
  
  public func set(textOptin textOptin: Bool?) {
    guard textOptin != nil else {
      return
    }
    
    guard origin?.textOptin != (textOptin! ? 1 : 0) else {
      return
    }
    
    self.textOptin = textOptin
  }
  
  public func set(pushNotificationOptin pushNotificationOptin: Bool?) {
    guard pushNotificationOptin != nil else {
      return
    }
    
    guard origin?.pushNotificationOptin != (pushNotificationOptin! ? 1 : 0) else {
      return
    }
    
    self.pushNotificationOptin = pushNotificationOptin
  }
  
  public func set(inboxMessageOptin inboxMessageOptin: Bool?) {
    guard inboxMessageOptin != nil else {
      return
    }
    
    guard origin?.inboxMessageOptin != (inboxMessageOptin! ? 1 : 0) else {
      return
    }
    
    self.inboxMessageOptin = inboxMessageOptin
  }
  
  public func set(novadine novadine: Bool?) {
    guard novadine != nil else {
      return
    }
    
    guard origin?.novadine != novadine! else {
      return
    }
    
    self.novadine = (novadine! ? "1" : "0")
  }
  
  public func isNovadine() -> Bool {
    return self.novadine == "1"
  }
  
  public func mapping(map: Map) {
    
    contactId <- map["ContactID"]
    firstName <- map["FirstName"]
    lastName <- map["LastName"]
    zipCode <- map["ZipCode"]
    email <- map["Email"]
    prospect <- map["Prospect"]
    phone <- map["Cell_Number"]
    birthday <- map["Birthday"]
    gender <- map["Gender"]
    emailOptin <- map["Email_Optin"]
    textOptin <- map["Txt_Optin"]
    pushNotificationOptin <- map["PushNotification_Optin"]
    inboxMessageOptin <- map["InboxMessage_Optin"]
    novadine <- map["custom_Novadine_User"]
  }

}
