//
//  SessionTests.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
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
  
  func testContactSession() {
    contactSessionTest()
  }
}
