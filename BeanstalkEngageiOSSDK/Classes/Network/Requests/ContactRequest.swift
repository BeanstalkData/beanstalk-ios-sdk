//
//  CreateContactRequest.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

/**
 Request model for contact create/update.
 */
open class ContactRequest: Mappable {
  
  fileprivate var contactId: Int?
  fileprivate var firstName : String?
  fileprivate var lastName : String?
  fileprivate var phone: String?
  fileprivate var email: String?
  fileprivate var fKey: String?
  fileprivate var password : String?
  fileprivate var zipCode : String?
  fileprivate var birthday: String?
  fileprivate var gender: String?
  fileprivate var emailOptin: Bool?
  fileprivate var textOptin: Bool?
  fileprivate var inboxMessageOptin: Bool?
  fileprivate var prospect : String?
  fileprivate var googleId: String?
  fileprivate var googleToken: String?
  fileprivate var fBid: String?
  fileprivate var fBToken: String?
  fileprivate var primaryId: String?

  open fileprivate(set) var origin: BEContact?
  
  public init(origin: BEContact? = nil, prospect: String = "loyalty") {
    self.origin = origin
    self.contactId = origin?.contactId
    self.prospect = prospect
  }
  
  public required init?(map: Map) {
  }
  
  open func getContactId() -> String? {
    if let cId = self.contactId {
      return String(cId)
    }
    else {
      return nil
    }
  }
  
  open func set(password: String?) {
    self.password = password
  }
  
  open func getPassword() -> String? {
    return self.password
  }
  
  open func set(firstName: String?) {
    guard let firstName = firstName, !firstName.isEmpty else { return }

    guard origin?.firstName?.caseInsensitiveCompare(firstName) != ComparisonResult.orderedSame else {
      self.firstName = nil
      return
    }
    
    self.firstName = firstName
  }
  
  open func getFirstName() -> String? {
    guard self.firstName == nil else {
      return self.firstName
    }
    return self.origin?.firstName
  }
  
  open func set(lastName: String?) {
    guard let lastName = lastName, !lastName.isEmpty else {
      return
    }
    
    guard origin?.lastName?.caseInsensitiveCompare(lastName) != ComparisonResult.orderedSame else {
      self.lastName = nil
      return
    }
    
    self.lastName = lastName
  }
  
  open func getLastName() -> String? {
    guard self.lastName == nil else {
      return self.lastName
    }
    return self.origin?.lastName
  }
  
  open func set(zipCode: String?) {
    guard zipCode != nil else {
      return
    }
    
    guard origin?.zipCode?.caseInsensitiveCompare(zipCode!) != ComparisonResult.orderedSame else {
      self.zipCode = nil
      return
    }
    
    self.zipCode = zipCode
  }
  
  open func getZipCode() -> String? {
    guard self.zipCode == nil else {
      return self.zipCode
    }
    return self.origin?.zipCode
  }
  
  open func set(email: String?) {
    guard let email = email, !email.isEmpty else {
      return
    }
    
    guard origin?.email?.caseInsensitiveCompare(email) != ComparisonResult.orderedSame else {
      self.email = nil
      return
    }
    
    self.email = email
  }
  
  open func getEmail() -> String? {
    guard self.email == nil else {
      return self.email
    }
    return self.origin?.email
  }
  
  open func set(fKey: String?) {
    guard let fKey = fKey, !fKey.isEmpty else {
      return
    }
    
    guard origin?.fKey?.caseInsensitiveCompare(fKey) != ComparisonResult.orderedSame else {
      self.fKey = nil
      return
    }
    
    self.fKey = fKey
  }
  
  open func getFKey() -> String? {
    guard self.fKey == nil else {
      return self.fKey
    }
    return self.origin?.fKey
  }

  
  open func set(phone: String?) {
    guard let phone = phone, !phone.isEmpty else {
      return
    }
    
    guard origin?.phone?.caseInsensitiveCompare(phone) != ComparisonResult.orderedSame else {
      self.phone = nil
      return
    }
    
    self.phone = phone
  }
  
  open func getPhone() -> String? {
    guard self.phone == nil else {
      return self.phone
    }
    return self.origin?.phone
  }
  
  open func set(birthday: String?) {
    guard birthday != nil else {
      return
    }
    
    guard origin?.birthday?.caseInsensitiveCompare(birthday!) != ComparisonResult.orderedSame else {
      self.birthday = nil
      return
    }
    
    self.birthday = birthday
  }
  
  open func getBirthday() -> String? {
    guard self.birthday == nil else {
      return self.birthday
    }
    return self.origin?.birthday
  }
  
  open func set(gender: String?) {
    guard gender != nil else {
      return
    }
    
    guard origin?.gender?.caseInsensitiveCompare(gender!) != ComparisonResult.orderedSame else {
      self.gender = nil
      return
    }
    
    self.gender = gender
  }
  
  open func getGender() -> String? {
    guard self.gender == nil else {
      return self.gender
    }
    return self.origin?.gender
  }

  
  open func set(emailOptin: Bool?) {
    guard emailOptin != nil else {
      return
    }
    
    guard origin?.emailOptin != (emailOptin! ? 1 : 0) else {
      self.emailOptin = nil
      return
    }
    
    self.emailOptin = emailOptin
  }
  
  open func isEmailOptin() -> Bool? {
    guard self.emailOptin == nil else {
      return self.emailOptin
    }
    return self.origin?.isEmailOptin()
  }
  
  open func set(textOptin: Bool?) {
    guard textOptin != nil else {
      return
    }
    
    guard origin?.textOptin != (textOptin! ? 1 : 0) else {
      self.textOptin = nil
      return
    }
    
    self.textOptin = textOptin
  }
  
  open func isTextOptin() -> Bool? {
    guard self.textOptin == nil else {
      return self.textOptin
    }
    return self.origin?.isTextOptin()
  }
  
  open func set(inboxMessageOptin: Bool?) {
    guard inboxMessageOptin != nil else {
      return
    }
    
    guard origin?.inboxMessageOptin != (inboxMessageOptin! ? 1 : 0) else {
      self.inboxMessageOptin = nil
      return
    }
    
    self.inboxMessageOptin = inboxMessageOptin
  }
  
  open func isInboxMessageOptin() -> Bool? {
    guard self.inboxMessageOptin == nil else {
      return self.inboxMessageOptin
    }
    return self.origin?.isInboxMessageOptin()
  }
  
  open func set(prospect: String?) {
    guard let prospect = prospect, !prospect.isEmpty else {
      return
    }
    
    guard origin?.prospect?.caseInsensitiveCompare(prospect) != ComparisonResult.orderedSame else {
      self.prospect = nil
      return
    }
    
    self.prospect = prospect
  }
  
  open func getProspect() -> String? {
    guard self.prospect == nil else {
      return self.prospect
    }
    return self.origin?.prospect
  }
  
  open func set(googleId: String?) {
    guard let googleId = googleId else {
      return
    }

    guard origin?.googleId?.caseInsensitiveCompare(googleId) != ComparisonResult.orderedSame else {
      self.googleId = nil
      return
    }

    self.googleId = googleId
  }

  open func set(googleToken: String?) {
    guard let googleToken = googleToken else {
      return
    }

    guard origin?.googleToken?.caseInsensitiveCompare(googleToken) != ComparisonResult.orderedSame else {
      self.googleToken = nil
      return
    }
    
    self.googleToken = googleToken
  }
  
  open func set(fBid: String?) {
    guard let fBid = fBid else {
      return
    }

    guard origin?.fbId?.caseInsensitiveCompare(fBid) != ComparisonResult.orderedSame else {
      self.googleToken = nil
      return
    }
    
    self.fBid = fBid
  }

  open func set(fBToken: String?) {
    guard let fBToken = fBToken else {
      return
    }

    guard origin?.fbToken?.caseInsensitiveCompare(fBToken) != ComparisonResult.orderedSame else {
      self.googleToken = nil
      return
    }
    
    self.fBToken = fBToken
  }

  open func set(primaryId: String?) {
    guard let primaryId = primaryId else { return }
    
    guard origin?.primaryId?.caseInsensitiveCompare(primaryId) != ComparisonResult.orderedSame else {
      self.primaryId = nil
      return
    }
    
    self.primaryId = primaryId
  }
  
  open func getPrimaryId() -> String? {
    guard self.primaryId == nil else {
      return self.primaryId
    }
    return self.origin?.primaryId
  }
  
  open func mapping(map: Map) {
    
    contactId <- map["ContactID"]
    password <- map["Password"]
    firstName <- map["FirstName"]
    lastName <- map["LastName"]
    zipCode <- map["ZipCode"]
    email <- map["Email"]
    fKey <- map["FKey"]
    prospect <- map["Prospect"]
    phone <- map["CellNumber"]
    birthday <- map["Birthday"]
    gender <- map["Gender"]
    emailOptin <- map["Email_Optin"]
    textOptin <- map["Txt_Optin"]
    inboxMessageOptin <- map["InboxMessage_Optin"]
    googleId <- map["GoogleId"]
    googleToken <- map["GoogleToken"]
    fBid <- map["FBid"]
    fBToken <- map["FBToken"]
    primaryId <- map["Primary_Id"]
  }

  open func normalize() {
    self.set(phone: self.phone?.formatPhoneNumberToNationalSignificant())
  }
}

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}
