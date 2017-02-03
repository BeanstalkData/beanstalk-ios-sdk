//
//  StoresTests.swift
//  BeanstalkEngageiOSSDK
//
//  Created by Pavel Dvorovenko on 2/3/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import BeanstalkEngageiOSSDK
import Pods_BeanstalkEngageiOSSDK_Tests

class StoresTests: BEStoresTests {
  let testsMetadata = TestsMetadata()
  
  override func getMetadata() -> BEBaseTestsMetadataProtocol? {
    return testsMetadata
  }
  
  func testAllStores() {
    allStoresTest()
  }
  
  func testStoresAtLocation() {
    allStoresAtLocationTest()
  }
}
