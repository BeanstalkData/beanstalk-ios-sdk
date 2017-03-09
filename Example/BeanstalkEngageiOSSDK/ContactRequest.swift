//
//  ContactRequest.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation

import ObjectMapper

import BeanstalkEngageiOSSDK

class CustomContactRequest: BeanstalkEngageiOSSDK.ContactRequest {
  internal var preferredReward : String?
  
  override internal func mapping(map: Map) {
    super.mapping(map: map)
    
    preferredReward <- map["custom_PreferredReward"]
  }
}
