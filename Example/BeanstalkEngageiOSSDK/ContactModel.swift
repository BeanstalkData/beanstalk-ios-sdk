//
//  ContactModel.swift
//  BeanstalkEngageiOSSDK
//
//  Created by Pavel Dvorovenko on 2/7/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import BeanstalkEngageiOSSDK

public class ContactModel: BEContact {
  
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
}
