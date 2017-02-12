//
//  ContactModel.swift
//  BeanstalkEngageiOSSDK
//
//  Created by Pavel Dvorovenko on 2/7/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

import ObjectMapper

import BeanstalkEngageiOSSDK

public class ContactModel: BEContact {
  
  public var preferredReward : String?
  
  public func getFullName() -> String {
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
  
  override public func mapping(map: Map) {
    super.mapping(map)
    
    preferredReward <- map["PreferredReward"]
  }
}
