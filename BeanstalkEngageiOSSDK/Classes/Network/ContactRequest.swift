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
  
  private var contactId: Int?
  private var firstName : String?
  private var lastName : String?
  private var phone: String?
  private var email: String?
  private var password : String?
  private var zipCode : String?
  private var birthday: String?
  private var gender: String?
  private var emailOptin: Bool?
  private var textOptin: Bool?
  private var pushNotificationOptin: Bool?
  private var inboxMessageOptin: Bool?
  private var novadine: String?
  private var prospect : String?
  
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
  
  public func getPassword() -> String? {
    return self.password
  }
  
  public func set(firstName firstName: String?) {
    guard firstName?.characters.count > 0 else {
      return
    }

    guard origin?.firstName?.caseInsensitiveCompare(firstName!) != NSComparisonResult.OrderedSame else {
      self.firstName = nil
      return
    }
    
    self.firstName = firstName
  }
  
  public func getFirstName() -> String? {
    guard self.firstName == nil else {
      return self.firstName
    }
    return self.origin?.firstName
  }
  
  public func set(lastName lastName: String?) {
    guard lastName?.characters.count > 0 else {
      return
    }
    
    guard origin?.lastName?.caseInsensitiveCompare(lastName!) != NSComparisonResult.OrderedSame else {
      self.lastName = nil
      return
    }
    
    self.lastName = lastName
  }
  
  public func getLastName() -> String? {
    guard self.lastName == nil else {
      return self.lastName
    }
    return self.origin?.lastName
  }
  
  public func set(zipCode zipCode: String?) {
    guard zipCode != nil else {
      return
    }
    
    guard origin?.zipCode?.caseInsensitiveCompare(zipCode!) != NSComparisonResult.OrderedSame else {
      self.zipCode = nil
      return
    }
    
    self.zipCode = zipCode
  }
  
  public func getZipCode() -> String? {
    guard self.zipCode == nil else {
      return self.zipCode
    }
    return self.origin?.zipCode
  }
  
  public func set(email email: String?) {
    guard email?.characters.count > 0 else {
      return
    }
    
    guard origin?.email?.caseInsensitiveCompare(email!) != NSComparisonResult.OrderedSame else {
      self.email = nil
      return
    }
    
    self.email = email
  }
  
  public func getEmail() -> String? {
    guard self.email == nil else {
      return self.email
    }
    return self.origin?.email
  }

  
  public func set(phone phone: String?) {
    guard phone?.characters.count > 0 else {
      return
    }
    
    guard origin?.phone?.caseInsensitiveCompare(phone!) != NSComparisonResult.OrderedSame else {
      self.phone = nil
      return
    }
    
    self.phone = phone
  }
  
  public func getPhone() -> String? {
    guard self.phone == nil else {
      return self.phone
    }
    return self.origin?.phone
  }
  
  public func set(birthday birthday: String?) {
    guard birthday != nil else {
      return
    }
    
    guard origin?.birthday?.caseInsensitiveCompare(birthday!) != NSComparisonResult.OrderedSame else {
      self.birthday = nil
      return
    }
    
    self.birthday = birthday
  }
  
  public func getBirthday() -> String? {
    guard self.birthday == nil else {
      return self.birthday
    }
    return self.origin?.birthday
  }
  
  public func set(gender gender: String?) {
    guard gender != nil else {
      return
    }
    
    guard origin?.gender?.caseInsensitiveCompare(gender!) != NSComparisonResult.OrderedSame else {
      self.gender = nil
      return
    }
    
    self.gender = gender
  }
  
  public func getGender() -> String? {
    guard self.gender == nil else {
      return self.gender
    }
    return self.origin?.gender
  }

  
  public func set(emailOptin emailOptin: Bool?) {
    guard emailOptin != nil else {
      return
    }
    
    guard origin?.emailOptin != (emailOptin! ? 1 : 0) else {
      self.emailOptin = nil
      return
    }
    
    self.emailOptin = emailOptin
  }
  
  public func isEmailOptin() -> Bool? {
    guard self.emailOptin == nil else {
      return self.emailOptin
    }
    return self.origin?.isEmailOptin()
  }
  
  public func set(textOptin textOptin: Bool?) {
    guard textOptin != nil else {
      return
    }
    
    guard origin?.textOptin != (textOptin! ? 1 : 0) else {
      self.textOptin = nil
      return
    }
    
    self.textOptin = textOptin
  }
  
  public func isTextOptin() -> Bool? {
    guard self.textOptin == nil else {
      return self.textOptin
    }
    return self.origin?.isTextOptin()
  }
  
  public func set(pushNotificationOptin pushNotificationOptin: Bool?) {
    guard pushNotificationOptin != nil else {
      return
    }
    
    guard origin?.pushNotificationOptin != (pushNotificationOptin! ? 1 : 0) else {
      self.pushNotificationOptin = nil
      return
    }
    
    self.pushNotificationOptin = pushNotificationOptin
  }
  
  public func isPushNotificationOptin() -> Bool? {
    guard self.pushNotificationOptin == nil else {
      return self.pushNotificationOptin
    }
    return self.origin?.isPushNotificationOptin()
  }
  
  public func set(inboxMessageOptin inboxMessageOptin: Bool?) {
    guard inboxMessageOptin != nil else {
      return
    }
    
    guard origin?.inboxMessageOptin != (inboxMessageOptin! ? 1 : 0) else {
      self.inboxMessageOptin = nil
      return
    }
    
    self.inboxMessageOptin = inboxMessageOptin
  }
  
  public func isInboxMessageOptin() -> Bool? {
    guard self.inboxMessageOptin == nil else {
      return self.inboxMessageOptin
    }
    return self.origin?.isInboxMessageOptin()
  }
  
  public func set(novadine novadine: Bool?) {
    guard novadine != nil else {
      return
    }
    
    guard origin?.novadine != novadine! else {
      self.novadine = nil
      return
    }
    
    self.novadine = (novadine! ? "1" : "0")
  }
  
  public func isNovadine() -> Bool {
    return self.novadine == "1"
  }
  
  public func mapping(map: Map) {
    
    contactId <- map["ContactID"]
    password <- map["Password"]
    firstName <- map["FirstName"]
    lastName <- map["LastName"]
    zipCode <- map["ZipCode"]
    email <- map["Email"]
    prospect <- map["Prospect"]
    phone <- map["CellNumber"]
    birthday <- map["Birthday"]
    gender <- map["Gender"]
    emailOptin <- map["Email_Optin"]
    textOptin <- map["Txt_Optin"]
    pushNotificationOptin <- map["PushNotification_Optin"]
    inboxMessageOptin <- map["InboxMessage_Optin"]
    novadine <- map["custom_Novadine_User"]
  }

  public func normalize() {
    self.set(phone: self.phone?.formatPhoneNumberToNationalSignificant())
  }
}
