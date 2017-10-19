//
//  BEStoresTests.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import CoreLocation
import XCTest

open class BEStoresTests: BEBaseTestCase {
  
  open func allStoresTest <StoreClass> (version: String?, storeClass: StoreClass.Type) -> [BEStoreProtocol]? where StoreClass: BEStoreProtocol {
    
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    var storesResult: [BEStoreProtocol]? = nil
    
    coreServiceHandler.signIn(getMetadata()!.getRegisteredUser1Email(), password: getMetadata()!.getRegisteredUser1Password()) { (result) in
      XCTAssert(result, "Login request finished with error")
      
      if (result) {
        var coordinate = self.getMetadata()!.getInvalidLocationCoordinate()
        
        coreServiceHandler.getStoresAtLocation(coordinate, version: version, storeClass: storeClass) { (result, stores) in
          XCTAssert(result, "Get stores at location finished with error")
          
          storesResult = stores
        }
      }
    }
    
    return storesResult
  }
  
  open func allStoresAtLocationTest <StoreClass> (version: String?, storeClass: StoreClass.Type) -> [BEStoreProtocol]? where StoreClass: BEStoreProtocol {
    
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    var storesResult: [BEStoreProtocol]? = nil
    
    coreServiceHandler.signIn(getMetadata()!.getRegisteredUser1Email(), password: getMetadata()!.getRegisteredUser1Password()) { (result) in
      XCTAssert(result, "Login request finished with error")
      
      if (result) {
        var coordinate = self.getMetadata()!.getValidLocationCoordinate()
        
        coreServiceHandler.getStoresAtLocation(coordinate, version: version, storeClass: storeClass) { (result, stores) in
          XCTAssert(result, "Get stores at location finished with error")
          
          storesResult = stores
        }
      }
    }
    
    return storesResult
  }
}
