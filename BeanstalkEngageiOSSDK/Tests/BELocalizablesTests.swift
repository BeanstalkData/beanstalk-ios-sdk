//
//  BELocalizablesTests.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import XCTest

open class BELocalizablesTests: BEBaseTestCase {
  
  open override func setUp() {
    super.setUp()
  }
  
  open override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  open func localizablesTest() {
    XCTAssert(Localized(key: BELocKey.sorry_an_error_occurred_while_processing_your_request) == "Sorry, an error occurred while processing your request")
  }
}
