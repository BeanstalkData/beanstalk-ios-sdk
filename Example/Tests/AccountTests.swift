//
//  AccountTests.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import XCTest

import BeanstalkEngageiOSSDK
import BeanstalkEngageiOSSDK_Example
import Pods_BeanstalkEngageiOSSDK_Tests

class AccountTests: BEAccountTests {
  let testsMetadata = TestsMetadata()
  
  override func getMetadata() -> BEBaseTestsMetadataProtocol? {
    return testsMetadata
  }
  
  func testLoginRegisteredUser() {
    loginRegisteredUserTest()
  }
  
  func testAutoLoginRegisteredUser() {
    autoLoginRegisteredUserTest()
  }
  
  func testAutoLoginUnRegisteredUser() {
    autoLoginUnRegisteredUserTest()
  }
  
  func testLoginRegisteredUserWithValidPush() {
    loginRegisteredUserWithValidPushTest()
  }
  
  func testLoginRegisteredUserWithInvalidPush() {
    loginRegisteredUserWithInvalidPushTest()
  }
  
  func testResetPassword() {
    resetPasswordTest()
  }
  
  func testUpdatePassword() {
    updatePasswordTest()
  }
  
  func testRegisterLoyaltyAccount() {
    registerLoyaltyAccountTest()
  }
  
  func testLoyaltyAccountParsing() {
    loyaltyAccountParsingTest()
  }
  
  func testRegisterAccount() {
    registerAccountTest()
  }
  
  func testGetContact() {
    getContactTest(ContactModel.self)
  }
  
  func testUpdateContact() {
    updateContactTest(ContactModel.self)
  }
  
  func testUserInfo() {
    userInfoTest()
  }
  
  internal func testUpdateContactCustomFields() {
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    coreServiceHandler.signIn(getMetadata()!.getRegisteredUser1Email(), password: getMetadata()!.getRegisteredUser1Password()) { (result) in
      XCTAssert(result, "Login request finished with error")
      
      if (result) {
        
        coreServiceHandler.getContact(ContactModel.self) { contact in
          XCTAssert(contact != nil, "Get contact request finished with error")
          
          if contact != nil {
            
            let request = CustomContactRequest(origin: contact!)
            request.preferredReward = "testRewards"
            
            coreServiceHandler.updateContact(request: request, handler: { (result) in
              XCTAssert(result, "Update contact request finished with error")
              
              if result {
                coreServiceHandler.getContact(ContactModel.self) { (contact) in
                  XCTAssert(contact != nil, "Get contact request finished with error")
                  
                  if contact != nil {
                    XCTAssert(contact!.firstName == request.origin?.firstName, "Contact object is invalid")
                    XCTAssert(contact!.lastName == request.origin?.lastName, "Contact object is invalid")
                    XCTAssert(contact!.phone == request.origin?.phone, "Contact object is invalid")
                    XCTAssert(contact!.email == request.origin?.email, "Contact object is invalid")
                    XCTAssert(contact!.zipCode == request.origin?.zipCode, "Contact object is invalid")
                    XCTAssert(contact!.birthday == request.origin?.birthday, "Contact object is invalid")
                    XCTAssert(contact!.emailOptin == request.origin?.emailOptin, "Contact object is invalid")
                    XCTAssert(contact!.preferredReward == request.preferredReward, "Contact object is invalid")
                    XCTAssert(contact!.gender == request.origin?.gender, "Contact object is invalid")
                  }
                  
                  let user1Contact = self.getMetadata()!.getRegisteredUser1Contact()
                  let request = CustomContactRequest(origin: user1Contact)
                  request.preferredReward = ""
                  
                  coreServiceHandler.updateContact(request: request, handler: { (result) in
                    XCTAssert(result, "Update contact request finished with error")
                    
                    if result {
                      coreServiceHandler.getContact(ContactModel.self) { (contact) in
                        XCTAssert(contact != nil, "Get contact request finished with error")
                        
                        if contact != nil {
                          XCTAssert(contact!.firstName == user1Contact.firstName, "Contact object is invalid")
                          XCTAssert(contact!.lastName == user1Contact.lastName, "Contact object is invalid")
                          XCTAssert(contact!.phone == user1Contact.phone, "Contact object is invalid")
                          XCTAssert(contact!.email == user1Contact.email, "Contact object is invalid")
                          XCTAssert(contact!.zipCode == user1Contact.zipCode, "Contact object is invalid")
                          XCTAssert(contact!.birthday == user1Contact.birthday, "Contact object is invalid")
                          XCTAssert(contact!.emailOptin == user1Contact.emailOptin, "Contact object is invalid")
                          XCTAssert(contact!.preferredReward == request.preferredReward, "Contact object is invalid")
                          XCTAssert(contact!.gender == user1Contact.gender, "Contact object is invalid")
                        }
                      }
                    }
                  })
                }
              }
            })
          }
        }
      }
    }
  }
}
