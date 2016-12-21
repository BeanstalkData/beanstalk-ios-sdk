//
//  StoresResponse.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public protocol StoresResponseProtocol {
  func failed() -> Bool
  
  func getStores() -> [Store]?
}

public class StoresResponse : Mappable, StoresResponseProtocol {
  private var status : Bool?
  
  var stores : [Store]?
  
  required public init?(_ map: Map) {
    
  }
    
  public func mapping(map: Map) {
    status <- map["status"]
    stores <- map["stores"]
  }
  
  public func failed() -> Bool{
    if status == nil || !(status!) {
      return true
    }
      
    return false
  }
    
  public func getStores() -> [Store]?{
    return stores
  }
}

public class Store : Mappable {
  private static let kId = "_id"
  private static let kCustomerId = "_customerId"
  private static let kDate = "_date"
  private static let kStoreId = "_storeId"
  private static let kCountry = "_country"
  private static let kAddress1 = "_address1"
  private static let kCity = "_city"
  private static let kState = "_state"
  private static let kZip = "_zip"
  private static let kPhone = "_phone"
  private static let kLongitude = "_longitude"
  private static let kLatitude = "_latitude"
  private static let kGeoEnabled = "_geoEnabled"
  private static let kPaymentLoyaltyParticipation = "_paymentLoyaltyParticipation"

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
    let storeName = "***REMOVED***" + (self.storeId != nil ? " #\(storeId!)" : "")
    
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
