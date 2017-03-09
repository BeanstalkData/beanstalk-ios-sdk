//
//  BESession.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation

open class BESession {
  
  fileprivate let userDefaults: BEUserDefaults
  
  public init(userDefaults: BEUserDefaults = BEUserDefaults()) {
    self.userDefaults = userDefaults
  }
  
  open func getUserDefaults() -> BEUserDefaults {
    return self.userDefaults
  }
  
  open func clearSession() {
    setContact(nil)
    setAuthToke(nil)
    saveDefaultCard(nil)
    saveRewards(nil)
    setRegisteredAPNSToken(nil)
  }
  
  open func clearApnsTokens() {
    setAPNSToken(nil)
    setRegisteredAPNSToken(nil)
  }
  
  open func getContactId() -> String? {
    let prefs = self.userDefaults.getTransientDefaults()
    
    var contact = BEContact(storage: prefs)
    
    guard contact?.contactId != nil else {
      return nil
    }
    
    return String(contact!.contactId!)
  }
  
  open func getContact <ContactClass: BEContact> () -> ContactClass? {
    let prefs = self.userDefaults.getTransientDefaults()
    
    var contact = ContactClass(storage: prefs)
    
    return contact
  }
  
  open func setContact(_ contact: BEContact?) {
    let prefs = self.userDefaults.getTransientDefaults()
    if contact != nil {
      contact?.save(prefs)
    } else {
      BEContact.clear(prefs)
    }
  }
  
  open func getAuthToken() -> String? {
    let prefs = self.userDefaults.getTransientDefaults()
    return prefs.object(forKey: DataKeys.TOKEN_KEY) as? String
  }
  
  open func setAuthToke(_ token: String?) {
    let prefs = self.userDefaults.getTransientDefaults()
    if token != nil {
      prefs.set(token, forKey: DataKeys.TOKEN_KEY)
    } else {
      prefs.removeObject(forKey: DataKeys.TOKEN_KEY)
    }
    prefs.synchronize()
  }
  
  open func getAPNSToken() -> String? {
    let prefs = self.userDefaults.getTransientDefaults()
    return prefs.object(forKey: DataKeys.DEVICE_TOKEN) as? String
  }
  
  open func setAPNSToken(_ apnsToken: String?) {
    let prefs = self.userDefaults.getTransientDefaults()
    if (apnsToken != nil) {
      prefs.set(apnsToken, forKey: DataKeys.DEVICE_TOKEN)
    } else {
      prefs.removeObject(forKey: DataKeys.DEVICE_TOKEN)
    }
    prefs.synchronize()
  }
  
  open func getRegisteredAPNSToken() -> String? {
    let prefs = self.userDefaults.getTransientDefaults()
    return prefs.object(forKey: DataKeys.REGISTERED_DEVICE_TOKEN) as? String
  }
  
  open func setRegisteredAPNSToken(_ apnsToken: String?) {
    let prefs = self.userDefaults.getTransientDefaults()
    if apnsToken != nil {
      prefs.set(apnsToken, forKey: DataKeys.REGISTERED_DEVICE_TOKEN)
    } else {
      prefs.removeObject(forKey: DataKeys.REGISTERED_DEVICE_TOKEN)
    }
    prefs.synchronize()
  }
  
  open func getDefaultCard() -> BEGiftCard? {
    let prefs = self.userDefaults.getTransientDefaults()
    var giftCard = BEGiftCard(storage: prefs)
    
    if giftCard?.id == nil {
      giftCard = nil
    }
    
    return giftCard
  }
  
  open func saveDefaultCard(_ card : BEGiftCard?){
    let prefs = self.userDefaults.getTransientDefaults()
    if (card != nil) {
      card?.save(prefs)
    } else {
      BEGiftCard.clear(prefs)
    }
  }
  
  open func getRewards() -> [BECoupon]? {
    let prefs = self.userDefaults.getTransientDefaults()
    var rewards = BECoupon.initList(prefs)
    
    return rewards
  }
  
  open func saveRewards(_ rewards : [BECoupon]?){
    let prefs = self.userDefaults.getTransientDefaults()
    if (rewards != nil) {
      BECoupon.saveList(rewards!, storage: prefs)
    } else {
      BECoupon.clearList(prefs)
    }
  }
}

open class BEUserDefaults: UserDefaults {
  open func getTransientDefaults() -> UserDefaults {
    return UserDefaults.standard
  }
}

private struct DataKeys{
  static let TOKEN_KEY = "_token"
  static let DEVICE_TOKEN = "_device_token"
  static let REGISTERED_DEVICE_TOKEN = "_registered_device_token"
}
