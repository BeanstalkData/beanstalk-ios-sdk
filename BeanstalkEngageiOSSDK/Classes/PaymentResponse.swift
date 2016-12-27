//
//  PaymentResponse.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import Foundation

import ObjectMapper

public class PaymentResponse : Mappable {
  var token : String?
  
  //for mocks only
  init(token : String){
    self.token = token
  }
  
  required public init?(_ map: Map) {
    
  }
  
  public func mapping(map: Map) {
    token <- map["paymentToken"]
  }
}
