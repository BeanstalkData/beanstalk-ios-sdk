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
  
  open func autoSignIn(_ handler: (_ success: Bool) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var signInStatus = false
    self.testCase.getCoreService()?.autoSignIn(contactClass: BEContact.self, handler: { (success, error) in
      signInStatus = success
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(signInStatus)
    
    return self
  }
  
  @discardableResult open func signIn(_ email: String, password: String, handler: (_ success: Bool) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var signInStatus = false
    self.testCase.getCoreService()?.authenticate(email: email, password: password, contactClass: BEContact.self, handler: { (success, error) in
      
      signInStatus = success
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(signInStatus)
    
    return self
  }
  
  open func signOut(_ handler: (_ success: Bool) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var signOutStatus = false
    self.testCase.getCoreService()?.logout(handler: { (success, error) in
      
      signOutStatus = success
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(signOutStatus)
    
    return self
  }
  
  open func resetPassword(_ email: String, handler: (_ success: Bool) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var resetPasswordStatus = false
    self.testCase.getCoreService()?.resetPassword(email: email, handler: { (success, error) in
      
      resetPasswordStatus = success
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(resetPasswordStatus)
    
    return self
  }
  
  open func updatePassword(_ password: String, handler: (_ success: Bool) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var updatePasswordStatus = false
    self.testCase.getCoreService()?.updatePassword(password: password, confirmPassword: password, handler: { (success, error) in
      updatePasswordStatus = success
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(updatePasswordStatus)
    
    return self
  }
  
  open func registerLoyaltyAccount(_ request: ContactRequest, handler: (_ success: Bool) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var registerStatus = false
    self.testCase.getCoreService()?.registerLoyaltyAccount(request: request, contactClass: BEContact.self, handler: { (success, error) in
      
      registerStatus = success
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(registerStatus)
    
    return self
  }
  
  open func registerAccount(_ request: ContactRequest, handler: (_ success: Bool) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var registerStatus = false
    self.testCase.getCoreService()?.register(request: request, contactClass: BEContact.self, handler: { (success, error) in
      
      registerStatus = success
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(registerStatus)
    
    return self
  }
  
  open func getContact(_ handler: (_ contact: BEContact?) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var contact: BEContact?
    self.testCase.getCoreService()?.getContact(contactClass: BEContact.self, handler: { (success, result, error) in
      contact = result
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(contact)
    
    return self
  }

  @discardableResult open func updateContact(request : ContactRequest, handler: (_ success: Bool) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var updateStatus = false
    self.testCase.getCoreService()?.updateContact(request: request, contactClass: BEContact.self, handler: { (success, _, error) in
      updateStatus = success
      
      self.testCase.fullfill()
    })
    
    self.testCase.wait()
    
    handler(updateStatus)
    
    return self
  }
  
  @discardableResult open func getContact <ContactClass: BEContact> (_ contactClass: ContactClass.Type, handler: (_ contact: ContactClass?) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var contact: ContactClass?
    self.testCase.getCoreService()?.getContact(contactClass: contactClass, handler: { (success, result, error) in
      contact = result
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(contact)
    
    return self
  }
  
  // Rewards
  
  open func getAvailableRewards <CouponClass: BECoupon> (_ couponClass: CouponClass.Type, handler: (_ success: Bool, _ coupons: [CouponClass]) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var resultStatus = false
    var resultCoupons: [CouponClass] = []
    self.testCase.getCoreService()?.getAvailableRewards(couponClass: couponClass, handler: { (success, result, error) in
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

  open func getProgress (_ handler: (_ progress: Double?, _ error: BEErrorType?) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var value: Double?
    var apiError: BEErrorType?
    
    self.testCase.getCoreService()?.getUserProgress(handler: { (success, progresValue, error) in
      value = progresValue
      apiError = error
      
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(value, apiError)
    
    return self
  }
  
  // Gift cards
  
  open func getGiftCards <GiftCardClass: BEGiftCard> (_ giftCardClass: GiftCardClass.Type, handler: (_ success: Bool, _ cards: [GiftCardClass]) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var resultStatus = false
    var resultGiftCards: [GiftCardClass] = []
    self.testCase.getCoreService()?.getGiftCards(giftCardClass: giftCardClass, handler: { (success, result, error) in
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
  
  open func startPayment (_ cardId: String?, coupons: [BECoupon], handler: (_ info: BarCodeInfo) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var barCodeInfo = BarCodeInfo(data: "", type: .memberId)
    self.testCase.getCoreService()?.startPayment(cardId: cardId, coupons: coupons, handler: { (success, info, error) in
      
      barCodeInfo = info
      
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(barCodeInfo)
    
    return self
  }
  
  // Stores
  
  open func getStoresAtLocation <StoreClass> (_ coordinate: CLLocationCoordinate2D?, version: String?, storeClass: StoreClass.Type, handler: (_ success: Bool, _ stores: [BEStoreProtocol]?) -> Void) -> BECoreServiceTestHandler? where StoreClass: BEStoreProtocol {
    self.testCase.prepare()
    
    var locationStatus = false
    var locationStores: [BEStoreProtocol]? = nil
    self.testCase.getCoreService()?.getStoresAtLocation(coordinate: coordinate, version: version, storeClass: storeClass, handler: { (success, stores, error) in
      
      locationStatus = success
      locationStores = stores
      
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(locationStatus, locationStores)
    
    return self
  }
  
  // Push notifications
  
  open func getPushNotificationMessages (maxResults: Int, handler: (_ success: Bool, _ messages: [BEPushNotificationMessage]?) -> Void) -> BECoreServiceTestHandler? {
    self.testCase.prepare()
    
    var pushNotificationMessagesStatus = false
    var pushNotificationMessages: [BEPushNotificationMessage]? = nil
    self.testCase.getCoreService()?.pushNotificationGetMessages(maxResults: maxResults, handler: { (success, messages, error) in
      pushNotificationMessagesStatus = (error == nil)
      pushNotificationMessages = messages
      
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(pushNotificationMessagesStatus, pushNotificationMessages)
    
    return self
  }
}
