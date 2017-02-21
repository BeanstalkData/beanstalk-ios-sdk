//
//  UpdateContactRequest.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/16/17.
//
//

import Foundation

public final class UpdateContactRequest{
  public var firstName : String?
  public var lastName : String?
  public var phone: String?
  public var email: String?
  public var zipCode : String?
  public var birthdate: String?
  public var gender = "Unknown"
  public var emailOptIn = false
  public var txtOptIn = false
  public var pushNotificationOptin = false
  public var inboxMessageOptin = false
  public var preferredReward : String?
  
  public init(contact: BEContact?) {
    self.firstName = contact?.firstName
    self.lastName = contact?.lastName
    self.phone = contact?.phone?.stringByReplacingOccurrencesOfString("-", withString: "")
    self.email = contact?.email
    self.zipCode = contact?.zipCode
    self.birthdate = contact?.birthday
    if let gender = contact?.gender {
      self.gender = gender
    }
    if let optIn = contact?.emailOptin {
      self.emailOptIn = optIn > 0
    }
    if let optIn = contact?.pushNotificationOptin {
      self.pushNotificationOptin = optIn > 0
    }
    self.inboxMessageOptin = self.pushNotificationOptin
    
    self.preferredReward = contact?.preferredReward
  }
}
