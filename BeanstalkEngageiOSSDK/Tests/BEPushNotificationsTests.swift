//
//  BEPushNotificationsTests.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 4/11/17.
//
//

import Foundation
import XCTest

open class BEPushNotificationsTests: BEBaseTestCase {
  
  open override func setUp() {
    super.setUp()
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    coreServiceHandler.signIn(getMetadata()!.getRegisteredUser1Email(), password: getMetadata()!.getRegisteredUser1Password()) { (result) in
      XCTAssert(result, "Login request finished with error")
    }
  }
  
  open override func tearDown() {
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    coreServiceHandler.signOut { (result) in
      XCTAssert(result, "Logout request finished with error")
    }
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  open func getPushNotificationMessagesTest() {
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    var pushMessages: [BEPushNotificationMessage]?
    coreServiceHandler.getPushNotificationMessages(maxResults: 100, handler: { (result, messages) in
      XCTAssert(result, "getPushNotificationMessages request finished with error")
      pushMessages = messages
    })
    
    XCTAssert(pushMessages != nil)
  }
}
