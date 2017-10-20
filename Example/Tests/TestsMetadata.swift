//
//  TestsMetadata.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import CoreLocation
import BeanstalkEngageiOSSDK

class TestsMetadata: BEBaseTestsMetadataProtocol {
  internal func getBeanstalkApiKey() -> String {
    return "1234-4321-ABCD-DCBA"
  }
  
  internal func getBeanstalkUrl() -> String {
    return "proc.beanstalkdata.com"
  }
  
  internal func getRegisteredUserEmail() -> String {
    return "pavel105@dp.net"
  }
  
  internal func getRegisteredUser1Email() -> String {
    return "test104@email.com"
  }
  
  internal func getRegisteredUser1Password() -> String {
    return "qazwsxed"
  }
  
  internal func getRegisteredUser1Contact() -> BEContact {
    let contact = BEContact()
    
    contact.contactId = 17761827
    contact.firstName = "John"
    contact.lastName = "Apple"
    contact.zipCode = "28071"
    contact.email = getRegisteredUser1Email()
    contact.prospect = "loyalty"
    contact.gender = "Male"
    contact.birthday = "1996-01-18"
    contact.phone = "8774655523"
    contact.textOptin = 0
    contact.emailOptin = 0
    contact.pushNotificationOptin = 0
    contact.inboxMessageOptin = 0
    contact.primaryId = "123454321"
    contact.loyaltyCardId = "987654321"
    
    return contact
  }
  
  internal func getRegisteredUser1GiftCard() -> BEGiftCard {
    let card = BEGiftCard(id: "713", number : "5022440100002652373", balance : "100")
    
    return card
  }
  
  func getValidAPNSToken() -> String {
    return "1212121212121212121212121212121212121212"
  }
  
  func getInvalidAPNSToken() -> String {
    return "qwerty"
  }
  
  func getValidLocationCoordinate() -> CLLocationCoordinate2D? {
    var coordinate = CLLocationCoordinate2D()
    
    // Concord coordinates
    coordinate.longitude = -80.579510
    coordinate.latitude = 35.408752
    
    return coordinate
  }
  
  func getInvalidLocationCoordinate() -> CLLocationCoordinate2D? {
    return nil
  }
}
