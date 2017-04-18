//
//  BETransaction.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import ObjectMapper


public struct BETransaction: Mappable {
  public var transactionId: String = ""
  
  public init?(map: Map) {
    guard let id = map["id"] as? String, id.lengthOfBytes(using: .utf8) > 0 else {
      return nil
    }
  }
  
  // for mock usage only
  init(transactionId: String) {
    self.transactionId = transactionId
  }
  
  public mutating func mapping(map: Map) {
    transactionId <- map["id"]
  }
}
