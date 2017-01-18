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
  public var male = false
  public var emailOptIn = false
  public var txtOptIn = false
  public var pushNotificationOptin = false
  public var inboxMessageOptin = false
  public var preferredReward : String?
  
  public init() {
    
  }
}
