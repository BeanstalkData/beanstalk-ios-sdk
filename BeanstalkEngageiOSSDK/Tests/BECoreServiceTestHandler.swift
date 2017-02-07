//
//  BECoreServiceTestHandler.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/4/17.
//
//

import Foundation
import CoreLocation
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
  
  public func getContact(handler : (BEContact?) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var contact: BEContact?
    self.testCase.getCoreService()?.getContact(nil, handler: { result in
      contact = result
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(contact)
    
    return self
  }

  public func getContact <ContactClass: BEContact> (contactClass: ContactClass.Type, handler : (ContactClass?) -> Void) -> BECoreServiceTestHandler? {
    
    self.testCase.prepare()
    
    var contact: ContactClass?
    self.testCase.getCoreService()?.getContact(nil, contactClass: contactClass, handler: { result in
      contact = result as? ContactClass
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(contact)
    
    return self
  }

  
  // Stores
  
  public func getStoresAtLocation(coordinate: CLLocationCoordinate2D?, handler : (Bool, [BEStore]?) -> Void) -> BECoreServiceTestHandler? {
    self.testCase.prepare()
    
    var locationStatus = false
    var locationStores: [BEStore]? = nil
    self.testCase.getCoreService()?.getStoresAtLocation(nil, coordinate: coordinate, handler: { (success, stores) in
      
      locationStatus = success
      locationStores = stores
      
      self.testCase .fullfill()
    })
    
    self.testCase.wait()
    
    handler(locationStatus, locationStores)
    
    return self
  }
}
