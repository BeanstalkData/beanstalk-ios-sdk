//
//  BEBalanceAmount.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//
//

import Foundation

import ObjectMapper

open class BEBalanceAmount: Mappable {
  var amount: Double?
  
  required public init?(map: Map) {
  }
  
  open func mapping(map: Map) {
    amount <- map["amount"]
  }
}
