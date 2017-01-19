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
    
    handler(signInStatus)
    
    return self
  }
  
  public func signOut(handler : (Bool) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var signOutStatus = false
    self.testCase.getCoreService()?.logout(nil, handler: { (success) in
      
      signOutStatus = success
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(signOutStatus)
    
    return self
  }
  
  public func registerLoyaltyAccount(request: CreateContactRequest, handler : (Bool) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var registerStatus = false
    self.testCase.getCoreService()?.registerLoyaltyAccount(nil, request: request, handler: { (result) in
      
      registerStatus = result
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(registerStatus)
    
    return self
  }
  
  public func registerAccount(request: CreateContactRequest, handler : (Bool) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var registerStatus = false
    self.testCase.getCoreService()?.register(nil, request: request, handler: { (result) in
      
      registerStatus = result
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(registerStatus)
    
    return self
  }
}
