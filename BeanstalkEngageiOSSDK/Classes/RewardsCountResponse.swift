//
//  RewardsCountResponse.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class RewardsCountResponse : Mappable {
  private var categories : [Category]?
  
  //for mocks only
  init(categories : [Category]){
    self.categories = categories
  }
  
  required public init?(_ map: Map) {
    
  }
  
  public func mapping(map: Map) {
    categories <- map["Category"]
  }
  
  func getCount() -> Double {
    if categories != nil && categories?.count > 0 {
      return Double(categories!.reduce(0,combine:  {$0 + $1.count!}))
    }
    return 0.0
  }
}

public class Category : Mappable {
  var name: String?
  var count: Int?
  
  //for mocks only
  init(count: Int){
    self.count = count;
  }
  
  required public init?(_ map: Map) {
    
  }
  
  public func mapping(map: Map) {
    name <- map["Name"]
    
    //        if map["Count"] is String {
    //            count <- map["Count"]
    //        } else if map["Count"] is Int {
    //            count <- map["Count"]
    //        }
    
    var c: String = "0"
    c <- map["Count"]
    count = Int(c)
  }
}
