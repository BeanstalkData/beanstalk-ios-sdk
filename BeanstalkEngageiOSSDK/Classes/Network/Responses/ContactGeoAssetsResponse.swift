//
//  ContactGeoAssetsResponse.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public struct ContactGeoAssetsResponse: Mappable {
  public var defaultImageUrl: String?
  public var currentImageUrl: String?
  
  public init?(map: Map) {
    
  }
  
  public mutating func mapping(map: Map) {
    defaultImageUrl <- map["DefaultImage"]
    currentImageUrl <- map["CurrentImage"]
  }
}
