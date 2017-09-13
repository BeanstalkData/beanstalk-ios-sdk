//
//  LocalizationTests.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import BeanstalkEngageiOSSDK
import XCTest

class LocalizationTests: BELocalizablesTests {
  let testsMetadata = TestsMetadata()
  
  func testLocalizables() {
    localizablesTest()
    
    XCTAssert(Localized(key: LocKey.continue_process) == "Continue")
    XCTAssert(Localized(key: LocKey.sorry_an_error_occurred_while_processing_your_request) == "Sorry")
    
    XCTAssert(Localized(key: LocKey.wrong_key) == "wrong_key")
  }

}
