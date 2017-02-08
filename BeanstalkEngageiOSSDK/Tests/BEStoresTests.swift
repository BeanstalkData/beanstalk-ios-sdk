//
//  BEStoresTests.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/31/17.
//
//

import Foundation
import CoreLocation
import XCTest

import Timberjack

public class BEStoresTests: BEBaseTestCase {

  public override func setUp() {
    super.setUp()
    
    Timberjack.register()
  }
  
  public override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
    
    Timberjack.unregister()
  }
  
  public func allStoresTest <StoreClass: BEStore> (storeClass: StoreClass.Type) -> [BEStore]? {
    
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    var storesResult: [BEStore]? = nil
    
    coreServiceHandler.signIn(getMetadata()!.getRegisteredUser1Email(), password: getMetadata()!.getRegisteredUser1Password()) { (result) in
      XCTAssert(result, "Login request finished with error");
      
      if (result) {
        var coordinate = self.getMetadata()!.getInvalidLocationCoordinate()
        
        coreServiceHandler.getStoresAtLocation(coordinate, storeClass: storeClass) { (result, stores) in
          XCTAssert(result, "Get stores at location finished with error")
          
          storesResult = stores
        }
      }
    }
    
    return storesResult
  }
  
  public func allStoresAtLocationTest <StoreClass: BEStore> (storeClass: StoreClass.Type) -> [BEStore]? {
    
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    var storesResult: [BEStore]? = nil
    
    coreServiceHandler.signIn(getMetadata()!.getRegisteredUser1Email(), password: getMetadata()!.getRegisteredUser1Password()) { (result) in
      XCTAssert(result, "Login request finished with error");
      
      if (result) {
        var coordinate = self.getMetadata()!.getValidLocationCoordinate()
        
        coreServiceHandler.getStoresAtLocation(coordinate, storeClass: storeClass) { (result, stores) in
          XCTAssert(result, "Get stores at location finished with error")
          
          storesResult = stores
        }
      }
    }
    
    return storesResult
  }
}
