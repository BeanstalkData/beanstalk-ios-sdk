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

public class CoreService{
  let apiService: ApiCommunication
  public required init(apiKey: String) {
    self.apiService = ApiCommunication(apiKey: apiKey)
  }
  
  public func getContactId() -> String? {
    let prefs = NSUserDefaults.standardUserDefaults()
    return prefs.valueForKey(DataKeys.CONTACT_KEY) as? String
  }
  
  private func setContactId(contactId: String?) {
    let prefs = NSUserDefaults.standardUserDefaults()
    prefs.setValue(contactId, forKey: DataKeys.CONTACT_KEY)
  }
  
  public func getAuthToken() -> String? {
    let prefs = NSUserDefaults.standardUserDefaults()
    return prefs.valueForKey(DataKeys.TOKEN_KEY) as? String
  }
  
  private func setAuthToke(token: String?) {
    let prefs = NSUserDefaults.standardUserDefaults()
    prefs.setValue(token, forKey: DataKeys.TOKEN_KEY)
  }
  
  public func getDefaultCard() -> GiftCard? {
    let prefs = NSUserDefaults.standardUserDefaults()
    var giftCard = GiftCard(storage: prefs)
    
    if giftCard?.id == nil {
      giftCard = nil
    }
    
    return giftCard
  }
  
  public func saveDefaultCard(card : GiftCard){
    let prefs = NSUserDefaults.standardUserDefaults()
    card.save(prefs)
  }
  
  public func registerLoyaltyAccount(controller: RegistrationProtocol, request: CreateContactRequest, handler: (Bool) -> Void){
    guard controller.validate(request) else{
      return
    }
    
    request.phone = request.phone?.formatPhoneNumberToNationalSignificant()
    
    controller.showProgress("Registering User")
    if request.novadine {
      apiService.createLoyaltyAccount(request, handler: {
        _,error in
        controller.hideProgress()
        guard error == nil else {
          
          switch error! {
          case .NetworkConnection:
            controller.showMessage("Network Error", message: "Connection unavailable.")
          default :
            controller.showMessage("Registration Error", message: "Unable to sign up user, please try again later.")
          }
          handler(false)
          return
        }
        self.auth(controller, email : request.email!, password: request.password!, handler: handler)
        
      })
    }else {
      apiService.checkContactsByEmailExisted(request.email!, handler: {
        error in
        
        var updateExisted = false
        if let e = error {
          
          var title : String? = nil
          var message : String? = nil;
          var notifyError = true
          switch e {
          case .NetworkConnection:
            title = "Network Error"
            message = "Connection unavailable."
          case .ContactExisted(true):
            notifyError = false
            updateExisted = true
          default :
            title = "Registration Error"
            message = "This email is already registered in our database. Please sign-in into your account. Use the \"forgot password\" button in case you need to reset it."
          }
          if notifyError {
            controller.hideProgress()
            controller.showMessage(title!, message: message!)
            handler(false)
            return
          }
        }
        self.apiService.checkContactsByPhoneExisted(request.phone!, handler: {
          error in
          if let e = error {
            
            var title : String? = nil
            var message : String? = nil;
            var notifyError = true
            switch e {
            case .NetworkConnection:
              title = "Network Error"
              message = "Connection unavailable."
            case .ContactExisted(true):
              notifyError = false
              updateExisted = true
            default :
              title = "Registration Error"
              message = "This phone is already registered in our database. Please sign-in into your account. Use the \"forgot password\" button in case you need to reset it."
            }
            if notifyError {
              controller.hideProgress()
              controller.showMessage(title!, message: message!)
              handler(false)
              return
            }
          }
          self.apiService.createLoyaltyAccount(request, handler: {
            contactId, error in
            guard contactId != nil && error == nil else {
              controller.hideProgress()
              switch error! {
              case .NetworkConnection:
                controller.showMessage("Network Error", message: "Connection unavailable.")
              default :
                controller.showMessage("Registration Error", message: "Unable to sign up user, please try again later.")
              }
              handler(false)
              return
            }
            
            self.auth(controller, email: request.email!, password: request.password!, handler: handler)
            
          })
        })
      })
    }
  }
  
  public func register(controller : RegistrationProtocol, request : CreateContactRequest, handler : (Bool) -> Void){
    guard controller.validate(request) else{
      return
    }
    
    request.phone = request.phone?.formatPhoneNumberToNationalSignificant()
    
    controller.showProgress("Registering User")
    if request.novadine {
      apiService.createContact(request, handler: {
        _,error in
        controller.hideProgress()
        guard error == nil else {
          
          switch error! {
          case .NetworkConnection:
            controller.showMessage("Network Error", message: "Connection unavailable.")
          default :
            controller.showMessage("Registration Error", message: "Unable to sign up user, please try again later.")
          }
          handler(false)
          return
        }
        self.auth(controller, email : request.email!, password: request.password!, handler: handler)
        
      })
    }else {
      apiService.checkContactsByEmailExisted(request.email!, handler: {
        error in
        
        var updateExisted = false
        if let e = error {
          
          var title : String? = nil
          var message : String? = nil;
          var notifyError = true
          switch e {
          case .NetworkConnection:
            title = "Network Error"
            message = "Connection unavailable."
          case .ContactExisted(true):
            notifyError = false
            updateExisted = true
          default :
            title = "Registration Error"
            message = "This email is already registered in our database. Please sign-in into your account. Use the \"forgot password\" button in case you need to reset it."
          }
          if notifyError {
            controller.hideProgress()
            controller.showMessage(title!, message: message!)
            handler(false)
            return
          }
        }
        self.apiService.checkContactsByPhoneExisted(request.phone!, handler: {
          error in
          if let e = error {
            
            var title : String? = nil
            var message : String? = nil;
            var notifyError = true
            switch e {
            case .NetworkConnection:
              title = "Network Error"
              message = "Connection unavailable."
            case .ContactExisted(true):
              notifyError = false
              updateExisted = true
            default :
              title = "Registration Error"
              message = "This phone is already registered in our database. Please sign-in into your account. Use the \"forgot password\" button in case you need to reset it."
            }
            if notifyError {
              controller.hideProgress()
              controller.showMessage(title!, message: message!)
              handler(false)
              return
            }
          }
          self.apiService.createContact(request, handler: {
            contactId, error in
            guard contactId != nil && error == nil else {
              controller.hideProgress()
              switch error! {
              case .NetworkConnection:
                controller.showMessage("Network Error", message: "Connection unavailable.")
              default :
                controller.showMessage("Registration Error", message: "Unable to sign up user, please try again later.")
              }
              handler(false)
              return
            }
            if !updateExisted {
              self.apiService.createUser(request.email!, password: request.password!, contactId: contactId!, handler: {
                error in
                controller.hideProgress()
                guard error == nil else {
                  switch error! {
                  case .NetworkConnection:
                    controller.showMessage("Network Error", message: "Connection unavailable.")
                  default :
                    controller.showMessage("Registration Error", message: "Unable to sign up user, please try again later.")
                  }
                  handler(false)
                  return
                }
                self.auth(controller, email: request.email!, password: request.password!, handler: handler)
              })
            } else {
              self.auth(controller, email: request.email!, password: request.password!, handler: handler)
            }
            
          })
        })
      })
    }
  }
  
  public func authenticate(controller: AuthenticationProtocol?, email: String?, password: String?, handler : ((success: Bool, additionalInfo : Bool) -> Void)) {
    if controller != nil {
      guard controller!.validate(email, password: password) else{
        return
      }
    }
    
    controller?.showProgress("Attempting to Login")
    apiService.checkContactIsNovadine(email!, handler: {
      isNovadineContact, _ in
      self.apiService.authenticateUser(email!, password: password!, handler: {
        contactId, token, error in
        controller?.hideProgress()
        guard error == nil else {
          switch error! {
          case .NetworkConnection:
            controller?.showMessage("Network Error", message: "Connection unavailable.")
          default :
            controller?.showMessage("Login Error", message: "Unable to Login!")
          }
          handler(success: false, additionalInfo: isNovadineContact)
          return
        }
        let prefs = NSUserDefaults.standardUserDefaults()
        self.setContactId(contactId)
        self.setAuthToke(token)
        
        prefs.synchronize()
        handler(success: true, additionalInfo: isNovadineContact)
        
      })
    })
  }
  
  public func resetPassword(controller: AuthenticationProtocol?, email : String?, handler : () -> Void) {
    if controller != nil {
      guard controller!.validate(email, password: "123456") else{
        return
      }
    }
    controller?.showProgress("Reseting Password")
    apiService.resetPassword(email!, handler: {
      message, error in
      controller?.hideProgress()
      if error == nil {
        controller?.showMessage("Password reset", message: message!)
      }else{
        switch error! {
        case .NetworkConnection:
          controller?.showMessage("Network Error", message: "Connection unavailable.")
        default :
          controller?.showMessage("Password reset", message: "Unable to reset password")
        }
      }
      handler()
    })
  }
  
  public func logout(controller : CoreProtocol, handler : () -> Void){
    let prefs = NSUserDefaults.standardUserDefaults()
    
    let contactId = getContactId()!
    let token = getAuthToken()!
    controller.showProgress("Logout...")
    apiService.logoutUser(contactId, token : token, handler: {
      error in
      controller.hideProgress()
      handler()
    })
    
    setContactId(nil)
    setAuthToke(nil)
    
    prefs.synchronize()
  }
  
  public func validateZIP(controller: CoreProtocol, ZIP: String, handler: ((success: Bool) -> Void)) {
    controller.showProgress("Checking...")
    apiService.checkZIPForAvailable(ZIP) { (available, error) in
      controller.hideProgress()
      
      if error != nil {
        handler(success: false)
      }
      else {
        handler(success: available)
      }
    }
  }
  
  public func getContact(controller : CoreProtocol, handler : (Contact?) -> Void){
    let prefs = NSUserDefaults.standardUserDefaults()
    let contactId = getContactId()!
    controller.showProgress("Retrieving Profile")
    apiService.getContact(contactId, handler: {
      contact, error in
      controller.hideProgress()
      if error != nil {
        switch error! {
        case .NetworkConnection:
          controller.showMessage("Network Error", message: "Connection unavailable.")
        default :
          controller.showMessage("Profile Error", message: "Unable to retrieve profile")
        }
      }
      handler(contact)
    })
  }
  
  public func updateContact(controller : EditProfileProtocol, original: Contact, request : UpdateContactRequest, handler : (Bool) -> Void){
    guard controller.validate(request) else{
      handler(false)
      return
    }
    
    request.phone = request.phone?.formatPhoneNumberToNationalSignificant()
    
    controller.showProgress("Updating Profile")
    apiService.updateContact(original, request: request, handler: {
      error in
      controller.hideProgress()
      if error != nil {
        switch error! {
        case .NetworkConnection:
          controller.showMessage("Network Error", message: "Connection unavailable.")
        default :
          controller.showMessage("Update Error", message: "Update Failed!")
        }
      }
      handler(error == nil)
    })
    
  }
  
  public func updatePassword(controller : UpdatePasswordProtocol, password: String?, confirmPassword: String?, handler : (Bool) -> Void){
    guard controller.validate(password, confirmPassword: confirmPassword) else{
      handler(false)
      return
    }
    let prefs = NSUserDefaults.standardUserDefaults()
    let contactId = getContactId()!
    let token = getAuthToken()!
    controller.showProgress("Updating Password")
    apiService.updatePassword(password!, contactId: contactId, token: token, handler: {
      error in
      controller.hideProgress()
      if error != nil {
        switch error! {
        case .NetworkConnection:
          controller.showMessage("Network Error", message: "Connection unavailable.")
        default :
          controller.showMessage("Password Update", message: "Unable to update password")
        }
      }
      handler(error == nil)
    })
  }
  
  public func getAvailableRewards(controller : CoreProtocol, handler : ([Coupon])->Void){
    let prefs = NSUserDefaults.standardUserDefaults()
    let contactId = getContactId()!
    controller.showProgress("Loading...")
    apiService.getUserOffers(contactId, handler : {
      data, error in
      controller.hideProgress()
      var rewards = [Coupon]()
      if error == nil {
        if data?.coupons != nil {
          rewards = data!.coupons!
        }
      }else {
        switch error! {
        case .NetworkConnection:
          controller.showMessage("Network Error", message: "Connection unavailable.")
        default:
          print("skip error")
        }
      }
      handler(rewards)
    })
  }
  
  public func getUserProgress(controller : CoreProtocol, handler : (Int, String)->Void){
    let prefs = NSUserDefaults.standardUserDefaults()
    let contactId = getContactId()!
    controller.showProgress("Getting Rewards")
    apiService.getProgress(contactId, handler : {
      data, error in
      controller.hideProgress()
      let required = 8
      var progressValue = 0;
      var progressText = "Only \(required) more purchases until your next TC reward!"
      if error == nil {
        let rewardValue = data == nil ? 0 : Int(data!.getCount())
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
  
  
  public func getAvailableFoRedeemRewards(controller : CoreProtocol, handler : ([Coupon], ApiError?)->Void){
    let prefs = NSUserDefaults.standardUserDefaults()
    let contactId = getContactId()!
    apiService.getUserOffers(contactId, handler : {
      data, error in
      
      if error != nil {
        switch error! {
        case .NetworkConnection:
          controller.showMessage("Network Error", message: "Connection unavailable.")
        default :
          controller.showMessage("Coupons Error", message: "Failed to get coupons try again later")
        }
        
        handler([], error)
        return
      }
      if data == nil || data!.coupons == nil || data!.coupons!.count == 0 {
        controller.showMessage("Coupons", message: "You have no available coupons")
        
        handler([], nil)
        return
      }
      
      handler(data!.coupons!, nil)
    })
  }
  
  public func getGiftCards(controller : CoreProtocol, handler : ([GiftCard])->Void){
    let prefs = NSUserDefaults.standardUserDefaults()
    let contactId = getContactId()!
    let token = getAuthToken()!
    controller.showProgress("Retrieving Cards")
    apiService.getGiftCards(contactId, token: token, handler: {
      data, error in
      controller.hideProgress()
      if error != nil {
        controller.hideProgress()
        switch error! {
        case .NetworkConnection:
          controller.showMessage("Network Error", message: "Connection unavailable.")
        default :
          controller.showMessage("Cards Error", message: "Error Retrieving Cards Information")
        }
        handler([])
        return
      }
      if data != nil && data!.failed() {
        controller.hideProgress()
        controller.showMessage("Cards Error", message: "Error Retrieving Cards Information")
        handler([])
        return
      }
      if data == nil || data!.getCards() == nil || data!.getCards()!.count == 0 {
        controller.hideProgress()
        controller.showMessage("Cards", message: "You have no cards registered")
        handler([])
        return
      }
      let cards = data!.getCards()!
      
      handler(cards)
    })
  }
  
  public func startPayment(controller : CoreProtocol, cardId : String?, coupons: [Coupon], handler : (String, String)->Void){
    controller.showProgress("Generating Barcode")
    if cardId == nil && coupons.count == 0 {
      controller.hideProgress()
      let data = getBarCodeInfo(nil, cardId: cardId, coupons: coupons)
      handler(data.0, data.1)
      return
    }
    let prefs = NSUserDefaults.standardUserDefaults()
    let contactId = getContactId()!
    let token = getAuthToken()!
    let couponsString : String = coupons.reduce("", combine: { $0 == "" ? $1.number! : $0 + "," + $1.number! })
    apiService.startPayment(contactId, token: token, paymentId: cardId, coupons: couponsString, handler : {
      data, error in
      controller.hideProgress()
      if error != nil {
        switch error! {
        case .NetworkConnection:
          controller.showMessage("Network Error", message: "Connection unavailable.")
        default :
          controller.showMessage("Payment Error", message: "Error generating barcode. Please try again later.")
        }
        
        let data = self.getBarCodeInfo(nil, cardId: cardId, coupons: coupons)
        handler(data.0, data.1)
        return
      }
      let data = self.getBarCodeInfo(data?.token, cardId: cardId, coupons: coupons)
      handler(data.0, data.1)
    })
  }
  
  public func isAuthenticated() ->Bool{
    let prefs = NSUserDefaults.standardUserDefaults()
    let contactId = getContactId()
    let token = getAuthToken()
    return contactId != nil && token != nil
  }
  
  
  //MARK: - Push Notifications
  
  public func pushNotificationEnroll(deviceToken: String, handler: (success: Bool, error: ApiError?) -> Void) {
    if let contactId = self.getContactId() {
      apiService.pushNotificationEnroll(contactId, deviceToken: deviceToken, handler: { (response, error) in
        if error != nil {
          handler(success: false, error: error)
        }
        else if response != nil {
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
    if let contactId = self.getContactId() {
      apiService.pushNotificationDelete(contactId, handler: { (response, error) in
        if error != nil {
          handler(success: false, error: error)
        }
        else if response != nil {
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
  
  
  //MARK: - Locations
  
  public func getStoresAtLocation(controller : CoreProtocol, coordinate: CLLocationCoordinate2D, handler : ((success: Bool, stores : [Store]?) -> Void)) {
    let prefs = NSUserDefaults.standardUserDefaults()
    let longitude = "\(coordinate.longitude)"
    let latitude = "\(coordinate.latitude)"
    let token = getAuthToken()
    controller.showProgress("Retrieving Stores")
    
    apiService.getStoresAtLocation (longitude, latitude: latitude, token: token, handler: {
      data, error in
      controller.hideProgress()
      
      if error != nil {
        switch error! {
        case .NetworkConnection:
          controller.showMessage("Network Error", message: "Connection unavailable.")
        default :
          controller.showMessage("Find Stores Error", message: "Error Retrieving Stores Information")
        }
        return
      }
      
      if data != nil && data!.failed() {
        controller.showMessage("Find Stores Error", message: "Error Retrieving Stores Information")
        return
      }
      
      handler(success: true, stores: data?.getStores())
    })
  }
  
  
  //No needs to check isNoadine user
  private func auth(controller : RegistrationProtocol, email: String, password: String, handler : (Bool) -> Void) {
    controller.showProgress("Attempting to Login")
    apiService.authenticateUser(email, password: password, handler: {
      contactId, token, error in
      controller.hideProgress()
      guard error == nil else {
        switch error! {
        case .NetworkConnection:
          controller.showMessage("Network Error", message: "Connection unavailable.")
        default :
          controller.showMessage("Login Error", message: "Unable to Login!")
        }
        handler(false)
        return
      }
      let prefs = NSUserDefaults.standardUserDefaults()
      self.setContactId(contactId)
      self.setAuthToke(token)
      
      prefs.synchronize()
      handler(true)
      
    })
  }
  
  private func getBalanceForCard(controller : CoreProtocol , contactId: String, token: String, index: Int, cards : [GiftCard], handler :([GiftCard])->Void){
    if index == 0 {
      dispatch_async(dispatch_get_main_queue(),{
        // controller.showProgress("Retrieving Cards Balances")
      })
    }
    apiService.getGiftCardBalance(contactId, token: token, number: cards[index].number!, handler: {
      data, error in
      debugPrint("index \(index)")
      if index == cards.count-1 {
        controller.hideProgress()
      }
      if error == nil {
        cards[index].balance = data?.getCardBalance()
      }
      if index == cards.count-1 {
        handler(cards)
      }else {
        self.getBalanceForCard(controller, contactId: contactId, token: token, index: index + 1, cards: cards, handler: handler)
      }
    })
  }
  
  private func getBarCodeInfo(data: String?, cardId : String?, coupons : [Coupon]) -> (String, String){
    var content = ""
    var display = ""
    if data == nil || data!.characters.count == 0{
      let prefs = NSUserDefaults.standardUserDefaults()
      let contactId = getContactId()!
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
private struct DataKeys{
  static let TOKEN_KEY = "_token"
  static let CONTACT_KEY = "_contact_id"
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
