//
//  BESession.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation

/**
 Protocol for accessing (persistence) session-related data:
 * Contact info
 * Auth token
 * APNs device token
 * Default Gift card
 * Rewards
 */
public protocol BESessionProtocol {
  /**
   Accessor method for user contact of provided class.
   */
  func getContact <ContactClass: BEContact> () -> ContactClass?
  /**
   Accessor method for user contact of provided class.
   */
  func setContact(_ contact: BEContact?)
  /**
   Accessor method for user contact id.
   */
  func getContactId() -> String?
  
  /**
   Accessor method for user auth token.
   */
  func getAuthToken() -> String?
  /**
   Accessor method for user auth token.
   */
  func setAuthToke(_ token: String?)
  
  /**
   Accessor method for APNs device token that wasn't successfully enrolled yet.
   Can be used to check whether is enrolled token is expired.
   */
  func getAPNSToken() -> String?
  /**
   Accessor method for APNs device token that wasn't successfully enrolled yet.
   Can be used to check whether is enrolled token is expired.
   */
  func setAPNSToken(_ apnsToken: String?)
  
  /**
   Accessor method for APNs device token that was successfully enrolled.
   Can be used to check whether is enrolled token is expired.
   */
  func getRegisteredAPNSToken() -> String?
  /**
   Accessor method for APNs device token that was successfully enrolled.
   Can be used to check whether is enrolled token is expired.
   */
  func setRegisteredAPNSToken(_ apnsToken: String?)
  
  /**
   Accessor method for default gift card.
   */
  func getDefaultCard() -> BEGiftCard?
  /**
   Accessor method for default gift card.
   */
  func saveDefaultCard(_ card : BEGiftCard?)
  
  /**
   Accessor method for stored available rewards.
   */
  func getRewards() -> [BECoupon]?
  /**
   Accessor method for stored available rewards.
   */
  func saveRewards(_ rewards : [BECoupon]?)
  
  /**
   Method for clearing any session-related data.
   */
  func clearSession()
  /**
   Method for clearing APNs-related data.
   */
  func clearApnsTokens()
}
