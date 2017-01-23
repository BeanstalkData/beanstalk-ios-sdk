import UIKit
import XCTest

import Timberjack

public class BEAccountTests: BEBaseTestCase {
  
  public override func setUp() {
    super.setUp()
    
    Timberjack.register()
  }
  
  public override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
    
    Timberjack.unregister()
  }
  
  public func loginRegisteredUserTest() {
    
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    coreServiceHandler.signIn(getMetadata()!.getRegisteredUser1Email(), password: getMetadata()!.getRegisteredUser1Password()) { (result) in
      XCTAssert(result, "Login request finished with error");
      
      if (result) {
        coreServiceHandler.signOut() { (result) in
          XCTAssert(result, "Logout request finished with error");
        }
      }
    }
  }
  
  public func loginRegisteredUserWithValidPushTest() {
    
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let pushToken = getMetadata()!.getValidAPNSToken()
    
    self.getSession()?.setAPNSToken(pushToken)
    self.getSession()?.setRegisteredAPNSToken(nil)
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    coreServiceHandler.signIn(getMetadata()!.getRegisteredUser1Email(), password: getMetadata()!.getRegisteredUser1Password()) { (result) in
      XCTAssert(result, "Login request finished with error");
      
      XCTAssert(self.getSession()?.getAPNSToken() == pushToken, "Invalid APNS token after login")
      XCTAssert(self.getSession()?.getRegisteredAPNSToken() == pushToken, "Invalid APNS token after login")
      
      if (result) {
        coreServiceHandler.signOut() { (result) in
          XCTAssert(self.getSession()?.getAPNSToken() == pushToken, "Invalid APNS token after logout")
          XCTAssert(self.getSession()?.getRegisteredAPNSToken() == nil, "Invalid APNS token after logout")
        }
      }
    }
  }
  
  public func loginRegisteredUserWithInvalidPushTest() {
    
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let pushToken = getMetadata()!.getInvalidAPNSToken()
    
    self.getSession()?.setAPNSToken(pushToken)
    self.getSession()?.setRegisteredAPNSToken(nil)
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    coreServiceHandler.signIn(getMetadata()!.getRegisteredUser1Email(), password: getMetadata()!.getRegisteredUser1Password()) { (result) in
      XCTAssert(result, "Login request finished with error");
      
      XCTAssert(self.getSession()?.getAPNSToken() == pushToken, "Invalid APNS token after login")
      XCTAssert(self.getSession()?.getRegisteredAPNSToken() == nil, "Invalid APNS token after login")
      
      if (result) {
        coreServiceHandler.signOut() { (result) in
          XCTAssert(self.getSession()?.getAPNSToken() == pushToken, "Invalid APNS token after logout")
          XCTAssert(self.getSession()?.getRegisteredAPNSToken() == nil, "Invalid APNS token after logout")
        }
      }
    }
  }
  
  public func registerLoyaltyAccountTest() {
    
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    let contact = getMetadata()!.getRegisteredUser1Contact()
    let request = CreateContactRequest()
    request.firstName = contact.firstName
    request.lastName = contact.lastName
    request.phone = contact.phone
    request.email = contact.email
    request.emailConfirm = contact.email
    request.password = getMetadata()!.getRegisteredUser1Password()
    request.passwordConfirm = getMetadata()!.getRegisteredUser1Password()
    request.zipCode  = contact.zipCode
    request.birthdate = contact.birthday
    request.emailOptIn = (contact.emailOptin != 0)
    request.preferredReward = ""
    request.male = (contact.gender == "Male")
    
    coreServiceHandler.registerLoyaltyAccount(request) { (result) in
      
      XCTAssert(result, "Register Loyalty Account request finished with error");
      
      if (result) {
        coreServiceHandler.signOut() { (result) in
          XCTAssert(result, "Logout request finished with error");
        }
      }
    }
  }
  
  public func registerAccountTest() {
    
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    let contact = getMetadata()!.getRegisteredUser1Contact()
    let request = CreateContactRequest()
    request.firstName = contact.firstName
    request.lastName = contact.lastName
    request.phone = contact.phone
    request.email = contact.email
    request.emailConfirm = contact.email
    request.password = getMetadata()!.getRegisteredUser1Password()
    request.passwordConfirm = getMetadata()!.getRegisteredUser1Password()
    request.zipCode  = contact.zipCode
    request.birthdate = contact.birthday
    request.emailOptIn = (contact.emailOptin != 0)
    request.preferredReward = ""
    request.male = (contact.gender == "Male")
    
    coreServiceHandler.registerAccount(request) { (result) in
      
      XCTAssert(result, "Register Account request finished with error");
      
      if (result) {
        coreServiceHandler.signOut() { (result) in
          XCTAssert(result, "Logout request finished with error");
        }
      }
    }
  }
}
