//
//  BESession.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/12/17.
//
//

import Foundation

public class BESession {
  
  public init() {
  }
  
  public func clearSession() {
    setContactId(nil)
    setAuthToke(nil)
    saveDefaultCard(nil)
    setRegisteredAPNSToken(nil)
  }
  
  public func clearApnsTokens() {
    setAPNSToken(nil)
    setRegisteredAPNSToken(nil)
  }
  
  public func getContactId() -> String? {
    let prefs = NSUserDefaults.standardUserDefaults()
    return prefs.valueForKey(DataKeys.CONTACT_KEY) as? String
  }
  
  public func setContactId(contactId: String?) {
    let prefs = NSUserDefaults.standardUserDefaults()
    prefs.setValue(contactId, forKey: DataKeys.CONTACT_KEY)
    prefs.synchronize()
  }
  
  public func getAuthToken() -> String? {
    let prefs = NSUserDefaults.standardUserDefaults()
    return prefs.valueForKey(DataKeys.TOKEN_KEY) as? String
  }
  
  public func setAuthToke(token: String?) {
    let prefs = NSUserDefaults.standardUserDefaults()
    prefs.setValue(token, forKey: DataKeys.TOKEN_KEY)
    prefs.synchronize()
  }
  
  public func getAPNSToken() -> String? {
    let prefs = NSUserDefaults.standardUserDefaults()
    return prefs.valueForKey(DataKeys.DEVICE_TOKEN) as? String
  }
  
  public func setAPNSToken(apnsToken: String?) {
    let prefs = NSUserDefaults.standardUserDefaults()
    prefs.setValue(apnsToken, forKey: DataKeys.DEVICE_TOKEN)
    prefs.synchronize()
  }
  
  public func getRegisteredAPNSToken() -> String? {
    let prefs = NSUserDefaults.standardUserDefaults()
    return prefs.valueForKey(DataKeys.REGISTERED_DEVICE_TOKEN) as? String
  }
  
  public func setRegisteredAPNSToken(apnsToken: String?) {
    let prefs = NSUserDefaults.standardUserDefaults()
    prefs.setValue(apnsToken, forKey: DataKeys.REGISTERED_DEVICE_TOKEN)
    prefs.synchronize()
  }
  
  public func getDefaultCard() -> BEGiftCard? {
    let prefs = NSUserDefaults.standardUserDefaults()
    var giftCard = BEGiftCard(storage: prefs)
    
    if giftCard?.id == nil {
      giftCard = nil
    }
    
    return giftCard
  }
  
  public func saveDefaultCard(card : BEGiftCard?){
    let prefs = NSUserDefaults.standardUserDefaults()
    if (card != nil) {
      card?.save(prefs)
    } else {
      BEGiftCard.clear(prefs)
    }
    prefs.synchronize()
  }
  
  private struct DataKeys{
    static let TOKEN_KEY = "_token"
    static let CONTACT_KEY = "_contact_id"
    static let DEVICE_TOKEN = "_device_token"
    static let REGISTERED_DEVICE_TOKEN = "_registered_device_token"
  }
}
