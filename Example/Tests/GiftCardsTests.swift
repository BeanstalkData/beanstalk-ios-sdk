//
//  GiftCardsTests.swift
//  BeanstalkEngageiOSSDK
//
//  Created by Pavel Dvorovenko on 2/8/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import BeanstalkEngageiOSSDK
import BeanstalkEngageiOSSDK_Example
import Pods_BeanstalkEngageiOSSDK_Tests

class GiftCardsTests: BEGiftCardsTests {
  let testsMetadata = TestsMetadata()
  
  override func getMetadata() -> BEBaseTestsMetadataProtocol? {
    return testsMetadata
  }
  
  func testGiftCards() {
    giftCardsTest()
  }
  
  func testGiftCardParsing() {
    giftCardParsingTest()
  }
  
  func testGiftCardBalanceParsing() {
    giftCardBalanceParsingTest()
  }
  
  func testGiftCardStartPayment() {
    giftCardStartPaymentTest(nil, coupons: []){ (contectText, dispalyText) in
      XCTAssert(contectText == self.getSession()?.getContactId(), "Gift card start payment failed")
      XCTAssert(dispalyText == "Member ID: "+(self.getSession()?.getContactId())!, "Gift card start payment failed")
    }
  }
}
