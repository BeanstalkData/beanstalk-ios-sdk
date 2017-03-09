//
//  ContactModel.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation

import ObjectMapper

import BeanstalkEngageiOSSDK

open class ContactModel: BEContact {
  
  open var preferredReward : String?
  
  open func getFullName() -> String {
    var fullName = ""
    
    if self.firstName != nil {
      fullName += self.firstName!
    }
    
    if self.lastName != nil {
      if fullName.characters.count > 0 {
        fullName += " "
      }
      
      fullName += self.lastName!
    }
    
    return fullName
  }
  
  override open func mapping(map: Map) {
    super.mapping(map: map)
    
    preferredReward <- map["PreferredReward"]
  }
}
