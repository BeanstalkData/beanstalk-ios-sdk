//
//  StoresTests.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import BeanstalkEngageiOSSDK
import Pods_BeanstalkEngageiOSSDK_Tests

class StoresTests: BEStoresTests {
  let testsMetadata = TestsMetadata()
  
  override func getMetadata() -> BEBaseTestsMetadataProtocol? {
    return testsMetadata
  }
  
  func testAllStores() {
    allStoresTest(BEStore.self)
  }
  
  func testStoresAtLocation() {
    allStoresAtLocationTest(BEStore.self)
  }
}
