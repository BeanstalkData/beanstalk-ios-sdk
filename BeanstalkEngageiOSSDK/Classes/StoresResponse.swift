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
  private static let kStoreName = "_storeName"
  private static let kCountry = "_country"
  private static let kAddress1 = "_address1"
  private static let kAddress2 = "_address2"
  private static let kCity = "_city"
  private static let kState = "_state"
  private static let kZip = "_zip"
  private static let kPhone = "_phone"
  private static let kFax = "_fax"
  private static let kConcept = "_concept"
  private static let kVenue = "_venue"
  private static let kSubVenue = "_subVenue"
  private static let kRegion = "_region"
  private static let kRegionName = "_regionName"
  private static let kLongitude = "_longitude"
  private static let kLatitude = "_latitude"
  private static let kGeoEnabled = "_geoEnabled"


    public var id: String?
    public var customerId: String?
    public var date: String?
  public var storeId: String?
  public var storeName: String?
  public var country: String?
  public var address1: String?
  public var address2: String?
  public var city: String?
  public var state: String?
  public var zip: String?
  public var phone: String?
  public var fax: String?
  public var concept: String?
  public var venue: String?
  public var subVenue: String?
  public var region: String?
  public var regionName: String?
  public var longitude: String?
  public var latitude: String?
  public var geoEnabled: String?




    public init(id: String){
        self.id = id
    }
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        id <- map["Id"]
        customerId <- map["CustomerId"]
      // TODO: fix Date formatting
//      date <- map["Date"]
      
      storeId <- map["StoreId"]
      storeName <- map["StoreName"]
      country <- map["Country"]
      address1 <- map["Address1"]
      address2 <- map["Address2"]
      city <- map["City"]
      state <- map["State"]
      zip <- map["Zip"]
      phone <- map["Phone"]
      fax <- map["Fax"]
      concept <- map["Concept"]
      venue <- map["Venue"]
      subVenue <- map["SubVenue"]
      region <- map["Region"]
      regionName <- map["RegionName"]
      longitude <- map["Longitude"]
      latitude <- map["Latitude"]
      geoEnabled <- map["geoEnabled"]
      
    }
    
    init?(storage : NSUserDefaults){
        id = storage.valueForKey(Store.kId) as? String
        if id == nil {
            return nil
        }
      
        customerId = storage.valueForKey(Store.kCustomerId) as? String
      date = storage.valueForKey(Store.kDate) as? String
      storeId = storage.valueForKey(Store.kStoreId) as? String
      storeName = storage.valueForKey(Store.kStoreName) as? String
      country = storage.valueForKey(Store.kCountry) as? String
      address1 = storage.valueForKey(Store.kAddress1) as? String
      address2 = storage.valueForKey(Store.kAddress2) as? String
      city = storage.valueForKey(Store.kCity) as? String
      state = storage.valueForKey(Store.kState) as? String
      zip = storage.valueForKey(Store.kZip) as? String
      phone = storage.valueForKey(Store.kPhone) as? String
      fax = storage.valueForKey(Store.kFax) as? String
      concept = storage.valueForKey(Store.kConcept) as? String
      venue = storage.valueForKey(Store.kVenue) as? String
      subVenue = storage.valueForKey(Store.kSubVenue) as? String
      region = storage.valueForKey(Store.kRegion) as? String
      regionName = storage.valueForKey(Store.kRegionName) as? String
      longitude = storage.valueForKey(Store.kLongitude) as? String
      latitude = storage.valueForKey(Store.kLatitude) as? String
      geoEnabled = storage.valueForKey(Store.kGeoEnabled) as? String
    }
    
    func save(storage : NSUserDefaults){
        storage.setValue(id, forKey: Store.kId)
        storage.setValue(customerId, forKey: Store.kCustomerId)
      storage.setValue(date, forKey: Store.kDate)
      
      storage.setValue(storeId, forKey: Store.kStoreId)
      storage.setValue(storeName, forKey: Store.kStoreName)
      storage.setValue(country, forKey: Store.kCountry)
      storage.setValue(address1, forKey: Store.kAddress1)
      storage.setValue(address2, forKey: Store.kAddress2)
      storage.setValue(city, forKey: Store.kCity)
      storage.setValue(state, forKey: Store.kState)
      storage.setValue(zip, forKey: Store.kZip)
      storage.setValue(phone, forKey: Store.kPhone)
      storage.setValue(fax, forKey: Store.kFax)
      storage.setValue(concept, forKey: Store.kConcept)
      storage.setValue(venue, forKey: Store.kVenue)
      storage.setValue(subVenue, forKey: Store.kSubVenue)
      storage.setValue(region, forKey: Store.kRegion)
      storage.setValue(regionName, forKey: Store.kRegionName)
      storage.setValue(longitude, forKey: Store.kLongitude)
      storage.setValue(latitude, forKey: Store.kLatitude)
      storage.setValue(geoEnabled, forKey: Store.kGeoEnabled)
      
        storage.synchronize()
    }
}
