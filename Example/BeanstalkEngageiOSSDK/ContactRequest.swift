//
//  ContactRequest.swift
//  BeanstalkEngageiOSSDK
//
//  Created by Pavel Dvorovenko on 2/12/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

import ObjectMapper

import BeanstalkEngageiOSSDK

class ContactRequest: BeanstalkEngageiOSSDK.ContactRequest {
  internal var preferredReward : String?
  
  override internal func mapping(map: Map) {
    super.mapping(map)
    
    preferredReward <- map["custom_PreferredReward"]
  }
}
