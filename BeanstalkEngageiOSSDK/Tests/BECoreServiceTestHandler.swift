//
//  BECoreServiceTestHandler.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/4/17.
//
//

import Foundation
import CoreLocation
import XCTest

public class BECoreServiceTestHandler {
  
  let testCase: BEBaseTestCase
  
  public class func create(testCase: BEBaseTestCase) -> BECoreServiceTestHandler{
    let coreServiceTestHandler = BECoreServiceTestHandler(testCase: testCase)
    
    return coreServiceTestHandler
  }
  
  private init(testCase: BEBaseTestCase) {
    self.testCase = testCase
  }
  
  /* User */
  
  public func autoSignIn(handler : (Bool) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var signInStatus = false
    self.testCase.getCoreService()?.autoSignIn(nil, contactClass: BEContact.self, handler: { (success) in
      signInStatus = success
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(signInStatus)
    
    return self
  }
  
  public func signIn(email: String, password: String, handler : (Bool) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var signInStatus = false
    self.testCase.getCoreService()?.authenticate(nil, email: email, password: password, contactClass: BEContact.self, handler: { (success, additionalInfo) in
      
      signInStatus = success
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(signInStatus)
    
    return self
  }
  
  public func signOut(handler : (Bool) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var signOutStatus = false
    self.testCase.getCoreService()?.logout(nil, handler: { (success) in
      
      signOutStatus = success
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(signOutStatus)
    
    return self
  }
  
  public func resetPassword(email: String, handler : (Bool) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var resetPasswordStatus = false
    self.testCase.getCoreService()?.resetPassword(nil, email: email, handler: { (result) in
      
      resetPasswordStatus = result
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(resetPasswordStatus)
    
    return self
  }
  
  public func updatePassword(password: String, handler : (Bool) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var updatePasswordStatus = false
    self.testCase.getCoreService()?.updatePassword(nil, password: password, confirmPassword: password, handler: { (result) in
      updatePasswordStatus = result
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(updatePasswordStatus)
    
    return self
  }
  
  public func registerLoyaltyAccount(request: CreateContactRequest, handler : (Bool) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var registerStatus = false
    self.testCase.getCoreService()?.registerLoyaltyAccount(nil, request: request, contactClass: BEContact.self, handler: { (result) in
      
      registerStatus = result
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(registerStatus)
    
    return self
  }
  
  public func registerAccount(request: CreateContactRequest, handler : (Bool) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var registerStatus = false
    self.testCase.getCoreService()?.register(nil, request: request, contactClass: BEContact.self, handler: { (result) in
      
      registerStatus = result
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(registerStatus)
    
    return self
  }
  
  public func getContact(handler : (BEContact?) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var contact: BEContact?
    self.testCase.getCoreService()?.getContact(nil, contactClass: BEContact.self, handler: { result in
      contact = result
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(contact)
    
    return self
  }

  public func updateContact(contact: BEContact, request : UpdateContactRequest, handler : (Bool) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var updateStatus = false
    self.testCase.getCoreService()?.updateContact(nil, original: contact, request : request, handler : { result in

      updateStatus = result

      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(updateStatus)
    
    return self
  }
  
  public func getContact <ContactClass: BEContact> (contactClass: ContactClass.Type, handler : (ContactClass?) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var contact: ContactClass?
    self.testCase.getCoreService()?.getContact(nil, contactClass: contactClass, handler: { result in
      contact = result as? ContactClass
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(contact)
    
    return self
  }
  
  // Rewards
  
  public func getAvailableRewards <CouponClass: BECoupon> (couponClass: CouponClass.Type, handler : (Bool, [CouponClass]) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var resultStatus = false
    var resultCoupons: [CouponClass] = []
    self.testCase.getCoreService()?.getAvailableRewards(nil, couponClass: couponClass, handler: { (success, result) in
      resultStatus = success
      if let coupons = result as? [CouponClass] {
        resultCoupons = coupons
      }
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(resultStatus, resultCoupons)
    
    return self
  }

  public func getProgress (handler : (Bool, Int, String) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var resultStatus = false
    var resultCount = 0
    var resultText = ""
    self.testCase.getCoreService()?.getUserProgress(nil, handler: { (success, count, text) in
      resultStatus = success
      resultCount = count
      resultText = text
      
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(resultStatus, resultCount, resultText)
    
    return self
  }
  
  // Gift cards
  
  public func getGiftCards <GiftCardClass: BEGiftCard> (giftCardClass: GiftCardClass.Type, handler : (Bool, [GiftCardClass]) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var resultStatus = false
    var resultGiftCards: [GiftCardClass] = []
    self.testCase.getCoreService()?.getGiftCards(nil, giftCardClass: giftCardClass, handler: { (success, result) in
      resultStatus = success
      if let giftCards = result as? [GiftCardClass] {
        resultGiftCards = giftCards
      }
      
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(resultStatus, resultGiftCards)
    
    return self
  }
  
  public func startPayment (cardId: String?, coupons: [BECoupon], handler : (String, String) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var contentText = ""
    var displayText = ""
    self.testCase.getCoreService()?.startPayment(nil, cardId: cardId, coupons: coupons, handler: { (content, display) in
      
      contentText = content
      displayText = display
      
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(contentText, displayText)
    
    return self
  }
  
  // Stores
  
  public func getStoresAtLocation <StoreClass: BEStore> (coordinate: CLLocationCoordinate2D?, storeClass: StoreClass.Type, handler : (Bool, [BEStore]?) -> Void) -> BECoreServiceTestHandler? {
    self.testCase.prepare()
    
    var locationStatus = false
    var locationStores: [BEStore]? = nil
    self.testCase.getCoreService()?.getStoresAtLocation(nil, coordinate: coordinate, storeClass: storeClass, handler: { (success, stores) in
      
      locationStatus = success
      locationStores = stores
      
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(locationStatus, locationStores)
    
    return self
  }
}
