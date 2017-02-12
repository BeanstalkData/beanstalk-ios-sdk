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
  
  private(set) var contactId: Int?
  private(set) var firstName : String?
  private(set) var lastName : String?
  private(set) var phone: String?
  private(set) var email: String?
  private(set) var password : String?
  private(set) var zipCode : String?
  private(set) var birthday: String?
  private(set) var gender: String?
  private(set) var emailOptin: Bool?
  private(set) var textOptin: Bool?
  private(set) var pushNotificationOptin: Bool?
  private(set) var inboxMessageOptin: Bool?
  private(set) var novadine: String?
  private(set) var prospect : String?
  
//  public var passwordConfirm : String?
//  public var emailConfirm: String?
//  public var gender: String?
//  public var preferredReward : String?
  
  private var origin: BEContact?
  
  public init(prospect: String = "loyalty") {
    
  }
  
  public init(origin: BEContact, prospect: String = "loyalty") {
    self.origin = origin
    self.contactId = origin.contactId
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
  
  public func set(male male: Bool?) {
    guard male != nil else {
      return
    }
    
    let gender = male! ? "Male" : "Female"
    
    guard origin?.gender?.caseInsensitiveCompare(gender) != NSComparisonResult.OrderedSame else {
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
    
    contactId <- map["contactId"]
    firstName <- map["FirstName"]
    lastName <- map["LastName"]
    zipCode <- map["ZipCode"]
    email <- map["Email"]
    prospect <- map["Prospect"]
    phone <- map["Cell_Number"]
    birthday <- map["Birthday"]
    gender <- map["gender"]
    emailOptin <- map["Email_Optin"]
//    "Email_Optin": request.emailOptIn ? "true" :"false",
    textOptin <- map["Txt_Optin"]
//    "Txt_Optin": request.txtOptIn ? "true" :"false",
    pushNotificationOptin <- map["PushNotification_Optin"]
//    "PushNotification_Optin": request.pushNotificationOptin ? "true" :"false",
    inboxMessageOptin <- map["InboxMessage_Optin"]
//    "InboxMessage_Optin": request.inboxMessageOptin ? "true" :"false",
    novadine <- map["custom_Novadine_User"]
//    "custom_Novadine_User" : request.novadine ? "1" :"0",
  }

}
