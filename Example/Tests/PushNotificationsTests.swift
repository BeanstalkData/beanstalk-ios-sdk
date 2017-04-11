//
//  PushNotificationsTests.swift
//  BeanstalkEngageiOSSDK
//
//  Created by Pavel Dvorovenko on 4/11/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
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
