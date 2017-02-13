//
//  BESession.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/12/17.
//
//

import Foundation

public typealias BESession = BESessionT<BEUserDefaults>

public class BESessionT<UserDefaults: BEUserDefaults> {
  
  required public init() {
  }
  
  public func clearSession() {
    setContact(nil)
    setAuthToke(nil)
    saveDefaultCard(nil)
    setRegisteredAPNSToken(nil)
  }
  
  public func clearApnsTokens() {
    setAPNSToken(nil)
    setRegisteredAPNSToken(nil)
  }
  
  public func getContactId() -> String? {
    let prefs = UserDefaults.getTransientDefaults()
    
    var contact = BEContact(storage: prefs)
    
    guard contact?.contactId != nil else {
      return nil
    }
    
    return String(contact!.contactId!)
  }
  
  public func getContact <ContactClass: BEContact> () -> ContactClass? {
    let prefs = UserDefaults.getTransientDefaults()
    
    var contact = ContactClass(storage: prefs)
    
    return contact
  }
  
  public func setContact(contact: BEContact?) {
    let prefs = UserDefaults.getTransientDefaults()
    if contact != nil {
      contact?.save(prefs)
    } else {
      BEContact.clear(prefs)
    }
    prefs.synchronize()
  }
  
  public func getAuthToken() -> String? {
    let prefs = UserDefaults.getTransientDefaults()
    return prefs.objectForKey(DataKeys.TOKEN_KEY) as? String
  }
  
  public func setAuthToke(token: String?) {
    let prefs = UserDefaults.getTransientDefaults()
    if token != nil {
      prefs.setObject(token, forKey: DataKeys.TOKEN_KEY)
    } else {
      prefs.removeObjectForKey(DataKeys.TOKEN_KEY)
    }
    prefs.synchronize()
  }
  
  public func getAPNSToken() -> String? {
    let prefs = UserDefaults.getTransientDefaults()
    return prefs.objectForKey(DataKeys.DEVICE_TOKEN) as? String
  }
  
  public func setAPNSToken(apnsToken: String?) {
    let prefs = UserDefaults.getTransientDefaults()
    if (apnsToken != nil) {
      prefs.setObject(apnsToken, forKey: DataKeys.DEVICE_TOKEN)
    } else {
      prefs.removeObjectForKey(DataKeys.DEVICE_TOKEN)
    }
    prefs.synchronize()
  }
  
  public func getRegisteredAPNSToken() -> String? {
    let prefs = UserDefaults.getTransientDefaults()
    return prefs.objectForKey(DataKeys.REGISTERED_DEVICE_TOKEN) as? String
  }
  
  public func setRegisteredAPNSToken(apnsToken: String?) {
    let prefs = UserDefaults.getTransientDefaults()
    if apnsToken != nil {
      prefs.setObject(apnsToken, forKey: DataKeys.REGISTERED_DEVICE_TOKEN)
    } else {
      prefs.removeObjectForKey(DataKeys.REGISTERED_DEVICE_TOKEN)
    }
    prefs.synchronize()
  }
  
  public func getDefaultCard() -> BEGiftCard? {
    let prefs = UserDefaults.getTransientDefaults()
    var giftCard = BEGiftCard(storage: prefs)
    
    if giftCard?.id == nil {
      giftCard = nil
    }
    
    return giftCard
  }
  
  public func saveDefaultCard(card : BEGiftCard?){
    let prefs = UserDefaults.getTransientDefaults()
    if (card != nil) {
      card?.save(prefs)
    } else {
      BEGiftCard.clear(prefs)
    }
    prefs.synchronize()
  }
}

public class BEUserDefaults: NSUserDefaults {
  public class func getTransientDefaults() -> NSUserDefaults {
    return NSUserDefaults.standardUserDefaults()
  }
}

private struct DataKeys{
  static let TOKEN_KEY = "_token"
  static let DEVICE_TOKEN = "_device_token"
  static let REGISTERED_DEVICE_TOKEN = "_registered_device_token"
}
