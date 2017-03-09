//
//  BEGiftCardBalance.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation

import ObjectMapper

open class BEGiftCardBalance: Mappable {
  var balanceAmount: BEBalanceAmount?
  
  required public init?(map: Map) {
  }
  
  open func mapping(map: Map) {
    balanceAmount <- map["balanceAmount"]
  }
}
