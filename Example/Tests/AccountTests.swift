//
//  AccountTests.swift
//  BeanstalkEngageiOSSDK
//
//  Created by Pavel Dvorovenko on 1/19/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import BeanstalkEngageiOSSDK
import BeanstalkEngageiOSSDK_Example
import Pods_BeanstalkEngageiOSSDK_Tests

class AccountTests: BEAccountTests {
  let testsMetadata = TestsMetadata()
  
  override func getMetadata() -> BEBaseTestsMetadataProtocol? {
    return testsMetadata
  }
  
  func testLoginRegisteredUser() {
    loginRegisteredUserTest()
  }
  
  func testAutoLoginRegisteredUser() {
    autoLoginRegisteredUserTest()
  }
  
  func testAutoLoginUnRegisteredUser() {
    autoLoginUnRegisteredUserTest()
  }
  
  func testLoginRegisteredUserWithValidPush() {
    loginRegisteredUserWithValidPushTest()
  }
  
  func testLoginRegisteredUserWithInvalidPush() {
    loginRegisteredUserWithInvalidPushTest()
  }
  
  func testResetPassword() {
    resetPasswordTest()
  }
  
  func testUpdatePassword() {
    updatePasswordTest()
  }
  
  func testRegisterLoyaltyAccount() {
    registerLoyaltyAccountTest()
  }
  
  func testLoyaltyAccountParsing() {
    loyaltyAccountParsingTest()
  }
  
  func testRegisterAccount() {
    registerAccountTest()
  }
  
  func testGetContact() {
    getContactTest(ContactModel.self)
  }
  
  func testUpdateContact() {
    updateContactTest(ContactModel.self)
  }
}
