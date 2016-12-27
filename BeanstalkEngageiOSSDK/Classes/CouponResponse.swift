//
//  CouponResponse.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class CouponResponse : Mappable {
  var coupons : [Coupon]?
  
  //for mocks only
  init(coupons: [Coupon]){
    self.coupons = coupons
  }
  
  required public init?(_ map: Map) {
    
  }
  
  public func mapping(map: Map) {
    coupons <- map["Coupon"]
  }
}

public class Coupon : Mappable {
  private static let kOriginalDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
  private static let kDisplayDateFormat = "MM/dd/yyyy"
  public var number: String?
  public var expiration: String?
  public var text: String?
  private var imageUrl : String?
  
  //for mocks only
  init(imageUrl :String){
    self.imageUrl = imageUrl
  }
  
  required public init?(_ map: Map) {
    
  }
  
  public func mapping(map: Map) {
    number <- map["CouponNo"]
    expiration <- map["ExpirationDate"]
    text <- map["CouponText"]
    imageUrl <- map["Image"]
  }
  
  public func getDisplayExpiration(formatter : NSDateFormatter) -> String{
    do {
      formatter.dateFormat = Coupon.kOriginalDateFormat
      let date = formatter.dateFromString(expiration!)!
      formatter.dateFormat = Coupon.kDisplayDateFormat
      return formatter.stringFromDate(date)
    } catch {
      return ""
    }
  }
  
  public func getImageUrl() -> String {
    return imageUrl!;
  }
}
