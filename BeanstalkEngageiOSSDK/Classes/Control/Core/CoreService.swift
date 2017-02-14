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

import Alamofire
import BeanstalkEngageiOSSDK

public typealias CoreService = CoreServiceT<HTTPAlamofireManager>

public class CoreServiceT <SessionManager: HTTPAlamofireManager> {
  let apiService: ApiCommunication<SessionManager>
  let session: BESession
  
  private var p_isAuthenticateInProgress = false
  public var isAuthenticateInProgress: Bool {
    get {
      return self.p_isAuthenticateInProgress
    }
  }
  
  public required init(apiKey: String, session: BESession) {
    self.apiService = ApiCommunication(apiKey: apiKey)
    self.session = session
  }
  
  public func getSession() -> BESession? {
    return session
  }
  
  public func clearSession() {
    self.session.clearSession()
  }
  
  public func isAuthenticated() ->Bool{
    let contactId = session.getContactId()
    let token = session.getAuthToken()
    return contactId != nil && token != nil
  }
  
  public func registerLoyaltyAccount <ContactClass: BEContact> (controller: RegistrationProtocol?, request: ContactRequest, contactClass: ContactClass.Type, handler: (Bool) -> Void){
    if (controller != nil) {
      guard controller!.validate(request) else{
        handler(false)
        return
      }
    }
    
    request.set(phone: request.phone?.formatPhoneNumberToNationalSignificant())
    
    controller?.showProgress("Registering User")
    apiService.createLoyaltyAccount(request, handler: { (result) in
      controller?.hideProgress()
      
      if result.isFailure {
        controller?.showMessage(result.error!)
        handler(false)
      } else {
        self.auth(controller, email : request.email!, password: request.password!, contactClass: contactClass, handler: handler)
      }
    })
  }
  
  public func register <ContactClass: BEContact> (controller : RegistrationProtocol?, request : ContactRequest, contactClass: ContactClass.Type, handler : (Bool) -> Void) {
    if (controller != nil) {
      guard controller!.validate(request) else{
        handler(false)
        return
      }
    }
    
    request.set(phone: request.phone?.formatPhoneNumberToNationalSignificant())
    
    controller?.showProgress("Registering User")
    if request.isNovadine() {
      apiService.createContact(request, handler: { (result) in
        controller?.hideProgress()
        
        if result.isFailure {
          controller?.showMessage(result.error!)
          handler(false)
        } else {
          self.auth(controller, email : request.email!, password: request.password!, contactClass: contactClass, handler: handler)
        }
      })
    } else {
      apiService.checkContactsByEmailExisted(request.email!, prospectTypes: [.eClub, .Loyalty], handler: { (result) in
        
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
                          self.auth(controller, email: request.email!, password: request.password!, contactClass: contactClass, handler: handler)
                        }
                      })
                    } else {
                      self.auth(controller, email: request.email!, password: request.password!, contactClass: contactClass, handler: handler)
                    }
                }
              })
            }
          })
        }
      })
    }
  }
  
  public func autoSignIn <ContactClass: BEContact> (controller: AuthenticationProtocol?, contactClass: ContactClass.Type, handler : ((success: Bool) -> Void)) {

    let contactId = session.getContactId()
    let token = session.getAuthToken()
    
    guard (contactId != nil && token != nil) else {
      handler(success: false)
      return
    }
    
    self.p_isAuthenticateInProgress = true
    controller?.showProgress("Attempting to Login")
    
    self.apiService.checkUserSession(contactId!, token: token!) { result in
      controller?.hideProgress()
      
      if result.isFailure {
        self.p_isAuthenticateInProgress = false
        controller?.showMessage(result.error!)
        handler(success: false)
      } else {
        self.handleLoginComplete(contactId, token: token, contactClass: contactClass, handler: { result in
          self.p_isAuthenticateInProgress = false
          handler(success: result)
        })
      }
    }
  }
  
  public func authenticate <ContactClass: BEContact> (controller: AuthenticationProtocol?, email: String?, password: String?, contactClass: ContactClass.Type, handler : ((success: Bool, additionalInfo : Bool) -> Void)) {
    if controller != nil {
      guard controller!.validate(email, password: password) else {
        handler(success: false, additionalInfo: false)
        return
      }
    }
    
    self.p_isAuthenticateInProgress = true
    controller?.showProgress("Attempting to Login")
    apiService.checkContactIsNovadine(email!, handler: { (result) in
      let isNovadineContact = (result.value != nil) ? result.value! : false
      self.apiService.authenticateUser(email!, password: password!, handler: { (result) in
        controller?.hideProgress()
        
        if result.isFailure {
          self.p_isAuthenticateInProgress = false
          controller?.showMessage(result.error!)
          handler(success: false, additionalInfo: isNovadineContact)
        } else {
          let contactId = result.value!.contactId
          let token = result.value!.token
          self.handleLoginComplete(contactId, token: token, contactClass: contactClass, handler: { result in
            self.p_isAuthenticateInProgress = false
            handler(success: result, additionalInfo: isNovadineContact)
          })
        }
      })
    })
  }
  
  //No needs to check isNoadine user
  private func auth <ContactClass: BEContact> (controller : RegistrationProtocol?, email: String, password: String, contactClass: ContactClass.Type, handler : (Bool) -> Void) {
    
    self.p_isAuthenticateInProgress = true
    controller?.showProgress("Attempting to Login")
    apiService.authenticateUser(email, password: password, handler: { (result) in
      controller?.hideProgress()
      
      if result.isFailure {
        self.p_isAuthenticateInProgress = false
        controller?.showMessage(result.error!)
        handler(false)
      } else {
        let contactId = result.value!.contactId
        let token = result.value!.token
        self.handleLoginComplete(contactId, token: token, contactClass: contactClass, handler: { result in
          self.p_isAuthenticateInProgress = false
          handler(result)
        })
      }
    })
  }
  
  private func handleLoginComplete <ContactClass: BEContact> (contactId : String?, token : String?, contactClass: ContactClass.Type, handler : (Bool) -> Void) {
    
    guard (contactId != nil && token != nil) else {
      self.clearSession()
      handler(false)
      return
    }
    
    apiService.getContact(contactId!, contactClass: contactClass, handler: { (result) in
      if result.isSuccess {
        self.session.setContact(result.value!)
      } else {
        self.session.setContact(nil)
      }
      self.session.setAuthToke(token)
      handler(result.isSuccess)
    })
  }
  
  public func resetPassword(controller: AuthenticationProtocol?, email : String?, handler : (success: Bool) -> Void) {
    if controller != nil {
      guard controller!.validate(email, password: "123456") else{
        handler(success: false)
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
      
      handler(success: !result.isFailure)
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
        
        self.clearSession()
      } else {
        self.clearSession()
        
        handler(success: result.isSuccess)
      }
    })
  }
  
  public func checkContactsByEmailExisted(
    controller: CoreProtocol?,
    email: String,
    prospectTypes: [ProspectType],
    handler : (Bool?) -> Void
    ) {
    controller?.showProgress("Checking email")
    apiService.checkContactsByEmailExisted(email, prospectTypes: prospectTypes) { (result) in
      controller?.hideProgress()
      
      if result.isFailure {
        controller?.showMessage(.UserEmailExists(reason: result.error!))
        handler(nil)
      } else {
        handler(result.value!)
      }
    }
  }
  
  public func getContact <ContactClass: BEContact> (controller : CoreProtocol?, contactClass: ContactClass.Type, handler : (BEContact?) -> Void) {
    let contactId = session.getContactId()!

    controller?.showProgress("Retrieving Profile")
    apiService.getContact(contactId, contactClass: contactClass, handler: { (result) in
      controller?.hideProgress()
      
      if result.isFailure {
        controller?.showMessage(.ProfileError(reason: result.error!))
        handler(nil)
      } else {
        self.session.setContact(result.value!)
        handler(result.value!)
      }
    })
  }
  
  public func updateContact(controller : EditProfileProtocol?, original: BEContact, request : ContactRequest, handler : (Bool) -> Void){
    
    if controller != nil {
      guard controller!.validate(request) else{
        handler(false)
        return
      }
    }
    
    request.set(phone: request.phone?.formatPhoneNumberToNationalSignificant())
    
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
  
  public func getAvailableRewards(controller : CoreProtocol?, handler : (Bool, [BECoupon])->Void){
    self.getAvailableRewards(controller, couponClass: BECoupon.self, handler: handler)
  }
  
  public func getAvailableRewards <CouponClass: BECoupon> (controller : CoreProtocol?, couponClass: CouponClass.Type, handler : (Bool, [BECoupon])->Void){
    let contactId = session.getContactId()!
    
    controller?.showProgress("Retrieving Rewards")
    apiService.getUserOffers(contactId, couponClass: couponClass, handler : { (result) in
      controller?.hideProgress()
      
      if result.isFailure {
        controller?.showMessage(result.error!)
        handler(result.isSuccess, [])
      } else {
        let rewards = result.value!
        handler(result.isSuccess, rewards)
      }
    })
  }
  
  public func getUserProgress(controller : CoreProtocol?, handler : (Bool, Int, String)->Void){
    let contactId = session.getContactId()!
    
    controller?.showProgress("Getting Rewards")
    apiService.getProgress(contactId, handler : { (result) in
      controller?.hideProgress()
      
      let resultStatus = result.isSuccess
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
      
      handler(resultStatus, progressValue, progressText)
    })
  }
  
  public func getGiftCards(controller : CoreProtocol?, handler : (Bool, [BEGiftCard])->Void){
    self.getGiftCards(controller, giftCardClass: BEGiftCard.self, handler: handler)
  }
  
  public func getGiftCards <GiftCardClass: BEGiftCard> (controller : CoreProtocol?, giftCardClass: GiftCardClass.Type, handler : (Bool, [BEGiftCard])->Void){
    let contactId = session.getContactId()!
    let token = session.getAuthToken()!
    
    controller?.showProgress("Retrieving Cards")
    apiService.getGiftCards(contactId, token: token, giftCardClass: giftCardClass, handler: { (result) in
      controller?.hideProgress()
      
      if result.isFailure {
        controller?.showMessage(.GiftCardsError(reason: result.error!))
        handler(result.isSuccess, [])
      } else {
        let cards = result.value!
        
        handler(result.isSuccess, cards)
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
  public func getStoresAtLocation(controller : CoreProtocol?, coordinate: CLLocationCoordinate2D?, handler : ((success: Bool, stores : [BEStore]?) -> Void)) {
    self.getStoresAtLocation(controller, coordinate: coordinate, storeClass: BEStore.self, handler: handler)
  }
  
  public func getStoresAtLocation <StoreClass: BEStore> (controller : CoreProtocol?, coordinate: CLLocationCoordinate2D?, storeClass: StoreClass.Type, handler : ((success: Bool, stores : [BEStore]?) -> Void)) {
    let longitude: String? = (coordinate != nil) ? "\(coordinate!.longitude)" : nil
    let latitude: String? = (coordinate != nil) ? "\(coordinate!.latitude)" : nil
    let token = session.getAuthToken()
    
    controller?.showProgress("Retrieving Stores")
    apiService.getStoresAtLocation (longitude, latitude: latitude, token: token, storeClass: storeClass, handler: { (result) in
      controller?.hideProgress()
      
      if result.isFailure {
        controller?.showMessage(.FindStoresError(reason: result.error!))
        handler(success: false, stores: [])
      } else {
        handler(success: true, stores: result.value!)
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
  func validate(request : ContactRequest) -> Bool{
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
    guard !(request.birthday?.isEmpty)! else{
      self.showMessage("Registration Error", message: "Enter Birthdate")
      return false
    }
    guard (request.zipCode?.isValidZipCode())! else{
      self.showMessage("Registration Error", message: "Enter 5 Digit Zipcode")
      return false
    }
    if !request.isNovadine(){
      guard (request.email?.isValidEmail())! else{
        self.showMessage("Registration Error", message: "Enter Valid Email")
        return false
      }
      guard !(request.password?.isEmpty)! else{
        self.showMessage("Registration Error", message: "Enter Password")
        return false
      }
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
