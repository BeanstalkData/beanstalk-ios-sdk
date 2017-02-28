import UIKit
import XCTest

import ObjectMapper
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
  
  public func autoLoginRegisteredUserTest() {
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    coreServiceHandler.autoSignIn( { result in
      XCTAssert(!result, "Unexpected Auto Login status, should be false");
      
      coreServiceHandler.signIn(self.getMetadata()!.getRegisteredUser1Email(), password: self.getMetadata()!.getRegisteredUser1Password()) { (result) in
        XCTAssert(result, "Login request finished with error");
        
        coreServiceHandler.autoSignIn( { result in
          XCTAssert(result, "Unexpected Auto Login status, should be true");
          
          coreServiceHandler.signOut() { result in
            XCTAssert(result, "Logout request finished with error");
            
            coreServiceHandler.autoSignIn( { result in
              XCTAssert(!result, "Unexpected Auto Login status, should be false");
            })
          }
        })
      }
    })
  }

  public func autoLoginUnRegisteredUserTest() {
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    coreServiceHandler.autoSignIn( { result in
      XCTAssert(!result, "Unexpected Auto Login status, should be false");
      
      coreServiceHandler.signIn("invalid@email.com", password: "123456789") { (result) in
        XCTAssert(!result, "Unexpected Login request state, should be false");
        
        coreServiceHandler.autoSignIn( { result in
          XCTAssert(!result, "Unexpected Auto Login status, should be false");
        })
      }
    })
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
  
  public func resetPasswordTest() {
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    coreServiceHandler.resetPassword("invalidEmail@InvalidEmail.com") { (result) in
      XCTAssert(result == false, "Success reset password for invalid user email")
      
      coreServiceHandler.resetPassword(self.getMetadata()!.getRegisteredUserEmail()) { (result) in
        XCTAssert(result == true, "Failed to reset password for valid user email")
      }
    }
  }
  
  public func updatePasswordTest() {
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    coreServiceHandler.signIn(getMetadata()!.getRegisteredUser1Email(), password: getMetadata()!.getRegisteredUser1Password()) { (result) in
      XCTAssert(result, "Login request finished with error")
      
      if (result) {
        coreServiceHandler.updatePassword(self.getMetadata()!.getRegisteredUser1Password(), handler: { (result) in
          XCTAssert(result, "Update password request finished with error")
          
          if (result) {
            coreServiceHandler.updatePassword("testPassword", handler: { (result) in
              XCTAssert(result, "Update password request finished with error")
              
              coreServiceHandler.updatePassword(self.getMetadata()!.getRegisteredUser1Password(), handler: { (result) in
                XCTAssert(result, "Update password request finished with error")
                
              })
            })
          }
        })
      }
    }
  }
  
  public func loyaltyAccountParsingTest() {
    let JSON: [String: AnyObject] = [
      "giftCardTrack2" : ";5022111100001111222=12344321111111?",
      "contactId" : "12341234",
      "sessionToken" : "42f5481997c18f778c973170c3ad4317f7eeb830",
      "giftCardNumber" : "5022111100001111222",
      "giftCardRegistrationStatus" : true,
      "giftCardPin" : NSNull()
    ]
    
    self.loyaltyAccountParsingTest(JSON)
  }
  
  public func loyaltyAccountParsingTest(JSON: [String: AnyObject]) {
    let map = Map(mappingType: .FromJSON, JSONDictionary: JSON)
    
    var loyaltyAccount = BELoyaltyUser(map)
    
    XCTAssert(loyaltyAccount!.contactId == JSON["contactId"] as? String, "Loyalty account object is invalid")
    XCTAssert(loyaltyAccount!.sessionToken == JSON["sessionToken"] as? String, "Loyalty account object is invalid")
    XCTAssert(loyaltyAccount!.giftCardNumber == JSON["giftCardNumber"] as? String, "Loyalty account object is invalid")
    XCTAssert(loyaltyAccount!.giftCardPin == JSON["giftCardPin"] as? String, "Loyalty account object is invalid")
    XCTAssert(loyaltyAccount!.giftCardRegistrationStatus == JSON["giftCardRegistrationStatus"]  as? Bool, "Loyalty account object is invalid")
    XCTAssert(loyaltyAccount!.giftCardTrack2 == JSON["giftCardTrack2"] as? String, "Loyalty account object is invalid")
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
    request.gender = contact.gender != nil ? contact.gender! : "Unknown"
    
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
    request.gender = contact.gender != nil ? contact.gender! : "Unknown"
    
    coreServiceHandler.registerAccount(request) { (result) in
      
      XCTAssert(result, "Register Account request finished with error");
      
      if (result) {
        coreServiceHandler.signOut() { (result) in
          XCTAssert(result, "Logout request finished with error");
        }
      }
    }
  }
  
  public func getContactTest<ContactClass: BEContact>(contactClass: ContactClass.Type) {
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    coreServiceHandler.signIn(getMetadata()!.getRegisteredUser1Email(), password: getMetadata()!.getRegisteredUser1Password()) { (result) in
      XCTAssert(result, "Login request finished with error")
      
      if (result) {
        
        coreServiceHandler.getContact({ (contact) in
          XCTAssert(contact != nil, "Get contact request finished with error")
          
          if contact != nil {
            XCTAssert(contact!.contactId != nil, "Contact object is invalid")
            XCTAssert(contact!.firstName != nil, "Contact object is invalid")
            XCTAssert(contact!.lastName != nil, "Contact object is invalid")
            XCTAssert(contact!.zipCode != nil, "Contact object is invalid")
            XCTAssert(contact!.email != nil, "Contact object is invalid")
            XCTAssert(contact!.gender != nil, "Contact object is invalid")
            XCTAssert(contact!.birthday != nil, "Contact object is invalid")
            XCTAssert(contact!.phone != nil, "Contact object is invalid")
          }
          
          coreServiceHandler.getContact(contactClass, handler: { (contact) in
            debugPrint("Contact object: " + contact.debugDescription)
            XCTAssert(contact != nil, "Get contact request finished with error")
            
            if contact != nil {
              XCTAssert(contact!.contactId != nil, "Contact object is invalid")
              XCTAssert(contact!.firstName != nil, "Contact object is invalid")
              XCTAssert(contact!.lastName != nil, "Contact object is invalid")
              XCTAssert(contact!.zipCode != nil, "Contact object is invalid")
              XCTAssert(contact!.email != nil, "Contact object is invalid")
              XCTAssert(contact!.gender != nil, "Contact object is invalid")
              XCTAssert(contact!.birthday != nil, "Contact object is invalid")
              XCTAssert(contact!.phone != nil, "Contact object is invalid")
            }
            
            coreServiceHandler.signOut() { (result) in
            }
          })
        })
      }
    }
  }
  
  public func updateContactTest<ContactClass: BEContact>(contactClass: ContactClass.Type) {
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    coreServiceHandler.signIn(getMetadata()!.getRegisteredUser1Email(), password: getMetadata()!.getRegisteredUser1Password()) { (result) in
      XCTAssert(result, "Login request finished with error")
      
      if (result) {
        
        coreServiceHandler.getContact({ (contact) in
          XCTAssert(contact != nil, "Get contact request finished with error")
          
          if contact != nil {
            
            let request = UpdateContactRequest(contact: contact)
            request.firstName = contact!.firstName! + "1"
            request.lastName = contact!.lastName! + "1"
            request.phone = contact!.phone
            request.email = contact!.email! + "m"
            request.zipCode  = contact!.zipCode! + "1"
            request.birthdate = contact!.birthday
            request.emailOptIn = (contact!.emailOptin != 0)
            request.preferredReward = ""
            request.gender = contact!.gender!
          
            coreServiceHandler.updateContact(contact!, request: request, handler: { (result) in
              XCTAssert(contact != nil, "Update contact request finished with error")
              
              if result {
                coreServiceHandler.getContact({ (contact) in
                  XCTAssert(contact != nil, "Get contact request finished with error")
                  
                  if contact != nil {
                    XCTAssert(contact!.firstName == request.firstName, "Contact object is invalid")
                    XCTAssert(contact!.lastName == request.lastName, "Contact object is invalid")
                    XCTAssert(contact!.phone == request.phone, "Contact object is invalid")
                    XCTAssert(contact!.email == request.email, "Contact object is invalid")
                    XCTAssert(contact!.zipCode == request.zipCode, "Contact object is invalid")
                    XCTAssert(contact!.birthday == request.birthdate, "Contact object is invalid")
                    XCTAssert((contact!.emailOptin != 0) == request.emailOptIn, "Contact object is invalid")
                    XCTAssert(contact!.preferredReward == request.preferredReward, "Contact object is invalid")
                    XCTAssert(contact!.gender == request.gender, "Contact object is invalid")
                  }
                  
                  let user1Contact = self.getMetadata()!.getRegisteredUser1Contact()
                  let request = UpdateContactRequest(contact: user1Contact)
                  request.firstName = user1Contact.firstName
                  request.lastName = user1Contact.lastName
                  request.phone = user1Contact.phone
                  request.email = user1Contact.email
                  request.zipCode  = user1Contact.zipCode
                  request.birthdate = user1Contact.birthday
                  request.emailOptIn = (user1Contact.emailOptin != 0)
                  request.preferredReward = ""
                  request.gender = user1Contact.gender!
                  
                  coreServiceHandler.updateContact(contact!, request: request, handler: { (result) in
                    XCTAssert(contact != nil, "Update contact request finished with error")
                    
                    if result {
                      coreServiceHandler.getContact({ (contact) in
                        XCTAssert(contact != nil, "Get contact request finished with error")
                        
                        if contact != nil {
                          XCTAssert(contact!.firstName == user1Contact.firstName, "Contact object is invalid")
                          XCTAssert(contact!.lastName == user1Contact.lastName, "Contact object is invalid")
                          XCTAssert(contact!.phone == user1Contact.phone, "Contact object is invalid")
                          XCTAssert(contact!.email == user1Contact.email, "Contact object is invalid")
                          XCTAssert(contact!.zipCode == user1Contact.zipCode, "Contact object is invalid")
                          XCTAssert(contact!.birthday == user1Contact.birthday, "Contact object is invalid")
                          XCTAssert(contact!.emailOptin == user1Contact.emailOptin, "Contact object is invalid")
                          XCTAssert(contact!.preferredReward == user1Contact.preferredReward, "Contact object is invalid")
                          XCTAssert(contact!.gender == user1Contact.gender, "Contact object is invalid")
                        }
                      })
                    }
                  })
                })
              }
            })
          }
        })
      }
    }
  }
}
