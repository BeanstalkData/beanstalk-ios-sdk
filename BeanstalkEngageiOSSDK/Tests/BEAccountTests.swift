import UIKit
import XCTest

import ObjectMapper

open class BEAccountTests: BEBaseTestCase {
    
  open func loginRegisteredUserTest() {
    
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    coreServiceHandler.signIn(getMetadata()!.getRegisteredUser1Email(), password: getMetadata()!.getRegisteredUser1Password()) { (result) in
      XCTAssert(result, "Login request finished with error")
      
      if (result) {
        coreServiceHandler.signOut() { (result) in
          XCTAssert(result, "Logout request finished with error")
        }
      }
    }
  }
  
  open func autoLoginRegisteredUserTest() {
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    coreServiceHandler.autoSignIn( { result in
      XCTAssert(!result, "Unexpected Auto Login status, should be false")
      
      coreServiceHandler.signIn(self.getMetadata()!.getRegisteredUser1Email(), password: self.getMetadata()!.getRegisteredUser1Password()) { (result) in
        XCTAssert(result, "Login request finished with error")
        
        coreServiceHandler.autoSignIn( { result in
          XCTAssert(result, "Unexpected Auto Login status, should be true")
          
          coreServiceHandler.signOut() { result in
            XCTAssert(result, "Logout request finished with error")
            
            coreServiceHandler.autoSignIn( { result in
              XCTAssert(!result, "Unexpected Auto Login status, should be false")
            })
          }
        })
      }
    })
  }

  open func autoLoginUnRegisteredUserTest() {
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    coreServiceHandler.autoSignIn( { result in
      XCTAssert(!result, "Unexpected Auto Login status, should be false")
      
      coreServiceHandler.signIn("invalid@email.com", password: "123456789") { (result) in
        XCTAssert(!result, "Unexpected Login request state, should be false")
        
        coreServiceHandler.autoSignIn( { result in
          XCTAssert(!result, "Unexpected Auto Login status, should be false")
        })
      }
    })
  }

  open func loginRegisteredUserWithValidPushTest() {
    
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let pushToken = getMetadata()!.getValidAPNSToken()
    
    self.getSession()?.setAPNSToken(pushToken)
    self.getSession()?.setRegisteredAPNSToken(nil)
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    coreServiceHandler.signIn(getMetadata()!.getRegisteredUser1Email(), password: getMetadata()!.getRegisteredUser1Password()) { (result) in
      XCTAssert(result, "Login request finished with error")
      
      XCTAssert(self.getSession()?.getAPNSToken() == pushToken, "Invalid APNS token after login")
      
      if (result) {
        coreServiceHandler.signOut() { (result) in
          XCTAssert(self.getSession()?.getAPNSToken() == pushToken, "Invalid APNS token after logout")
          XCTAssert(self.getSession()?.getRegisteredAPNSToken() == nil, "Invalid APNS token after logout")
        }
      }
    }
  }
  
  open func loginRegisteredUserWithInvalidPushTest() {
    
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let pushToken = getMetadata()!.getInvalidAPNSToken()
    
    self.getSession()?.setAPNSToken(pushToken)
    self.getSession()?.setRegisteredAPNSToken(nil)
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    coreServiceHandler.signIn(getMetadata()!.getRegisteredUser1Email(), password: getMetadata()!.getRegisteredUser1Password()) { (result) in
      XCTAssert(result, "Login request finished with error")
      
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
  
  open func resetPasswordTest() {
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    coreServiceHandler.resetPassword("invalidEmail@InvalidEmail.com") { (result) in
      XCTAssert(result == false, "Success reset password for invalid user email")
      
      coreServiceHandler.resetPassword(self.getMetadata()!.getRegisteredUserEmail()) { (result) in
        XCTAssert(result == true, "Failed to reset password for valid user email")
      }
    }
  }
  
  open func updatePasswordTest() {
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
  
  open func loyaltyAccountParsingTest() {
    let JSON: [String: AnyObject] = [
      "giftCardTrack2" : ";5022111100001111222=12344321111111?" as AnyObject,
      "contactId" : "12341234" as AnyObject,
      "sessionToken" : "42f5481997c18f778c973170c3ad4317f7eeb830" as AnyObject,
      "giftCardNumber" : "5022111100001111222" as AnyObject,
      "giftCardRegistrationStatus" : true as AnyObject,
      "giftCardPin" : NSNull()
    ]
    
    self.loyaltyAccountParsingTest(JSON)
  }
  
  open func loyaltyAccountParsingTest(_ JSON: [String: AnyObject]) {
    let map = Map(mappingType: .fromJSON, JSON: JSON)
    
    var loyaltyAccount = BELoyaltyUser(map: map)
    loyaltyAccount?.mapping(map: map)
    
    XCTAssert(loyaltyAccount!.contactId == JSON["contactId"] as? String, "Loyalty account object is invalid")
    XCTAssert(loyaltyAccount!.sessionToken == JSON["sessionToken"] as? String, "Loyalty account object is invalid")
    XCTAssert(loyaltyAccount!.giftCardNumber == JSON["giftCardNumber"] as? String, "Loyalty account object is invalid")
    XCTAssert(loyaltyAccount!.giftCardPin == JSON["giftCardPin"] as? String, "Loyalty account object is invalid")
    XCTAssert(loyaltyAccount!.giftCardRegistrationStatus == JSON["giftCardRegistrationStatus"]  as? Bool, "Loyalty account object is invalid")
    XCTAssert(loyaltyAccount!.giftCardTrack2 == JSON["giftCardTrack2"] as? String, "Loyalty account object is invalid")
  }
  
  open func registerLoyaltyAccountTest() {
    
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    let contact = getMetadata()!.getRegisteredUser1Contact()
    let request = ContactRequest()
    request.set(firstName: contact.firstName)
    request.set(lastName: contact.lastName)
    request.set(phone: contact.phone)
    request.set(email: contact.email)
    request.set(password: getMetadata()!.getRegisteredUser1Password())
    request.set(zipCode: contact.zipCode)
    request.set(birthday: contact.birthday)
    request.set(emailOptin: (contact.emailOptin != 0))
    request.set(pushNotificationOptin: (contact.pushNotificationOptin != 0))
    request.set(inboxMessageOptin: (contact.inboxMessageOptin != 0))
    request.set(textOptin: (contact.textOptin != 0))
    request.set(gender: contact.gender)
    
    coreServiceHandler.registerLoyaltyAccount(request) { (result) in
      
      XCTAssert(result, "Register Loyalty Account request finished with error")
      
      if (result) {
        coreServiceHandler.signOut() { (result) in
          XCTAssert(result, "Logout request finished with error")
        }
      }
    }
  }
  
  open func registerAccountTest() {
    
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    let contact = getMetadata()!.getRegisteredUser1Contact()
    let request = ContactRequest()
    request.set(firstName: contact.firstName)
    request.set(lastName: contact.lastName)
    request.set(phone: contact.phone)
    request.set(email: contact.email)
    request.set(password: getMetadata()!.getRegisteredUser1Password())
    request.set(zipCode: contact.zipCode)
    request.set(birthday: contact.birthday)
    request.set(emailOptin: (contact.emailOptin != 0))
    request.set(pushNotificationOptin: (contact.pushNotificationOptin != 0))
    request.set(inboxMessageOptin: (contact.inboxMessageOptin != 0))
    request.set(textOptin: (contact.textOptin != 0))
    request.set(gender: contact.gender)
    
    coreServiceHandler.registerAccount(request) { (result) in
      
      XCTAssert(result, "Register Account request finished with error")
      
      if (result) {
        coreServiceHandler.signOut() { (result) in
          XCTAssert(result, "Logout request finished with error")
        }
      }
    }
  }
  
  open func getContactTest<ContactClass: BEContact>(_ contactClass: ContactClass.Type) {
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    coreServiceHandler.signIn(getMetadata()!.getRegisteredUser1Email(), password: getMetadata()!.getRegisteredUser1Password()) { (result) in
      XCTAssert(result, "Login request finished with error")
      
      if (result) {
        
        coreServiceHandler.getContact(contactClass, handler:{ (contact) in
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
  
  open func updateContactTest<ContactClass: BEContact>(_ contactClass: ContactClass.Type) {
    self.getSession()?.clearSession()
    self.getSession()?.clearApnsTokens()
    
    let coreServiceHandler = BECoreServiceTestHandler.create(self)
    
    coreServiceHandler.signIn(getMetadata()!.getRegisteredUser1Email(), password: getMetadata()!.getRegisteredUser1Password()) { (result) in
      XCTAssert(result, "Login request finished with error")
      
      if (result) {
        
        coreServiceHandler.getContact({ (contact) in
          XCTAssert(contact != nil, "Get contact request finished with error")
          
          if contact != nil {
            
            let request = ContactRequest(origin: contact!)
            request.set(firstName: contact!.firstName! + "1")
            request.set(lastName: contact!.lastName! + "1")
            request.set(phone: contact!.phone)
            request.set(email: contact!.email! + "m")
            request.set(zipCode: contact!.zipCode! + "1")
            request.set(birthday: contact!.birthday)
            request.set(emailOptin: (contact!.emailOptin != 0))
            request.set(gender: contact!.gender)
            
            coreServiceHandler.updateContact(request: request, handler: { (result) in
              XCTAssert(result, "Update contact request finished with error")
              
              if result {
                coreServiceHandler.getContact({ (contact) in
                  XCTAssert(contact != nil, "Get contact request finished with error")
                  
                  if contact != nil {
                    XCTAssert(contact!.firstName == request.getFirstName(), "Contact object is invalid")
                    XCTAssert(contact!.lastName == request.getLastName(), "Contact object is invalid")
                    XCTAssert(contact!.phone == request.getPhone(), "Contact object is invalid")
                    XCTAssert(contact!.email == request.getEmail(), "Contact object is invalid")
                    XCTAssert(contact!.zipCode == request.getZipCode(), "Contact object is invalid")
                    XCTAssert(contact!.birthday == request.origin!.birthday, "Contact object is invalid")
                    XCTAssert(contact!.emailOptin == request.origin!.emailOptin, "Contact object is invalid")
                    XCTAssert(contact!.gender == request.origin!.gender, "Contact object is invalid")
                  
                    let request = ContactRequest(origin: contact!)
                    
                    let user1Contact = self.getMetadata()!.getRegisteredUser1Contact()
                    request.set(firstName: user1Contact.firstName)
                    request.set(lastName: user1Contact.lastName)
                    request.set(phone: user1Contact.phone)
                    request.set(email: user1Contact.email)
                    request.set(zipCode: user1Contact.zipCode)
                    request.set(birthday: user1Contact.birthday)
                    request.set(emailOptin: (user1Contact.emailOptin != 0))
                    request.set(gender: user1Contact.gender)
                    
                    coreServiceHandler.updateContact(request: request, handler: { (result) in
                      XCTAssert(result, "Update contact request finished with error")
                      
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
                            XCTAssert(contact!.gender == user1Contact.gender, "Contact object is invalid")
                          }
                        })
                      }
                    })
                  }
                })
              }
            })
          }
        })
      }
    }
  }
  
  open func userInfoTest() {

    XCTAssert("test102@email.net".isValidEmail(), "Email should be valid")
    XCTAssert("test102@email.uk.net".isValidEmail(), "Email should be valid")
    XCTAssert("test_102@email.net".isValidEmail(), "Email should be valid")
    XCTAssert("tes_t_102@email.net".isValidEmail(), "Email should be valid")
    XCTAssert("test.102@email.net".isValidEmail(), "Email should be valid")
    XCTAssert("test%102@email.net".isValidEmail(), "Email should be valid")
    XCTAssert("test-102@email.net".isValidEmail(), "Email should be valid")
    XCTAssert("test+102@email.net".isValidEmail(), "Email should be valid")
    XCTAssert("test_102@e-mail.net".isValidEmail(), "Email should be valid")
    XCTAssert("test_102@email.n-et".isValidEmail(), "Email should be valid")
    XCTAssert("test_102@email.n".isValidEmail(), "Email should be valid")
    
    XCTAssert(!("test_102@-email.net").isValidEmail(), "Email should be valid")
    XCTAssert(!("test_102@_email.net".isValidEmail()), "Email should be invalid")
    XCTAssert(!(".test102@email.net".isValidEmail()), "Email should be invalid")
    XCTAssert(!("test102@email.net.".isValidEmail()), "Email should be invalid")
    XCTAssert(!("test102@email.".isValidEmail()), "Email should be invalid")
    XCTAssert(!("_test102@email.net".isValidEmail()), "Email should be invalid")
    XCTAssert(!("test102@email.net_".isValidEmail()), "Email should be invalid")
    XCTAssert(!("te__st102@email.net".isValidEmail()), "Email should be invalid")
    XCTAssert(!("te___st102@email.net".isValidEmail()), "Email should be invalid")
    XCTAssert(!("test102@email..net".isValidEmail()), "Email should be invalid")
    XCTAssert(!("test102@email..uk.net".isValidEmail()), "Email should be invalid")
    XCTAssert(!("test102@email.uk..net".isValidEmail()), "Email should be invalid")
  }
}
