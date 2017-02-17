//
//  BECoupon.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/12/17.
//
//

import Foundation

import ObjectMapper

public class BECoupon : NSObject, NSCoding, Mappable {
  private static let kOriginalDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
  private static let kDisplayDateFormat = "MM/dd/yyyy"
  
  private static let kObject = "BECoupon" + "_object"
  private static let kNumber = "BECoupon" + "_number"
  private static let kExpiration = "BECoupon" + "_expiration"
  private static let kText = "BECoupon" + "_text"
  private static let kImageUrl = "BECoupon" + "_imageUrl"
  
  public var number: String?
  public var expiration: String?
  public var text: String?
  public var imageUrl: String?
  
  //for mocks only
  init(imageUrl: String) {
    super.init()
    self.imageUrl = imageUrl
  }
  
  required public init?(_ map: Map) {
    super.init()
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
  
  //MARK: - Persistence store -
  
  class public func initList(storage : NSUserDefaults) -> [BECoupon] {
    
    var couponList: [BECoupon]?
    if let list = storage.objectForKey(BECoupon.kObject) as? NSData {
      couponList = NSKeyedUnarchiver.unarchiveObjectWithData(list) as? [BECoupon]
    }
    
    if couponList == nil {
      couponList = []
    }
    
    return couponList!
  }
  
  class public func clearList(storage : NSUserDefaults) {
    storage.setObject(nil, forKey: BECoupon.kObject)
    
    storage.synchronize()
  }
  
  class public func saveList(list : [BECoupon], storage : NSUserDefaults) {
    storage.setObject(NSKeyedArchiver.archivedDataWithRootObject(list), forKey: BECoupon.kObject)
    
    storage.synchronize()
  }
  
  //MARK: - NSCoding -
  required public init(coder aDecoder: NSCoder) {
    self.number = aDecoder.decodeObjectForKey(BECoupon.kNumber) as? String
    self.expiration = aDecoder.decodeObjectForKey(BECoupon.kExpiration) as? String
    self.text = aDecoder.decodeObjectForKey(BECoupon.kText) as? String
    self.imageUrl = aDecoder.decodeObjectForKey(BECoupon.kImageUrl) as? String
  }
  
  public func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(number, forKey: BECoupon.kNumber)
    aCoder.encodeObject(expiration, forKey: BECoupon.kExpiration)
    aCoder.encodeObject(text, forKey: BECoupon.kText)
    aCoder.encodeObject(imageUrl, forKey: BECoupon.kImageUrl)
  }
}
