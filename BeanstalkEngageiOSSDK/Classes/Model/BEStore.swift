//
//  BEStore.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/12/17.
//
//

import Foundation

import ObjectMapper

public class BEStore : Mappable {
  private static let kId = "BEStore_id"
  private static let kCustomerId = "BEStore_customerId"
  private static let kDate = "BEStore_date"
  private static let kStoreId = "BEStore_storeId"
  private static let kCountry = "BEStore_country"
  private static let kAddress1 = "BEStore_address1"
  private static let kCity = "BEStore_city"
  private static let kState = "BEStore_state"
  private static let kZip = "BEStore_zip"
  private static let kPhone = "BEStore_phone"
  private static let kLongitude = "BEStore_longitude"
  private static let kLatitude = "BEStore_latitude"
  private static let kGeoEnabled = "BEStore_geoEnabled"
  private static let kPaymentLoyaltyParticipation = "BEStore_paymentLoyaltyParticipation"
  
  //  private static let kStoreName = "_storeName"
  //  private static let kAddress2 = "_address2"
  //  private static let kFax = "_fax"
  //  private static let kConcept = "_concept"
  //  private static let kVenue = "_venue"
  //  private static let kSubVenue = "_subVenue"
  //  private static let kRegion = "_region"
  //  private static let kRegionName = "_regionName"
  
  
  public var id: String?
  public var customerId: String?
  public var openDate: NSDate?
  public var storeId: String?
  public var country: String?
  public var address1: String?
  public var city: String?
  public var state: String?
  public var zip: Int?
  public var phone: String?
  public var longitude: String?
  public var latitude: String?
  public var geoEnabled: Bool?
  public var paymentLoyaltyParticipation: Bool?
  
  //  public var storeName: String?
  //  public var address2: String?
  //  public var fax: String?
  //  public var concept: String?
  //  public var venue: String?
  //  public var subVenue: String?
  //  public var region: String?
  //  public var regionName: String?
  
  public init(id: String){
    self.id = id
  }
  
  required public init?(_ map: Map) {
  }
  
  public func getStoreName() -> String {
    let storeName = "Store" + (self.storeId != nil ? " #\(storeId!)" : "")
    
    return storeName
  }
  
  public func mapping(map: Map) {
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
        self.openDate = NSDate(timeIntervalSince1970: timeInterval)
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
}
