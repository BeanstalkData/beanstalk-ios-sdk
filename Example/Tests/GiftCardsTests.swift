//
//  GiftCardsTests.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
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
    giftCardStartPaymentTest(nil, coupons: []){ (barCodeInfo) in
      XCTAssert(barCodeInfo.data == (self.getSession()?.getContactId())!, "Gift card start payment failed")
    }
  }
}
