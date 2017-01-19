//
//  AccountTests.swift
//  BeanstalkEngageiOSSDK
//
//  Created by Pavel Dvorovenko on 1/19/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import BeanstalkEngageiOSSDK
import Pods_BeanstalkEngageiOSSDK_Tests

class AccountTests: BEAccountTests {
  let testsMetadata = TestsMetadata()
  
  override func getMetadata() -> BEBaseTestsMetadataProtocol? {
    return testsMetadata
  }
  
  func testLoginRegisteredUser() {
    loginRegisteredUserTest()
  }
  
  func testLoginRegisteredUserWithValidPush() {
    loginRegisteredUserWithValidPushTest()
  }
  
  func testLoginRegisteredUserWithInvalidPush() {
    loginRegisteredUserWithInvalidPushTest()
  }
  
  func testRegisterLoyaltyAccount() {
    registerLoyaltyAccountTest()
  }
  
  func testRegisterAccount() {
    registerAccountTest()
  }
}
