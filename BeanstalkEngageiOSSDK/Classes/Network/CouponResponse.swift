//
//  CouponResponse.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import ObjectMapper


public class CouponResponse : Mappable {
  var coupons: [BECoupon]?
  
  //for mocks only
  init(coupons: [BECoupon]) {
    self.coupons = coupons
  }
  
  required public init?(_ map: Map) {
    
  }
  
  public func mapping(map: Map) {
    coupons <- map["Coupon"]
  }
}
