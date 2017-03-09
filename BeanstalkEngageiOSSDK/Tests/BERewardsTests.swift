//
//  BERewardsTests.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import XCTest

import ObjectMapper
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


open class BERewardsTests: BEBaseTestCase {
  
  open func availableRewardsTest() {
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    coreServiceHandler.signIn(getMetadata()!.getRegisteredUser1Email(), password: getMetadata()!.getRegisteredUser1Password()) { (result) in
      XCTAssert(result, "Login request finished with error");
      
      if (result) {
        coreServiceHandler.getAvailableRewards(BECoupon.self) { (success, coupons) in
          XCTAssert(success, "Failed to get available rewards")
        }
      }
    }
  }
  
  open func rewardParsingTest() {
    let JSON: [String: Any] = [
      "Coupon":[
        [
          "CouponNo":"Registration Free Side Item_31609_4642",
          "CouponText":"Free Side Item",
          "CreationDate":"2012-11-19T00:00:00",
          "ExpirationDate":"2012-11-19T00:00:00",
          "DiscountPct":"0.00",
          "DiscountAmt":"0.00",
          "MaxDiscountAmt":"0.00",
          "DiscountCode":"10011",
          "CouponReceiptText":"Enjoy a Free Item",
          "CouponHandlingAttributes":"0",
          "Image": "https://s3.amazonaws.com/beanstalkloyalty_images/209/10011.png",
          "AImage": "https://s3.amazonaws.com/beanstalkloyalty_images/209/10011.png"
        ]
      ]
    ]
  
    let map = Map(mappingType: .fromJSON, JSON: JSON)
    var couponResponce = CouponResponse(map: map)
    couponResponce?.mapping(map: map)
    
    XCTAssert(couponResponce?.coupons?.count == 1, "Coupon objects count is invalid")
    
    if (couponResponce?.coupons?.count > 0) {
      let coupon = couponResponce?.coupons?[0]
      
      XCTAssert(coupon?.number == "Registration Free Side Item_31609_4642", "Coupon object is invalid")
      XCTAssert(coupon?.expiration == "2012-11-19T00:00:00", "Coupon object is invalid")
      XCTAssert(coupon?.text == "Free Side Item", "Coupon object is invalid")
      XCTAssert(coupon?.imageUrl == "https://s3.amazonaws.com/beanstalkloyalty_images/209/10011.png", "Coupon object is invalid")
      XCTAssert(coupon?.getDisplayExpiration(DateFormatter()) == "11/19/2012", "Coupon object formatting is invalid")
      XCTAssert(coupon?.getImageURL()?.absoluteString == "https://s3.amazonaws.com/beanstalkloyalty_images/209/10011.png",  "Coupon object formatting is invalid")
    }
  }
  
  open func rewardsProgressTest() {
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    coreServiceHandler.signIn(getMetadata()!.getRegisteredUser1Email(), password: getMetadata()!.getRegisteredUser1Password()) { (result) in
      XCTAssert(result, "Login request finished with error");
      
      if (result) {
        coreServiceHandler.getProgress({ (success, count, text) in
          XCTAssert(success, "Failed to get users' progress")
        })
      }
    }
  }
  
  open func rewardsCountParsingTest() {
    let JSON: [String: Any] = ["Category":[["Name":"Orders","Count":"1"]]]
    
    let map = Map(mappingType: .fromJSON, JSON: JSON)
    var rewardsCountResponce = RewardsCountResponse(map: map)
    rewardsCountResponce?.mapping(map: map)
    
    XCTAssert(rewardsCountResponce?.getCount() == 1, "Rewards count is invalid")
  }
  
}
