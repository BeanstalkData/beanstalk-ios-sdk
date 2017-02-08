//
//  BEBalanceAmount.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/12/17.
//
//

import Foundation

import ObjectMapper

public class BEBalanceAmount: Mappable {
  var amount: Double?
  
  required public init?(_ map: Map) {
    self.mapping(map)
  }
  
  public func mapping(map: Map) {
    amount <- map["amount"]
  }
}
