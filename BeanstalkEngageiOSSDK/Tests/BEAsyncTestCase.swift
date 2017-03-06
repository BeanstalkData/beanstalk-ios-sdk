//
//  BEAsyncTestCase.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/4/17.
//
//

import UIKit
import XCTest

open class BEAsyncTestCase: XCTestCase {

  fileprivate let kAsyncTimeout = TimeInterval(30)
  fileprivate var expectation: XCTestExpectation!
  
  open func prepare() {
    expectation = XCTestExpectation()
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
