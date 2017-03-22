//
//  RewardsCountResponse.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import ObjectMapper
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


open class RewardsCountResponse : Mappable {
  fileprivate var categories : [Category]?
  
  //for mocks only
  init(categories : [Category]){
    self.categories = categories
  }
  
  required public init?(map: Map) {
    
  }
  
  open func mapping(map: Map) {
    categories <- map["Category"]
  }
  
  func getCount() -> Double {
    if categories != nil && categories?.count > 0 {
      return Double(categories!.reduce(0,{$0 + $1.count!}))
    }
    return 0.0
  }
}

open class Category : Mappable {
  var name: String?
  var count: Int?
  
  //for mocks only
  init(count: Int){
    self.count = count
  }
  
  required public init?(map: Map) {
    
  }
  
  open func mapping(map: Map) {
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
