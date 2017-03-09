//
//  StoresResponse.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public protocol StoresResponseProtocol {
  func failed() -> Bool
  
  func getStores() -> [BEStore]?
}

open class StoresResponse<StoreClass: BEStore> : Mappable, StoresResponseProtocol {
  fileprivate var status : Bool?
  
  var stores : [StoreClass]?
  
  required public init?(map: Map) {
    
  }
  
  open func mapping(map: Map) {
    status <- map["status"]
    stores <- map["stores"]
  }
  
  open func failed() -> Bool{
    if status == nil || !(status!) {
      return true
    }
    
    return false
  }
  
  open func getStores() -> [BEStore]?{
    return stores
  }
}

