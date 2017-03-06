//
//  BEStore.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/12/17.
//
//

import Foundation

import ObjectMapper

open class BEStore : NSObject, NSCoding, Mappable {
  fileprivate static let kId = "BEStore_id"
  fileprivate static let kCustomerId = "BEStore_customerId"
  fileprivate static let kDate = "BEStore_date"
  fileprivate static let kStoreId = "BEStore_storeId"
  fileprivate static let kCountry = "BEStore_country"
  fileprivate static let kAddress1 = "BEStore_address1"
  fileprivate static let kCity = "BEStore_city"
  fileprivate static let kState = "BEStore_state"
  fileprivate static let kZip = "BEStore_zip"
  fileprivate static let kPhone = "BEStore_phone"
  fileprivate static let kLongitude = "BEStore_longitude"
  fileprivate static let kLatitude = "BEStore_latitude"
  fileprivate static let kGeoEnabled = "BEStore_geoEnabled"
  fileprivate static let kPaymentLoyaltyParticipation = "BEStore_paymentLoyaltyParticipation"
  
  //  private static let kStoreName = "_storeName"
  //  private static let kAddress2 = "_address2"
  //  private static let kFax = "_fax"
  //  private static let kConcept = "_concept"
  //  private static let kVenue = "_venue"
  //  private static let kSubVenue = "_subVenue"
  //  private static let kRegion = "_region"
  //  private static let kRegionName = "_regionName"
  
  
  open var id: String?
  open var customerId: String?
  open var openDate: Date?
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
  
  //  public var storeName: String?
  //  public var address2: String?
  //  public var fax: String?
  //  public var concept: String?
  //  public var venue: String?
  //  public var subVenue: String?
  //  public var region: String?
  //  public var regionName: String?
  
  public init(id: String){
    super.init()
    
    self.id = id
  }
  
  required public init?(map: Map) {
    super.init()
  }
  
  open func getStoreName() -> String {
    let storeName = "Store" + (self.storeId != nil ? " #\(storeId!)" : "")
    
    return storeName
  }
  
  open func mapping(map: Map) {
    var idDict: Dictionary<String, String>?
    idDict <- map["_id"]
    if idDict != nil {
      id = idDict!["$id"]
    }
    
    var openDateDict: Dictionary<String, Double>?
    openDateDict <- map["OpenDate"]
    if openDateDict != nil {
      let sec = openDateDict!["sec"]
      let usec = openDateDict!["usec"]
      
      if (sec != nil && usec != nil) {
        let timeInterval: Double = sec! + usec! / 1000000.0
        self.openDate = Date(timeIntervalSince1970: timeInterval)
      }
    }
    
    customerId <- map["CustomerId"]
    storeId <- map["StoreId"]
    city <- map["City"]
    longitude <- map["Longitude"]
    latitude <- map["Latitude"]
    address1 <- map["Address1"]
    zip <- map["Zip"]
    state <- map["State"]
    country <- map["Country"]
    phone <- map["Phone"]
    
    var geoEnabledNumber: String?
    geoEnabledNumber <- map["geoEnabled"]
    if (geoEnabledNumber != nil) {
      geoEnabled = (Int(geoEnabledNumber!) != 0)
    }
    
    var paymentLoyaltyParticipationNumber: NSNumber?
    paymentLoyaltyParticipationNumber <- map["PaymentLoyaltyParticipation"]
    if (paymentLoyaltyParticipationNumber != nil) {
      paymentLoyaltyParticipation = paymentLoyaltyParticipationNumber?.boolValue
    }
    
    //  storeName <- map["StoreName"]
    //  address2 <- map["Address2"]
    //  fax <- map["Fax"]
    //  concept <- map["Concept"]
    //  venue <- map["Venue"]
    //  subVenue <- map["SubVenue"]
    //  region <- map["Region"]
    //  regionName <- map["RegionName"]
  }
  
  //MARK: - NSCoding -
  required public init(coder aDecoder: NSCoder) {
    self.id = aDecoder.decodeObject(forKey: BEStore.kId) as? String
    self.customerId = aDecoder.decodeObject(forKey: BEStore.kCustomerId) as? String
    self.openDate = aDecoder.decodeObject(forKey: BEStore.kDate) as? Date
    self.storeId = aDecoder.decodeObject(forKey: BEStore.kStoreId) as? String
    self.country = aDecoder.decodeObject(forKey: BEStore.kCountry) as? String
    self.address1 = aDecoder.decodeObject(forKey: BEStore.kAddress1) as? String
    self.city = aDecoder.decodeObject(forKey: BEStore.kCity) as? String
    self.state = aDecoder.decodeObject(forKey: BEStore.kState) as? String
    self.zip = aDecoder.decodeObject(forKey: BEStore.kZip) as? Int
    self.phone = aDecoder.decodeObject(forKey: BEStore.kPhone) as? String
    self.longitude = aDecoder.decodeObject(forKey: BEStore.kLongitude) as? String
    self.latitude = aDecoder.decodeObject(forKey: BEStore.kLatitude) as? String
    self.geoEnabled = aDecoder.decodeObject(forKey: BEStore.kGeoEnabled) as? Bool
    self.paymentLoyaltyParticipation = aDecoder.decodeObject(forKey: BEStore.kPaymentLoyaltyParticipation) as? Bool
  }
  
  public func encode(with aCoder: NSCoder) {
    aCoder.encode(id, forKey: BEStore.kId)
    aCoder.encode(customerId, forKey: BEStore.kCustomerId)
    aCoder.encode(openDate, forKey: BEStore.kDate)
    aCoder.encode(storeId, forKey: BEStore.kStoreId)
    aCoder.encode(country, forKey: BEStore.kCountry)
    aCoder.encode(address1, forKey: BEStore.kAddress1)
    aCoder.encode(city, forKey: BEStore.kCity)
    aCoder.encode(state, forKey: BEStore.kState)
    aCoder.encode(zip, forKey: BEStore.kZip)
    aCoder.encode(phone, forKey: BEStore.kPhone)
    aCoder.encode(longitude, forKey: BEStore.kLongitude)
    aCoder.encode(latitude, forKey: BEStore.kLatitude)
    aCoder.encode(geoEnabled, forKey: BEStore.kGeoEnabled)
    aCoder.encode(paymentLoyaltyParticipation, forKey: BEStore.kPaymentLoyaltyParticipation)
  }
}
