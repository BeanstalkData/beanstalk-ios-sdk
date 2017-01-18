//
//  TestsMetadata.swift
//  BeanstalkEngageiOSSDK
//
//  Created by Pavel Dvorovenko on 1/3/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import BeanstalkEngageiOSSDK

class TestsMetadata: BEBaseTestsMetadataProtocol {
  internal func getBeanstalkApiKey() -> String {
    return "1234-4321-ABCD-DCBA"
  }
  
  internal func getRegisteredUser1Email() -> String {
    return "pavel105@dp.net"
  }
  
  internal func getRegisteredUser1Password() -> String {
    return "qazwsxe"
  }
  
  internal func getRegisteredUser1Contact() -> BEContact {
    let contact = BEContact()
    
    contact.firstName = "Pavel"
    contact.lastName = "Dv"
    contact.zipCode = "28071"
    contact.email = getRegisteredUser1Email()
    contact.prospect = "loyalty"
    contact.gender = "Male"
    contact.birthday = "1996-01-18"
    contact.phone = "8774655555"
    contact.textOptin = 0
    contact.emailOptin = 0
    contact.pushNotificationOptin = 0
    contact.inboxMessageOptin = 0
    
    return contact
  }
}
