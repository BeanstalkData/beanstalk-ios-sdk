//
//  GiftCardsTests.swift
//  BeanstalkEngageiOSSDK
//
//  Created by Pavel Dvorovenko on 2/8/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

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
}
