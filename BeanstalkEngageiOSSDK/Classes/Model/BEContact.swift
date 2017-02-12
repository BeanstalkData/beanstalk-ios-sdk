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
  public var preferredReward : String?
  public var novadine = false
  
  required public init() {
    
  }
  
  required public init?(_ map: Map) {
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
    preferredReward <- map["PreferredReward"]
    novadine <- map["Novadine_User"]
  }
}
