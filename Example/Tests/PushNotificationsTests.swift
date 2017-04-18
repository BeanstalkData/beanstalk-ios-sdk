//
//  PushNotificationsTests.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation

import BeanstalkEngageiOSSDK
import BeanstalkEngageiOSSDK_Example
import Pods_BeanstalkEngageiOSSDK_Tests

class PushNotificationsTests: BEPushNotificationsTests {
  let testsMetadata = TestsMetadata()
  
  override func getMetadata() -> BEBaseTestsMetadataProtocol? {
    return testsMetadata
  }
  
  func testGetPushNotificationMessages() {
    getPushNotificationMessagesTest()
  }
  
}
