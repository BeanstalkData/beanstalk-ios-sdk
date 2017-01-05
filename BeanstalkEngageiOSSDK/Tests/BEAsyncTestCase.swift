//
//  BEAsyncTestCase.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/4/17.
//
//

import UIKit
import XCTest

public class BEAsyncTestCase: XCTestCase {

  private let kAsyncTimeout = NSTimeInterval(30)
  private var expectation: XCTestExpectation!
  
  public func prepare() {
    expectation = self.expectationWithDescription("BEAsyncTestCase_expectation")
  }
  
  public func fullfill() {
    self.expectation.fulfill()
  }
  
  public func wait(timeout: NSTimeInterval) -> Bool {
    var error: NSError?
    waitForExpectationsWithTimeout(kAsyncTimeout, handler: { err in
      error = err
      XCTAssertNil(err)
    })
    
    return (error == nil)
  }
  
  public func wait() -> Bool {
    return self.wait(kAsyncTimeout)
  }
}
