//
//  SessionTests.swift
//  BeanstalkEngageiOSSDK
//
//  Created by Pavel Dvorovenko on 1/23/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import BeanstalkEngageiOSSDK
import Pods_BeanstalkEngageiOSSDK_Tests

class SessionTests: BESessionTests {
  let testsMetadata = TestsMetadata()
  
  override func getMetadata() -> BEBaseTestsMetadataProtocol? {
    return testsMetadata
  }
  
  func testUserSession() {
    userSessionTest()
  }
  
  func testClearSession() {
    clearSessionTest()
  }
  
  func testGiftCardSession() {
    giftCardSessionTest()
  }
}
