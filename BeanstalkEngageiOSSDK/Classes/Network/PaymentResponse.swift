//
//  PaymentResponse.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation

import ObjectMapper

open class PaymentResponse : Mappable {
  var token : String?
  
  //for mocks only
  init(token : String){
    self.token = token
  }
  
  required public init?(map: Map) {
    
  }
  
  open func mapping(map: Map) {
    token <- map["paymentToken"]
  }
}
