//
//  BESessionTests.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/23/17.
//
//

import Foundation
import XCTest

public class BESessionTests: BEBaseTestCase {
  
  public override func setUp() {
    super.setUp()
  }
  
  public override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  public func userSessionTest() {
    
    self.getSession()?.setContactId(String(getMetadata()!.getRegisteredUser1Contact().contactId!))
    self.getSession()?.setAuthToke("12c893b776668ed4384b5ff0e91ab4a3f3fb5867")
    self.getSession()?.setAPNSToken(getMetadata()!.getValidAPNSToken())
    self.getSession()?.setRegisteredAPNSToken(getMetadata()!.getValidAPNSToken())
    self.getSession()?.saveDefaultCard(getMetadata()!.getRegisteredUser1GiftCard())
    
    XCTAssert(String(getMetadata()!.getRegisteredUser1Contact().contactId!) == self.getSession()?.getContactId())
    XCTAssert(self.getSession()?.getAuthToken() == "12c893b776668ed4384b5ff0e91ab4a3f3fb5867")
    XCTAssert(self.getSession()?.getAPNSToken() == getMetadata()!.getValidAPNSToken())
    XCTAssert(self.getSession()?.getRegisteredAPNSToken() == getMetadata()!.getValidAPNSToken())
    XCTAssert(self.getSession()?.getDefaultCard() != nil)
    XCTAssert(String(getMetadata()!.getRegisteredUser1GiftCard().id!) == self.getSession()?.getDefaultCard()?.id)
    
    self.getSession()?.setContactId(nil)
    self.getSession()?.setAuthToke(nil)
    self.getSession()?.setAPNSToken(nil)
    self.getSession()?.setRegisteredAPNSToken(nil)
    
    XCTAssert(self.getSession()?.getContactId() == nil)
    XCTAssert(self.getSession()?.getAuthToken() == nil)
    XCTAssert(self.getSession()?.getAPNSToken() == nil)
    XCTAssert(self.getSession()?.getRegisteredAPNSToken() == nil)
  }
  
  public func clearSessionTest() {
    self.getSession()?.setContactId(String(getMetadata()!.getRegisteredUser1Contact().contactId!))
    self.getSession()?.setAuthToke("12c893b776668ed4384b5ff0e91ab4a3f3fb5867")
    self.getSession()?.setAPNSToken(getMetadata()!.getValidAPNSToken())
    self.getSession()?.setRegisteredAPNSToken(getMetadata()!.getValidAPNSToken())
    self.getSession()?.saveDefaultCard(getMetadata()!.getRegisteredUser1GiftCard())
    
    XCTAssert(String(getMetadata()!.getRegisteredUser1Contact().contactId!) == self.getSession()?.getContactId())
    XCTAssert(self.getSession()?.getAuthToken() == "12c893b776668ed4384b5ff0e91ab4a3f3fb5867")
    XCTAssert(self.getSession()?.getAPNSToken() == getMetadata()!.getValidAPNSToken())
    XCTAssert(self.getSession()?.getRegisteredAPNSToken() == getMetadata()!.getValidAPNSToken())
    XCTAssert(self.getSession()?.getDefaultCard() != nil)
    XCTAssert(String(getMetadata()!.getRegisteredUser1GiftCard().id!) == self.getSession()?.getDefaultCard()?.id)
    
    self.session?.clearSession()
    self.session?.clearApnsTokens()
    
    XCTAssert(self.getSession()?.getContactId() == nil)
    XCTAssert(self.getSession()?.getAuthToken() == nil)
    XCTAssert(self.getSession()?.getAPNSToken() == nil)
    XCTAssert(self.getSession()?.getRegisteredAPNSToken() == nil)
    XCTAssert(self.getSession()?.getDefaultCard() == nil)
  }
  
  public func giftCardSessionTest() {
    
    self.getSession()?.saveDefaultCard(getMetadata()!.getRegisteredUser1GiftCard())
    
    let giftCard = self.getSession()?.getDefaultCard()
    
    XCTAssert(giftCard != nil)
    XCTAssert(giftCard?.id == getMetadata()!.getRegisteredUser1GiftCard().id)
    XCTAssert(giftCard?.number == getMetadata()!.getRegisteredUser1GiftCard().number)
    XCTAssert(giftCard?.balance == getMetadata()!.getRegisteredUser1GiftCard().balance)
    
    self.getSession()?.saveDefaultCard(nil)
    let giftCardNil = self.getSession()?.getDefaultCard()

    XCTAssert(giftCardNil == nil)
  }
}
