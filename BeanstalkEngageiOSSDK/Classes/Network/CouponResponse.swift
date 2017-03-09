//
//  CouponResponse.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import ObjectMapper


open class CouponResponse <CouponClass: BECoupon> : Mappable {
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
