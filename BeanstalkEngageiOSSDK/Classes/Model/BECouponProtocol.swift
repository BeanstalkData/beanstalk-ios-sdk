//
//  BECouponProtocol.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/19/18.
//
//

import Foundation
import ObjectMapper

public protocol BECouponProtocol: NSObjectProtocol, BaseMappable {
  
  var number: String? { get }
  var expiration: String? { get }
  var text: String? { get }
  var imageUrl: String? { get }
  var imageAUrl: String? { get }
  var receiptText: String? { get }
  var discountCode: String? { get }
  
  func getDisplayExpiration(_ formatter: DateFormatter) -> String?
}
