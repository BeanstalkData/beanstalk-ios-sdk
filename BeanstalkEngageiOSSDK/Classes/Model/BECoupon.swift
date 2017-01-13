//
//  BECoupon.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/12/17.
//
//

import Foundation

import ObjectMapper

public class BECoupon : Mappable {
  private static let kOriginalDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
  private static let kDisplayDateFormat = "MM/dd/yyyy"
  public var number: String?
  public var expiration: String?
  public var text: String?
  public var imageUrl: String?
  
  //for mocks only
  init(imageUrl: String) {
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
  
  
  public func getDisplayExpiration(formatter: NSDateFormatter) -> String? {
    guard let expirationString = self.expiration else {
      return nil
    }
    
    formatter.dateFormat = BECoupon.kOriginalDateFormat
    if let date = formatter.dateFromString(expirationString) {
      formatter.dateFormat = BECoupon.kDisplayDateFormat
      
      return formatter.stringFromDate(date)
    }
    
    return nil
  }
  
  public func getImageURL() -> NSURL? {
    if let imageUrlString = self.imageUrl {
      if let URL = NSURL(string: imageUrlString) {
        return URL
      }
    }
    
    return nil
  }
}
