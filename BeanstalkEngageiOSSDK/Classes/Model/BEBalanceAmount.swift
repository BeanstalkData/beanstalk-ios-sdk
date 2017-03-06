//
//  BEBalanceAmount.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/12/17.
//
//

import Foundation

import ObjectMapper

open class BEBalanceAmount: Mappable {
  var amount: Double?
  
  required public init?(map: Map) {
    self.mapping(map: map)
  }
  
  open func mapping(map: Map) {
    amount <- map["amount"]
  }
}
