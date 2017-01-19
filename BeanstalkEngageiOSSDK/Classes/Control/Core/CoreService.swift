//
//  CoreService.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import PKHUD

import BeanstalkEngageiOSSDK

public class CoreService{
  let apiService: ApiCommunication
  let session: BESession
  
  public required init(apiKey: String, session: BESession) {
    self.apiService = ApiCommunication(apiKey: apiKey)
    self.session = session
  }
  
  public func isAuthenticated() ->Bool{
    let contactId = session.getContactId()
    let token = session.getAuthToken()
    return contactId != nil && token != nil
  }
  
  public func registerLoyaltyAccount(controller: RegistrationProtocol?, request: CreateContactRequest, handler: (Bool) -> Void){
    if (controller != nil) {
      guard controller!.validate(request) else{
        handler(false)
        return
      }
    }
    
    request.phone = request.phone?.formatPhoneNumberToNationalSignificant()
    
    controller?.showProgress("Registering User")
    apiService.createLoyaltyAccount(request, handler: { (result) in
      controller?.hideProgress()
      
      if result.isFailure {
        controller?.showMessage(result.error!)
        handler(false)
      } else {
        self.auth(controller, email : request.email!, password: request.password!, handler: handler)
      }
    })
  }
  
  public func register(controller : RegistrationProtocol?, request : CreateContactRequest, handler : (Bool) -> Void){
    if (controller != nil) {
      guard controller!.validate(request) else{
        handler(false)
        return
      }
    }
    
    request.phone = request.phone?.formatPhoneNumberToNationalSignificant()
    
    controller?.showProgress("Registering User")
    if request.novadine {
      apiService.createContact(request, handler: { (result) in
        controller?.hideProgress()
        
        if result.isFailure {
          controller?.showMessage(result.error!)
          handler(false)
        } else {
          self.auth(controller, email : request.email!, password: request.password!, handler: handler)
        }
      })
    } else {
      apiService.checkContactsByEmailExisted(request.email!, handler: { (result) in
        
        if result.isFailure {
          controller?.hideProgress()
          controller?.showMessage(.UserEmailExists(reason: result.error!))
          handler(false)
        } else {
          var updateExisted = result.value!
          
          self.apiService.checkContactsByPhoneExisted(request.phone!, handler: { (result) in
            
            if result.isFailure {
              controller?.hideProgress()
              controller?.showMessage(.UserPhoneExists(reason: result.error!))
              handler(false)
            } else {
              updateExisted = updateExisted || result.value!
              
              self.apiService.createContact(request, handler: { (result) in
                
                if result.isFailure {
                  controller?.hideProgress()
                  controller?.showMessage(result.error!)
                  handler(false)
                } else {
                    if !updateExisted {
                      self.apiService.createUser(request.email!, password: request.password!, contactId: result.value!, handler: { (result) in
                        
                        if result.isFailure {
                          controller?.hideProgress()
                          controller?.showMessage(result.error!)
                          handler(false)
                        } else {
                          self.auth(controller, email: request.email!, password: request.password!, handler: handler)
                        }
                      })
                    } else {
                      self.auth(controller, email: request.email!, password: request.password!, handler: handler)
                    }
                }
              })
            }
          })
        }
      })
    }
  }
  
  public func authenticate(controller: AuthenticationProtocol?, email: String?, password: String?, handler : ((success: Bool, additionalInfo : Bool) -> Void)) {
    if controller != nil {
      guard controller!.validate(email, password: password) else {
        handler(success: false, additionalInfo: false)
        return
      }
    }
    
    controller?.showProgress("Attempting to Login")
    apiService.checkContactIsNovadine(email!, handler: { (result) in
      let isNovadineContact = (result.value != nil) ? result.value! : false
      self.apiService.authenticateUser(email!, password: password!, handler: { (result) in
        controller?.hideProgress()
        
        if result.isFailure {
          controller?.showMessage(result.error!)
          handler(success: false, additionalInfo: isNovadineContact)
        } else {
          self.session.setContactId(result.value!.contactId)
          self.session.setAuthToke(result.value!.token)
          
          if let deviceToken = self.session.getAPNSToken() {
            self.pushNotificationEnroll(deviceToken, handler: { (success, error) in
              handler(success: true, additionalInfo: isNovadineContact)
            })
          } else {
            handler(success: true, additionalInfo: isNovadineContact)
          }
        }
      })
    })
  }
  
  public func resetPassword(controller: AuthenticationProtocol?, email : String?, handler : () -> Void) {
    if controller != nil {
      guard controller!.validate(email, password: "123456") else{
        handler()
        return
      }
    }
    controller?.showProgress("Reseting Password")
    apiService.resetPassword(email!, handler: { (result) in
      controller?.hideProgress()
      
      if result.isFailure {
        controller?.showMessage(.ResetPasswordError(reason: result.error!))
      } else {
        controller?.showMessage("Password reset", message: result.value!)
      }
      
      handler()
    })
  }
  
  public func logout(controller : CoreProtocol?, handler : (success: Bool) -> Void){
    let contactId = session.getContactId()!
    let token = session.getAuthToken()!
    let registeredDeviceToken = session.getRegisteredAPNSToken()
    
    controller?.showProgress("Logout...")
    apiService.logoutUser(contactId, token : token, handler: { (result) in
      controller?.hideProgress()
      
      if registeredDeviceToken != nil {
        self.pushNotificationDelete({ (success, error) in
          handler(success: success)
        })
        
        self.session.setContactId(nil)
        self.session.setAuthToke(nil)
        
      } else {
        self.session.setContactId(nil)
        self.session.setAuthToke(nil)
        
        handler(success: result.isSuccess)
      }
    })
  }
  
  public func getContact(controller : CoreProtocol?, handler : (BEContact?) -> Void){
    let contactId = session.getContactId()!

    controller?.showProgress("Retrieving Profile")
    apiService.getContact(contactId, handler: { (result) in
      controller?.hideProgress()
      
      if result.isFailure {
        controller?.showMessage(.ProfileError(reason: result.error!))
        handler(nil)
      } else {
        handler(result.value!)
      }
    })
  }
  
  public func updateContact(controller : EditProfileProtocol?, original: BEContact, request : UpdateContactRequest, handler : (Bool) -> Void){
    
    if controller != nil {
      guard controller!.validate(request) else{
        handler(false)
        return
      }
    }
    
    request.phone = request.phone?.formatPhoneNumberToNationalSignificant()
    
    controller?.showProgress("Updating Profile")
    apiService.updateContact(original, request: request, handler: { (result) in
      controller?.hideProgress()
      
      if result.isFailure {
        controller?.showMessage(.UpdateProfileError(reason: result.error!))
        handler(false)
      } else {
        handler(true)
      }
    })
  }
  
  public func updatePassword(controller : UpdatePasswordProtocol?, password: String?, confirmPassword: String?, handler : (Bool) -> Void){
    
    if controller != nil {
      guard controller!.validate(password, confirmPassword: confirmPassword) else{
        handler(false)
        return
      }
    }
    
    let contactId = session.getContactId()!
    let token = session.getAuthToken()!
    
    controller?.showProgress("Updating Password")
    apiService.updatePassword(password!, contactId: contactId, token: token, handler: { (result) in
      controller?.hideProgress()
      
      if result.isFailure {
        controller?.showMessage(.UpdatePasswordError(reason: result.error!))
        handler(false)
      } else {
        handler(true)
      }
    })
  }
  
  public func getAvailableRewards(controller : CoreProtocol?, handler : ([BECoupon])->Void){
    let contactId = session.getContactId()!
    
    controller?.showProgress("Retrieving Rewards")
    apiService.getUserOffers(contactId, handler : { (result) in
      controller?.hideProgress()
      
      var rewards = [BECoupon]()
      if result.isFailure {
        controller?.showMessage(result.error!)
      } else {
        rewards = result.value!
      }
      
      handler(rewards)
    })
  }
  
  public func getUserProgress(controller : CoreProtocol?, handler : (Int, String)->Void){
    let contactId = session.getContactId()!
    
    controller?.showProgress("Getting Rewards")
    apiService.getProgress(contactId, handler : { (result) in
      controller?.hideProgress()
      
      let required = 8
      var progressValue = 0;
      var progressText = "Only \(required) more purchases until your next TC reward!"
      
      if result.isFailure {
        //Check it
      } else {
        let rewardValue = result.value! == nil ? 0 : Int(result.value!!)
        if (rewardValue > 0 && rewardValue % required == 0) {
          progressValue = required;
        } else {
          progressValue = rewardValue % required;
        }
        
        let remainingCountUntilReward = required - progressValue;
        if (progressValue == 8) {
          progressText = "Congrats !! you have a TC reward!"
        } else {
          progressText = "Only \(remainingCountUntilReward) more purchases until your next TC reward!"
        }
      }
      
      handler(progressValue, progressText)
    })
  }
  
  public func getGiftCards(controller : CoreProtocol?, handler : ([BEGiftCard])->Void){
    let contactId = session.getContactId()!
    let token = session.getAuthToken()!
    
    controller?.showProgress("Retrieving Cards")
    apiService.getGiftCards(contactId, token: token, handler: { (result) in
      controller?.hideProgress()
      
      if result.isFailure {
        controller?.showMessage(.GiftCardsError(reason: result.error!))
        handler([])
      } else {
        let cards = result.value!
        
        handler(cards)
      }
    })
  }
  
  public func startPayment(controller : CoreProtocol?, cardId : String?, coupons: [BECoupon], handler : (String, String)->Void){

    if cardId == nil && coupons.count == 0 {
      let data = getBarCodeInfo(nil, cardId: cardId, coupons: coupons)
      handler(data.0, data.1)
      return
    }

    let contactId = session.getContactId()!
    let token = session.getAuthToken()!
    let couponsString : String = coupons.reduce("", combine: { $0 == "" ? $1.number! : $0 + "," + $1.number! })
    
    controller?.showProgress("Generating Barcode")
    apiService.startPayment(contactId, token: token, paymentId: cardId, coupons: couponsString, handler : { (result) in
      controller?.hideProgress()
      
      if result.isFailure {
        controller?.showMessage(.PaymentError(reason: result.error!))
        let data = self.getBarCodeInfo(nil, cardId: cardId, coupons: coupons)
        handler(data.0, data.1)
      } else {
        let cards = result.value!
        
        let data = self.getBarCodeInfo(result.value!, cardId: cardId, coupons: coupons)
        handler(data.0, data.1)
      }
    })
  }
  
  //MARK: - Push Notifications
  
  public func pushNotificationEnroll(deviceToken: String, handler: (success: Bool, error: ApiError?) -> Void) {
    if let contactId = self.session.getContactId() {
      apiService.pushNotificationEnroll(contactId, deviceToken: deviceToken, handler: { (result) in
        if result.isFailure {
          handler(success: false, error: result.error)
        }
        else if result.value! != nil {
          self.session.setRegisteredAPNSToken(deviceToken)
          
          handler(success: true, error: nil)
        }
        else {
          handler(success: false, error: nil)
        }
      })
    }
    else {
      handler(success: false, error: nil)
    }
  }
  
  public func pushNotificationDelete(handler: (success: Bool, error: ApiError?) -> Void) {
    if let contactId = self.session.getContactId() {
      apiService.pushNotificationDelete(contactId, handler: { (result) in
        
        if result.isFailure {
          handler(success: false, error: result.error)
        }
        else if result.value! != nil {
          handler(success: true, error: nil)
        }
        else {
          handler(success: false, error: nil)
        }
      })
    }
    else {
      handler(success: false, error: nil)
    }
    
    self.session.setRegisteredAPNSToken(nil)
  }
  
  
  //MARK: - Locations
  
  public func getStoresAtLocation(controller : CoreProtocol?, coordinate: CLLocationCoordinate2D, handler : ((success: Bool, stores : [BEStore]?) -> Void)) {
    let longitude = "\(coordinate.longitude)"
    let latitude = "\(coordinate.latitude)"
    let token = session.getAuthToken()
    
    controller?.showProgress("Retrieving Stores")
    apiService.getStoresAtLocation (longitude, latitude: latitude, token: token, handler: { (result) in
      controller?.hideProgress()
      
      if result.isFailure {
        controller?.showMessage(.FindStoresError(reason: result.error!))
        handler(success: false, stores: [])
      } else {
        handler(success: true, stores: result.value!)
      }
    })
  }
  
  
  //No needs to check isNoadine user
  private func auth(controller : RegistrationProtocol?, email: String, password: String, handler : (Bool) -> Void) {
    
    controller?.showProgress("Attempting to Login")
    apiService.authenticateUser(email, password: password, handler: { (result) in
      controller?.hideProgress()
    
      if result.isFailure {
        controller?.showMessage(result.error!)
        handler(false)
      } else {
        let contactId = result.value!.contactId
        let token = result.value!.token
        
        self.session.setContactId(contactId)
        self.session.setAuthToke(token)
        
        if let deviceToken = self.session.getAPNSToken() {
          self.pushNotificationEnroll(deviceToken, handler: { (success, error) in
            
          })
        }
        
        handler(true)
      }
    })
  }
  
  // TODO: fixme
//  private func getBalanceForCard(controller : CoreProtocol , contactId: String, token: String, index: Int, cards : [BEGiftCard], handler :([BEGiftCard])->Void){
//    
//    if index == 0 {
//      dispatch_async(dispatch_get_main_queue(),{
//        // controller.showProgress("Retrieving Cards Balances")
//      })
//    }
//    apiService.getGiftCardBalance(contactId, token: token, number: cards[index].number!, handler: {
//      data, error in
//      debugPrint("index \(index)")
//      if index == cards.count-1 {
//        controller.hideProgress()
//      }
//      if error == nil {
//        cards[index].balance = data?.getCardBalance()
//      }
//      if index == cards.count-1 {
//        handler(cards)
//      }else {
//        self.getBalanceForCard(controller, contactId: contactId, token: token, index: index + 1, cards: cards, handler: handler)
//      }
//    })
//  }
  
  private func getBarCodeInfo(data: String?, cardId : String?, coupons : [BECoupon]) -> (String, String){
    var content = ""
    var display = ""
    if data == nil || data!.characters.count == 0{
      let contactId = session.getContactId()!
      content = contactId
      display = "Member ID: \(content)"
    }else {
      content = data!
      if cardId == nil && coupons.count > 0 {
        display = "Rewards Token: \(content)"
      } else if cardId != nil  && coupons.count == 0 {
        display = "Pay Token: \(content)"
      }else {
        display = "Rewards and Pay Token: \(content)"
      }
    }
    return (content, display)
  }
  
}

public extension UIViewController {
  func validate(request : CreateContactRequest) -> Bool{
    guard !(request.firstName?.isEmpty)! else{
      self.showMessage("Registration Error", message: "Enter First Name")
      return false
    }
    guard !(request.lastName?.isEmpty)! else{
      self.showMessage("Registration Error", message: "Enter Last Name")
      return false
    }
    guard (request.phone?.isValidPhone())! else{
      self.showMessage("Registration Error", message: "Please enter a valid phone number")
      return false
    }
    guard !(request.birthdate?.isEmpty)! else{
      self.showMessage("Registration Error", message: "Enter Birthdate")
      return false
    }
    guard (request.zipCode?.isValidZipCode())! else{
      self.showMessage("Registration Error", message: "Enter 5 Digit Zipcode")
      return false
    }
    if !request.novadine{
      guard (request.email?.isValidEmail())! else{
        self.showMessage("Registration Error", message: "Enter Valid Email")
        return false
      }
      guard request.email == request.emailConfirm else{
        self.showMessage("Registration Error", message: "Emails do not match")
        return false
      }
      guard !(request.password?.isEmpty)! else{
        self.showMessage("Registration Error", message: "Enter Password")
        return false
      }
      guard request.password == request.passwordConfirm else{
        self.showMessage("Registration Error", message: "Passwords do not match")
        return false
      }
    }
    return true
  }
  
  func validate(request : UpdateContactRequest) -> Bool{
    guard !(request.firstName?.isEmpty)! else{
      self.showMessage("Update Error", message: "Enter First Name")
      return false
    }
    guard !(request.lastName?.isEmpty)! else{
      self.showMessage("Update Error", message: "Enter Last Name")
      return false
    }
    guard (request.phone?.isValidPhone())! else{
      self.showMessage("Update Error", message: "Please enter a valid phone number")
      return false
    }
    guard !(request.birthdate?.isEmpty)! else{
      self.showMessage("Update Error", message: "Enter Birthdate")
      return false
    }
    guard (request.zipCode?.isValidZipCode())! else{
      self.showMessage("Update Error", message: "Enter 5 Digit Zipcode")
      return false
    }
    guard (request.email?.isValidEmail())! else{
      self.showMessage("Update Error", message: "Enter Valid Email")
      return false
    }
    return true
  }
  
  func validate(email : String?, password : String?) -> Bool {
    guard (email?.isValidEmail())! else{
      self.showMessage("Login Error", message: "Enter Valid Email")
      return false
    }
    guard !(password?.isEmpty)! else{
      self.showMessage("Login Error", message: "Enter Password")
      return false
    }
    return true
  }
  
  func validate(password : String?, confirmPassword : String?) -> Bool {
    guard !(password?.isEmpty)! else{
      self.showMessage("Update Error", message: "Enter Password")
      return false
    }
    guard password == confirmPassword else{
      self.showMessage("Update Error", message: "Passwords do not match")
      return false
    }
    return true
  }
}
