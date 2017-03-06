//
//  BESessionTests.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/23/17.
//
//

import Foundation
import XCTest

open class BESessionTests: BEBaseTestCase {
  
  open override func setUp() {
    super.setUp()
  }
  
  open override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  open func userSessionTest() {
    
    self.getSession()?.setContact(getMetadata()!.getRegisteredUser1Contact())
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
    
    self.getSession()?.setContact(nil)
    self.getSession()?.setAuthToke(nil)
    self.getSession()?.setAPNSToken(nil)
    self.getSession()?.setRegisteredAPNSToken(nil)
    
    XCTAssert(self.getSession()?.getContactId() == nil)
    XCTAssert(self.getSession()?.getAuthToken() == nil)
    XCTAssert(self.getSession()?.getAPNSToken() == nil)
    XCTAssert(self.getSession()?.getRegisteredAPNSToken() == nil)
  }
  
  open func clearSessionTest() {
    self.getSession()?.setContact(getMetadata()!.getRegisteredUser1Contact())
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
  
  open func giftCardSessionTest() {
    
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
  
  open func contactSessionTest() {
    
    self.getSession()?.setContact(getMetadata()!.getRegisteredUser1Contact())
    
    let contact = self.getSession()?.getContact()
    
    XCTAssert(contact != nil)
    XCTAssert(contact?.contactId == getMetadata()!.getRegisteredUser1Contact().contactId)
    XCTAssert(contact?.firstName == getMetadata()!.getRegisteredUser1Contact().firstName)
    XCTAssert(contact?.lastName == getMetadata()!.getRegisteredUser1Contact().lastName)
    XCTAssert(contact?.zipCode == getMetadata()!.getRegisteredUser1Contact().zipCode)
    XCTAssert(contact?.email == getMetadata()!.getRegisteredUser1Contact().email)
    XCTAssert(contact?.prospect == getMetadata()!.getRegisteredUser1Contact().prospect)
    XCTAssert(contact?.gender == getMetadata()!.getRegisteredUser1Contact().gender)
    XCTAssert(contact?.birthday == getMetadata()!.getRegisteredUser1Contact().birthday)
    XCTAssert(contact?.fKey == getMetadata()!.getRegisteredUser1Contact().fKey)
    XCTAssert(contact?.phone == getMetadata()!.getRegisteredUser1Contact().phone)
    XCTAssert(contact?.textOptin == getMetadata()!.getRegisteredUser1Contact().textOptin)
    XCTAssert(contact?.emailOptin == getMetadata()!.getRegisteredUser1Contact().emailOptin)
    XCTAssert(contact?.pushNotificationOptin == getMetadata()!.getRegisteredUser1Contact().pushNotificationOptin)
    XCTAssert(contact?.inboxMessageOptin == getMetadata()!.getRegisteredUser1Contact().inboxMessageOptin)
    XCTAssert(contact?.novadine == getMetadata()!.getRegisteredUser1Contact().novadine)
    
    self.getSession()?.setContact(nil)
    let contactNill = self.getSession()?.getContact()
    
    XCTAssert(contactNill == nil)
  }
}
