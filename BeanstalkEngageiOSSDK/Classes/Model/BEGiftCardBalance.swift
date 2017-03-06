//
//  BEGiftCardBalance.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/12/17.
//
//

import Foundation

import ObjectMapper

public class BEGiftCardBalance: Mappable {
  var balanceAmount: BEBalanceAmount?
  
  required public init?(_ map: Map) {
  }
  
  public func mapping(map: Map) {
    balanceAmount <- map["balanceAmount"]
  }
}
