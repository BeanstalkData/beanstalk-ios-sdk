//
//  BECoupon.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation

import ObjectMapper

/**
 Model of reward coupon.
 */
open class BECoupon : NSObject, NSCoding, Mappable, BECouponProtocol {
  fileprivate static let kOriginalDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
  fileprivate static let kDisplayDateFormat = "MM/dd/yyyy"
  
  fileprivate static let kObject = "BECoupon" + "_object"
  fileprivate static let kNumber = "BECoupon" + "_number"
  fileprivate static let kExpiration = "BECoupon" + "_expiration"
  fileprivate static let kText = "BECoupon" + "_text"
  fileprivate static let kImageUrl = "BECoupon" + "_imageUrl"
  fileprivate static let kImageAUrl = "BECoupon" + "_imageAUrl"
  fileprivate static let kReceiptText = "BECoupon" + "_receiptText"
  fileprivate static let kDiscountCode = "BECoupon" + "_discountCode"
  
  open var number: String?
  open var expiration: String?
  open var text: String?
  open var imageUrl: String?
  open var imageAUrl: String?
  open var receiptText: String?
  open var discountCode: String?
  
  //for mocks only
  init(imageUrl: String) {
    super.init()
    self.imageUrl = imageUrl
  }
  
  required public init?(map: Map) {
    super.init()
  }
  
  open func mapping(map: Map) {
    number <- map["CouponNo"]
    expiration <- map["ExpirationDate"]
    text <- map["CouponText"]
    imageUrl <- map["Image"]
    imageAUrl <- map["AImage"]
    receiptText <- map["CouponReceiptText"]
    discountCode <- map["DiscountCode"]
  }
  
  
  open func getDisplayExpiration(_ formatter: DateFormatter) -> String? {
    guard let expirationString = self.expiration else {
      return nil
    }
    
    formatter.dateFormat = BECoupon.kOriginalDateFormat
    if let date = formatter.date(from: expirationString) {
      formatter.dateFormat = BECoupon.kDisplayDateFormat
      
      return formatter.string(from: date)
    }
    
    return nil
  }
  
  open func getImageURL() -> URL? {
    if let imageUrlString = self.imageUrl {
      if let URL = URL(string: imageUrlString) {
        return URL
      }
    }
    
    return nil
  }
  
  //MARK: - NSCoding -
  required public init(coder aDecoder: NSCoder) {
    self.number = aDecoder.decodeObject(forKey: BECoupon.kNumber) as? String
    self.expiration = aDecoder.decodeObject(forKey: BECoupon.kExpiration) as? String
    self.text = aDecoder.decodeObject(forKey: BECoupon.kText) as? String
    self.imageUrl = aDecoder.decodeObject(forKey: BECoupon.kImageUrl) as? String
    self.imageAUrl = aDecoder.decodeObject(forKey: BECoupon.kImageAUrl) as? String
    self.receiptText = aDecoder.decodeObject(forKey: BECoupon.kReceiptText) as? String
    self.discountCode = aDecoder.decodeObject(forKey: BECoupon.kDiscountCode) as? String
  }
  
  open func encode(with aCoder: NSCoder) {
    aCoder.encode(number, forKey: BECoupon.kNumber)
    aCoder.encode(expiration, forKey: BECoupon.kExpiration)
    aCoder.encode(text, forKey: BECoupon.kText)
    aCoder.encode(imageUrl, forKey: BECoupon.kImageUrl)
    aCoder.encode(imageAUrl, forKey: BECoupon.kImageAUrl)
    aCoder.encode(receiptText, forKey: BECoupon.kReceiptText)
    aCoder.encode(discountCode, forKey: BECoupon.kDiscountCode)
  }
}

public extension BECoupon {
  //MARK: - Persistence store -
  
  class public func initList<CouponClass : BECouponProtocol>(_ storage : UserDefaults, couponClass: CouponClass.Type) -> [CouponClass] {
    
    var couponList: [CouponClass]?
    if let list = storage.object(forKey: BECoupon.kObject) as? Data {
      couponList = NSKeyedUnarchiver.unarchiveObject(with: list) as? [CouponClass]
    }
    
    if couponList == nil {
      couponList = []
    }
    
    return couponList!
  }
  
  class public func clearList(_ storage : UserDefaults) {
    storage.set(nil, forKey: BECoupon.kObject)
    
    storage.synchronize()
  }
  
  class public func saveList(_ list : [BECouponProtocol], storage : UserDefaults) {
    storage.set(NSKeyedArchiver.archivedData(withRootObject: list), forKey: BECoupon.kObject)
    
    storage.synchronize()
  }
}
