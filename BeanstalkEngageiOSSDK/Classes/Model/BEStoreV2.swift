//
//  BEStoreV2.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation

import ObjectMapper

/**
 Model of store received from store locations.
 */
open class BEStoreV2 : NSObject, NSCoding, Mappable, BEStoreProtocol {
  fileprivate static let kId = "BEStoreV2_id"
  fileprivate static let kCustomerId = "BEStoreV2_customerId"
  fileprivate static let kStoreId = "BEStoreV2_storeId"
  fileprivate static let kCountry = "BEStoreV2_country"
  fileprivate static let kAddress1 = "BEStoreV2_address1"
  fileprivate static let kCity = "BEStoreV2_city"
  fileprivate static let kState = "BEStoreV2_state"
  fileprivate static let kZip = "BEStoreV2_zip"
  fileprivate static let kPhone = "BEStoreV2_phone"
  fileprivate static let kLongitude = "BEStoreV2_longitude"
  fileprivate static let kLatitude = "BEStoreV2_latitude"
  fileprivate static let kGeoEnabled = "BEStoreV2_geoEnabled"
  fileprivate static let kPaymentLoyaltyParticipation = "BEStoreV2_paymentLoyaltyParticipation"
  fileprivate static let kWebsite = "BEStoreV2_website"
  fileprivate static let kEmail = "BEStoreV2_email"
  fileprivate static let kTimeZone = "BEStoreV2_timeZone"
  fileprivate static let kName = "BEStoreV2_name"
  fileprivate static let kAddress2 = "BEStoreV2_address2"
  fileprivate static let kOpeningWeekHours = "BEStoreV2_openingWeekHours"
  
  open var id: String?
  open var customerId: String?
  open var storeId: String?
  open var country: String?
  open var address1: String?
  open var city: String?
  open var state: String?
  open var zip: Int?
  open var phone: String?
  open var longitude: String?
  open var latitude: String?
  open var geoEnabled: Bool?
  open var paymentLoyaltyParticipation: Bool?
  
  open var website: String?
  open var email: String?
  open var timeZone: String?
  open var name: String?
  
  open var address2: String?
  
  open var openingHours: BEOpeningWeekHours?
  
  open var openDate: Date? {
    get {
      return nil
    }
  }
  public init(id: String){
    super.init()
    
    self.id = id
  }
  
  required public init?(map: Map) {
    super.init()
  }
  
  open func mapping(map: Map) {
    var idDict: Dictionary<String, String>?
    idDict <- map["_id"]
    if idDict != nil {
      id = idDict!["$id"]
    }
    
    customerId <- map["customer_id"]
    storeId <- map["store_number"]
    name <- map["name"]
    phone <- map["phone_number"]
    website <- map["website"]
    email <- map["email"]
    timeZone <- map["time_zone"]
    
    var geoEnabledNumber: String?
    geoEnabledNumber <- map["geo_enabled"]
    if (geoEnabledNumber != nil) {
      geoEnabled = (Int(geoEnabledNumber!) != 0)
    }
    
    var paymentLoyaltyParticipationNumber: NSNumber?
    paymentLoyaltyParticipationNumber <- map["payment_loyalty_participation"]
    if (paymentLoyaltyParticipationNumber != nil) {
      paymentLoyaltyParticipation = paymentLoyaltyParticipationNumber?.boolValue
    }
    
    // location
    address1 <- map["loc.address_1"]
    address2 <- map["loc.address_2"]
    city <- map["loc.city"]
    state <- map["loc.state"]
    zip <- (map["loc.zip"], TransformOf<Int, String>(fromJSON: { Int($0!) }, toJSON: { $0.map { String($0) } }))
    country <- map["loc.country"]
    
    var coordinates: [Double]?
    coordinates <- map["loc.coordinates"]
    if let long = coordinates?.first {
      longitude = String(format: "%.6f", long)
    }
    if let lat = coordinates?.last {
      latitude = String(format: "%.6f", lat)
    }
    var openingHoursString: String?
    openingHoursString <- map["hours"]
    openingHours = BEOpeningWeekHours(formattedString: openingHoursString)
  }
  
  //MARK: - NSCoding -
  required public init(coder aDecoder: NSCoder) {
    self.id = aDecoder.decodeObject(forKey: BEStoreV2.kId) as? String
    self.customerId = aDecoder.decodeObject(forKey: BEStoreV2.kCustomerId) as? String
    self.storeId = aDecoder.decodeObject(forKey: BEStoreV2.kStoreId) as? String
    self.country = aDecoder.decodeObject(forKey: BEStoreV2.kCountry) as? String
    self.address1 = aDecoder.decodeObject(forKey: BEStoreV2.kAddress1) as? String
    self.city = aDecoder.decodeObject(forKey: BEStoreV2.kCity) as? String
    self.state = aDecoder.decodeObject(forKey: BEStoreV2.kState) as? String
    self.zip = aDecoder.decodeObject(forKey: BEStoreV2.kZip) as? Int
    self.phone = aDecoder.decodeObject(forKey: BEStoreV2.kPhone) as? String
    self.longitude = aDecoder.decodeObject(forKey: BEStoreV2.kLongitude) as? String
    self.latitude = aDecoder.decodeObject(forKey: BEStoreV2.kLatitude) as? String
    self.geoEnabled = aDecoder.decodeObject(forKey: BEStoreV2.kGeoEnabled) as? Bool
    self.paymentLoyaltyParticipation = aDecoder.decodeObject(forKey: BEStoreV2.kPaymentLoyaltyParticipation) as? Bool
    self.website = aDecoder.decodeObject(forKey: BEStoreV2.kWebsite) as? String
    self.email = aDecoder.decodeObject(forKey: BEStoreV2.kEmail) as? String
    self.timeZone = aDecoder.decodeObject(forKey: BEStoreV2.kTimeZone) as? String
    self.name = aDecoder.decodeObject(forKey: BEStoreV2.kName) as? String
    self.address2 = aDecoder.decodeObject(forKey: BEStoreV2.kAddress2) as? String
    self.openingHours = aDecoder.decodeObject(forKey: BEStoreV2.kOpeningWeekHours) as? BEOpeningWeekHours
  }
  
  public func encode(with aCoder: NSCoder) {
    aCoder.encode(id, forKey: BEStoreV2.kId)
    aCoder.encode(customerId, forKey: BEStoreV2.kCustomerId)
    aCoder.encode(storeId, forKey: BEStoreV2.kStoreId)
    aCoder.encode(country, forKey: BEStoreV2.kCountry)
    aCoder.encode(address1, forKey: BEStoreV2.kAddress1)
    aCoder.encode(city, forKey: BEStoreV2.kCity)
    aCoder.encode(state, forKey: BEStoreV2.kState)
    aCoder.encode(zip, forKey: BEStoreV2.kZip)
    aCoder.encode(phone, forKey: BEStoreV2.kPhone)
    aCoder.encode(longitude, forKey: BEStoreV2.kLongitude)
    aCoder.encode(latitude, forKey: BEStoreV2.kLatitude)
    aCoder.encode(geoEnabled, forKey: BEStoreV2.kGeoEnabled)
    aCoder.encode(paymentLoyaltyParticipation, forKey: BEStoreV2.kPaymentLoyaltyParticipation)
    aCoder.encode(website, forKey: BEStoreV2.kWebsite)
    aCoder.encode(email, forKey: BEStoreV2.kEmail)
    aCoder.encode(timeZone, forKey: BEStoreV2.kTimeZone)
    aCoder.encode(name, forKey: BEStoreV2.kName)
    aCoder.encode(address2, forKey: BEStoreV2.kAddress2)
    aCoder.encode(openingHours, forKey: BEStoreV2.kOpeningWeekHours)
  }
}
