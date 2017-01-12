//
//  BECoreServiceTestHandler.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/4/17.
//
//

import Foundation
import XCTest

public class BECoreServiceTestHandler {
  
  let testCase: BEBaseTestCase
  
  public class func create(testCase: BEBaseTestCase) -> BECoreServiceTestHandler{
    let coreServiceTestHandler = BECoreServiceTestHandler(testCase: testCase)
    
    return coreServiceTestHandler
  }
  
  private init(testCase: BEBaseTestCase) {
    self.testCase = testCase
  }
  
  /* User */
  public func signIn(email: String, password: String, handler : (Bool) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var signInStatus = false
    self.testCase.getCoreService()?.authenticate(nil, email: email, password: password, handler: { (success, additionalInfo) in
      
      signInStatus = success
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    XCTAssert(signInStatus, "Login request finished with error");
    
    handler(signInStatus)
    
    return signInStatus ? nil : self;
  }
}
