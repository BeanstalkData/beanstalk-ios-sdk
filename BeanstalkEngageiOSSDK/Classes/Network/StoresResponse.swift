//
//  StoresResponse.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public protocol StoresResponseProtocol {
  func failed() -> Bool
  
  func getStores() -> [BEStore]?
}

public class StoresResponse : Mappable, StoresResponseProtocol {
  private var status : Bool?
  
  var stores : [BEStore]?
  
  required public init?(_ map: Map) {
    
  }
  
  public func mapping(map: Map) {
    status <- map["status"]
    stores <- map["stores"]
  }
  
  public func failed() -> Bool{
    if status == nil || !(status!) {
      return true
    }
    
    return false
  }
  
  public func getStores() -> [BEStore]?{
    return stores
  }
}

