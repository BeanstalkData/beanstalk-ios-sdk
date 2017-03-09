//
//  RewardsTests.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import BeanstalkEngageiOSSDK
import BeanstalkEngageiOSSDK_Example
import Pods_BeanstalkEngageiOSSDK_Tests

class RewardsTests: BERewardsTests {
  let testsMetadata = TestsMetadata()

  override func getMetadata() -> BEBaseTestsMetadataProtocol? {
    return testsMetadata
  }
  
  func testAvailableRewards() {
    availableRewardsTest()
  }
  
  func testRewardsParsing() {
    rewardParsingTest()
  }
  
  func testRewardsProgress() {
    rewardsProgressTest()
  }
  
  func testRewardsCountParsing() {
    rewardsCountParsingTest()
  }
}
