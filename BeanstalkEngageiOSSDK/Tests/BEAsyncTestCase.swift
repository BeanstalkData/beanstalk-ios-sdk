//
//  BEAsyncTestCase.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import UIKit
import XCTest

open class BEAsyncTestCase: XCTestCase {

  fileprivate let kAsyncTimeout = TimeInterval(30)
  fileprivate var expectation: XCTestExpectation!
  
  open func prepare() {
    expectation = expectation(description: "BEAsyncTestCase_expectation")
  }
  
  open func fullfill() {
    self.expectation.fulfill()
  }
  
  open func wait(_ timeout: TimeInterval) -> Bool {
    var error: NSError?
    waitForExpectations(timeout: kAsyncTimeout, handler: { err in
      error = err as NSError?
      XCTAssertNil(err)
    })
    
    return (error == nil)
  }
  
  open func wait() -> Bool {
    return self.wait(kAsyncTimeout)
  }
}
