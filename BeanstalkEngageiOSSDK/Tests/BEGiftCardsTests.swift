//
//  BEGiftCardsTests.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 2/8/17.
//
//

import Foundation
import XCTest

import ObjectMapper
import Timberjack

public class BEGiftCardsTests: BEBaseTestCase {
  
  public override func setUp() {
    super.setUp()
    
    Timberjack.register()
  }
  
  public override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
    
    Timberjack.unregister()
  }
  
  public func giftCardsTest() {
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    coreServiceHandler.signIn(getMetadata()!.getRegisteredUser1Email(), password: getMetadata()!.getRegisteredUser1Password()) { (result) in
      XCTAssert(result, "Login request finished with error");
      
      if (result) {
        coreServiceHandler.getGiftCards(BEGiftCard.self, handler: { (success, giftCards) in
          XCTAssert(success, "Failed to get gift cards")
        })
      }
    }
  }
  
  public func giftCardParsingTest() {
    let JSON: [String: AnyObject] = [
      "status":true,"success":["code":2,"message":["response":["success":true,"cards":[["Id":7,"contactId":8554570,"customerId":171,"cardNumber":"6276000001329907735","pin":695,"expirationDate":"Jan  1 1900 12:00:00:000AM","active":1]]]]]
    ]
    
    let map = Map(mappingType: .FromJSON, JSONDictionary: JSON)
    var giftCardsResponce = GCResponse(map)
    
    XCTAssert(giftCardsResponce?.failed() == false, "Gift card responce object is invalid")
    XCTAssert(giftCardsResponce?.getCards()?.count == 1, "Gift card responce objects count is invalid")
    
    if (giftCardsResponce?.getCards()?.count > 0) {
      let giftCard = giftCardsResponce?.getCards()?[0]
      
      XCTAssert(giftCard?.id == "7", "Gift card object is invalid")
      XCTAssert(giftCard?.number == "6276000001329907735", "Gift card object is invalid")
      XCTAssert(giftCard?.balance == nil, "Gift card object is invalid")
    }
  }

  
}

