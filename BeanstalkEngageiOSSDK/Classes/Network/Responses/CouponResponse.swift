//
//  CouponResponse.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import ObjectMapper


/**
 Response model for coupon request.
 */
open class CouponResponse <CouponClass> : Mappable where CouponClass: BECouponProtocol {
  var coupons: [CouponClass]?
  
  //for mocks only
  init(coupons: [CouponClass]) {
    self.coupons = coupons
  }
  
  required public init?(map: Map) {
    
  }
  
  open func mapping(map: Map) {
    coupons <- map["Coupon"]
  }
}
