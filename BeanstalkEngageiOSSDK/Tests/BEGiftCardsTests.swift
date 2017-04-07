//
//  BEGiftCardsTests.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import XCTest

import ObjectMapper

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


open class BEGiftCardsTests: BEBaseTestCase {
  
  open func giftCardsTest() {
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    coreServiceHandler.signIn(getMetadata()!.getRegisteredUser1Email(), password: getMetadata()!.getRegisteredUser1Password()) { (result) in
      XCTAssert(result, "Login request finished with error")
      
      if (result) {
        coreServiceHandler.getGiftCards(BEGiftCard.self, handler: { (success, giftCards) in
          XCTAssert(success, "Failed to get gift cards")
        })
      }
    }
  }
  
  open func giftCardParsingTest() {
    let JSON: [String: Any] = [
      "status":true, "success":["code":2,"message":["response":["success":true,"cards":[["Id":7,"contactId":8554570,"customerId":171,"cardNumber":"6276000001329907735","pin":695,"expirationDate":"Jan  1 1900 12:00:00:000AM","active":1]]]]]
    ]
    
    let map = Map(mappingType: .fromJSON, JSON: JSON)
    var giftCardsResponce = GCResponse(map: map)
    giftCardsResponce?.mapping(map: map)
    
    XCTAssert(giftCardsResponce?.failed() == false, "Gift card responce object is invalid")
    XCTAssert(giftCardsResponce?.getCards()?.count == 1, "Gift card responce objects count is invalid")
    
    if (giftCardsResponce?.getCards()?.count > 0) {
      let giftCard = giftCardsResponce?.getCards()?[0]
      
      XCTAssert(giftCard?.id == "7", "Gift card object is invalid")
      XCTAssert(giftCard?.number == "6276000001329907735", "Gift card object is invalid")
      XCTAssert(giftCard?.balance == nil, "Gift card object is invalid")
      XCTAssert(giftCard?.getDisplayNumber() == "XXXXXXXXXXXX7735", "Gift card object formatting is invalid")
      XCTAssert(giftCard?.getDisplayBalanse() == BEGiftCard.kDefaultBalance, "Gift card object formatting is invalid")
    }
  }

  open func giftCardBalanceParsingTest() {
    let JSON: [String: Any] = [
      "status":true,"success":["code":2,"message":["response":["balanceInquiryReturn":["authorizationCode":"006035","balanceAmount":["amount":60.35,"currency":"USD"],"card":["cardCurrency":"840","cardNumber":"6276000001329907735","pinNumber":"0695    ","cardExpiration": NSNull(),"cardTrackOne": NSNull(),"cardTrackTwo": NSNull(),"eovDate":"20500101T0500Z"],"conversionRate":"1.000000","returnCode":["returnCode":"01","returnDescription":"Approval"],"stan":"176149","transactionID":""]]]]
    ]
    
    let map = Map(mappingType: .fromJSON, JSON: JSON)
    var giftCardBalanceResponce = GCBResponse(map: map)
    giftCardBalanceResponce?.mapping(map: map)
    
    XCTAssert(giftCardBalanceResponce?.getCardBalance() == "$60.35", "Gift card balance objects count is invalid")
  }
  
  open func giftCardStartPaymentTest(_ cardId: String?, coupons: [BECoupon], handler: @escaping (BarCodeInfo) -> Void) {
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    coreServiceHandler.signIn(getMetadata()!.getRegisteredUser1Email(), password: getMetadata()!.getRegisteredUser1Password()) { (result) in
      XCTAssert(result, "Login request finished with error")
      
      coreServiceHandler.startPayment(cardId, coupons: coupons, handler: handler)
    }
  }
}

