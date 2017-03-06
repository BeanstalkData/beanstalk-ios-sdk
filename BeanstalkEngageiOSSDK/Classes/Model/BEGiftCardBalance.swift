//
//  BEGiftCardBalance.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/12/17.
//
//

import Foundation

import ObjectMapper

open class BEGiftCardBalance: Mappable {
  var balanceAmount: BEBalanceAmount?
  
  required public init?(map: Map) {
    self.mapping(map: map)
  }
  
  open func mapping(map: Map) {
    balanceAmount <- map["balanceAmount"]
  }
}
