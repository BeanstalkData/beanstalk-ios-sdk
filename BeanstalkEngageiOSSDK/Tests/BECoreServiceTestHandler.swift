//
//  BECoreServiceTestHandler.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import CoreLocation
import XCTest

open class BECoreServiceTestHandler {
  
  let testCase: BEBaseTestCase
  
  open class func create(_ testCase: BEBaseTestCase) -> BECoreServiceTestHandler{
    let coreServiceTestHandler = BECoreServiceTestHandler(testCase: testCase)
    
    return coreServiceTestHandler
  }
  
  fileprivate init(testCase: BEBaseTestCase) {
    self.testCase = testCase
  }
  
  /* User */
  
  open func autoSignIn(_ handler : (Bool) -> Void) -> BECoreServiceTestHandler? {
    
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
  
  @discardableResult open func signIn(_ email: String, password: String, handler : (Bool) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var signInStatus = false
    self.testCase.getCoreService()?.authenticate(nil, email: email, password: password, contactClass: BEContact.self, handler: { (success) in
      
      signInStatus = success
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(signInStatus)
    
    return self
  }
  
  open func signOut(_ handler : (Bool) -> Void) -> BECoreServiceTestHandler? {
    
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
  
  open func resetPassword(_ email: String, handler : (Bool) -> Void) -> BECoreServiceTestHandler? {
    
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
  
  open func updatePassword(_ password: String, handler : (Bool) -> Void) -> BECoreServiceTestHandler? {
    
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
  
  open func registerLoyaltyAccount(_ request: ContactRequest, handler : (Bool) -> Void) -> BECoreServiceTestHandler? {
    
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
  
  open func registerAccount(_ request: ContactRequest, handler : (Bool) -> Void) -> BECoreServiceTestHandler? {
    
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
  
  open func getContact(_ handler : (BEContact?) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var contact: BEContact?
    self.testCase.getCoreService()?.getContact(nil, contactClass: BEContact.self, handler: { (success, result) in
      contact = result
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(contact)
    
    return self
  }

  @discardableResult open func updateContact(_ contact: BEContact, request : ContactRequest, handler : (Bool) -> Void) -> BECoreServiceTestHandler? {
    
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
  
  @discardableResult open func getContact <ContactClass: BEContact> (_ contactClass: ContactClass.Type, handler : (ContactClass?) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var contact: ContactClass?
    self.testCase.getCoreService()?.getContact(nil, contactClass: contactClass, handler: { (success,result) in
      contact = result
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(contact)
    
    return self
  }
  
  // Rewards
  
  open func getAvailableRewards <CouponClass: BECoupon> (_ couponClass: CouponClass.Type, handler : (Bool, [CouponClass]) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var resultStatus = false
    var resultCoupons: [CouponClass] = []
    self.testCase.getCoreService()?.getAvailableRewardsForCouponClass(nil, couponClass: couponClass, handler: { (success, result) in
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

  open func getProgress (_ handler : (Bool, Int, String) -> Void) -> BECoreServiceTestHandler? {
    
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
  
  open func getGiftCards <GiftCardClass: BEGiftCard> (_ giftCardClass: GiftCardClass.Type, handler : (Bool, [GiftCardClass]) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var resultStatus = false
    var resultGiftCards: [GiftCardClass] = []
    self.testCase.getCoreService()?.getGiftCardsForGiftCardClass(nil, giftCardClass: giftCardClass, handler: { (success, result) in
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
  
  open func startPayment (_ cardId: String?, coupons: [BECoupon], handler : (String, String) -> Void) -> BECoreServiceTestHandler? {
    
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
  
  open func getStoresAtLocation <StoreClass: BEStore> (_ coordinate: CLLocationCoordinate2D?, storeClass: StoreClass.Type, handler : (Bool, [BEStore]?) -> Void) -> BECoreServiceTestHandler? {
    self.testCase.prepare()
    
    var locationStatus = false
    var locationStores: [BEStore]? = nil
    self.testCase.getCoreService()?.getStoresAtLocationForStoreClass(nil, coordinate: coordinate, storeClass: storeClass, handler: { (success, stores) in
      
      locationStatus = success
      locationStores = stores
      
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(locationStatus, locationStores)
    
    return self
  }
}
