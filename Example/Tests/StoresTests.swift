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
    _ = allStoresTest(version: nil, storeClass: BEStore.self)
  }
  
  func testStoresAtLocation() {
    _ = allStoresAtLocationTest(version: nil, storeClass: BEStore.self)
  }
  
  func testAllStoresV2() {
    _ = allStoresTest(version: "2", storeClass: BEStoreV2.self)
  }
}
