//
//  CoreService.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import PKHUD

import Alamofire
import BeanstalkEngageiOSSDK

public typealias CoreService = CoreServiceT<HTTPAlamofireManager>

open class CoreServiceT <SessionManager: HTTPAlamofireManager>: BEAbstractRespondersHolder {
  public let apiService: ApiCommunication<SessionManager>
  let session: BESessionProtocol
  
  fileprivate var p_isAuthenticateInProgress = false
  open var isAuthenticateInProgress: Bool {
    get {
      return self.p_isAuthenticateInProgress
    }
  }
  
  public required init(apiKey: String, session: BESessionProtocol) {
    self.apiService = ApiCommunication(apiKey: apiKey)
    self.session = session
  }
  
  open func getSession() -> BESessionProtocol? {
    return session
  }
  
  open func clearSession() {
    self.session.clearSession()
  }
  
  open func isAuthenticated() -> Bool{
    let contactId = session.getContactId()
    let token = session.getAuthToken()
    return contactId != nil && token != nil
  }
  
  open func isOnline() -> Bool {
    return self.apiService.isOnline()
  }
  
  open func addResponder(_ responder: BEApiResponder) {
    self.apiService.addResponder(responder)
  }
  
  open func removeResponder(_ responder: BEApiResponder) {
    self.apiService.addResponder(responder)
  }
  
  open func registerLoyaltyAccount <ContactClass: BEContact> (_ controller: RegistrationProtocol?, request: ContactRequest, contactClass: ContactClass.Type, handler: @escaping (Bool) -> Void){
    if (controller != nil) {
      guard controller!.validate(request) else {
        handler(false)
        return
      }
    }
    
    request.normalize()
    
    weak var weakSelf = self
    controller?.showProgress("Registering User")
    apiService.createLoyaltyAccount(request, handler: { (result) in
      controller?.hideProgress()
      
      if result.isFailure {
        controller?.showMessage(result.error! as! BEErrorType)
        handler(false)
      } else {
        weakSelf?.auth(controller, email : request.getEmail()!, password: request.getPassword()!, contactClass: contactClass, handler: handler)
      }
    })
  }
  
  open func register <ContactClass: BEContact> (_ controller : RegistrationProtocol?, request : ContactRequest, contactClass: ContactClass.Type, handler : @escaping (Bool) -> Void) {
    if (controller != nil) {
      guard controller!.validate(request) else {
        handler(false)
        return
      }
    }
    
    request.normalize()
    
    controller?.showProgress("Registering User")
    
    weak var weakSelf = self
    apiService.checkContactsByEmailExisted(request.getEmail()!, prospectTypes: [.eClub, .Loyalty], handler: { (result) in
      
      if result.isFailure {
        controller?.hideProgress()
        controller?.showMessage(ApiError.userEmailExists(reason: result.error! as! BEErrorType))
        handler(false)
      } else {
        var updateExisted = result.value!
        
        weakSelf?.apiService.checkContactsByPhoneExisted(request.getPhone()!, prospectTypes: [], handler: { (result) in
          
          if result.isFailure {
            controller?.hideProgress()
            controller?.showMessage(ApiError.userPhoneExists(reason: result.error! as! BEErrorType))
            handler(false)
          } else {
            updateExisted = updateExisted || result.value!
            
            weakSelf?.apiService.createContact(request, contactClass: contactClass, handler: { (result) in
              
              if result.isFailure {
                controller?.hideProgress()
                controller?.showMessage(result.error! as! BEErrorType)
                handler(false)
              } else {
                if !updateExisted {
                  let contactId = result.value!.contactId
                  weakSelf?.apiService.createUser(request.getEmail()!, password: request.getPassword()!, contactId: contactId, handler: { (result) in
                    
                    if result.isFailure {
                      controller?.hideProgress()
                      controller?.showMessage(result.error! as! BEErrorType)
                      handler(false)
                    } else {
                      weakSelf?.auth(controller, email: request.getEmail()!, password: request.getPassword()!, contactClass: contactClass, handler: handler)
                    }
                  })
                } else {
                  weakSelf?.auth(controller, email: request.getEmail()!, password: request.getPassword()!, contactClass: contactClass, handler: handler)
                }
              }
            })
          }
        })
      }
    })
  }
  
  open func autoSignIn <ContactClass: BEContact> (_ controller: AuthenticationProtocol?, contactClass: ContactClass.Type, handler : @escaping ((_ success: Bool) -> Void)) {
    
    let contactId = session.getContactId()
    let token = session.getAuthToken()
    
    guard (contactId != nil && token != nil) else {
      handler(false)
      return
    }
    
    self.p_isAuthenticateInProgress = true
    controller?.showProgress("Attempting to Login")
    
    weak var weakSelf = self
    self.apiService.checkUserSession(contactId!, token: token!) { result in
      controller?.hideProgress()
      
      if result.isFailure {
        weakSelf?.p_isAuthenticateInProgress = false
        controller?.showMessage(result.error! as! BEErrorType)
        handler(false)
      } else {
        weakSelf?.handleLoginComplete(contactId, token: token, contactClass: contactClass, handler: { result in
          weakSelf?.p_isAuthenticateInProgress = false
          handler(result)
        })
      }
    }
  }
  
  open func authenticate <ContactClass: BEContact> (_ controller: AuthenticationProtocol?, email: String?, password: String?, contactClass: ContactClass.Type, handler : @escaping ((_ success: Bool) -> Void)) {
    if controller != nil {
      guard controller!.validate(email, password: password) else {
        handler(false)
        return
      }
    }
    
    self.p_isAuthenticateInProgress = true
    controller?.showProgress("Attempting to Login")
    
    weak var weakSelf = self
    self.apiService.authenticateUser(email!, password: password!, handler: { (result) in
      controller?.hideProgress()
      
      if result.isFailure {
        weakSelf?.p_isAuthenticateInProgress = false
        controller?.showMessage(result.error! as! BEErrorType)
        handler(false)
      } else {
        let contactId = result.value!.contactId
        let token = result.value!.token
        weakSelf?.handleLoginComplete(contactId, token: token, contactClass: contactClass, handler: { result in
          weakSelf?.p_isAuthenticateInProgress = false
          handler(result)
        })
      }
    })
  }
  
  //No needs to check isNoadine user
  fileprivate func auth <ContactClass: BEContact> (_ controller : RegistrationProtocol?, email: String, password: String, contactClass: ContactClass.Type, handler : @escaping (Bool) -> Void) {
    
    self.p_isAuthenticateInProgress = true
    controller?.showProgress("Attempting to Login")
    
    weak var weakSelf = self
    apiService.authenticateUser(email, password: password, handler: { (result) in
      controller?.hideProgress()
      
      if result.isFailure {
        weakSelf?.p_isAuthenticateInProgress = false
        controller?.showMessage(result.error! as! BEErrorType)
        handler(false)
      } else {
        let contactId = result.value!.contactId
        let token = result.value!.token
        weakSelf?.handleLoginComplete(contactId, token: token, contactClass: contactClass, handler: { result in
          weakSelf?.p_isAuthenticateInProgress = false
          handler(result)
        })
      }
    })
  }
  
  fileprivate func handleLoginComplete <ContactClass: BEContact> (_ contactId : String?, token : String?, contactClass: ContactClass.Type, handler : @escaping (Bool) -> Void) {
    
    guard (contactId != nil && token != nil) else {
      self.clearSession()
      handler(false)
      return
    }
    
    weak var weakSelf = self
    apiService.getContact(contactId!, contactClass: contactClass, handler: { (result) in
      if result.isSuccess {
        weakSelf?.session.setContact(result.value!)
      } else {
        weakSelf?.session.setContact(nil)
      }
      weakSelf?.session.setAuthToke(token)
      handler(result.isSuccess)
    })
  }
  
  open func resetPassword(_ controller: AuthenticationProtocol?, email : String?, handler : @escaping (_ success: Bool) -> Void) {
    if controller != nil {
      guard controller!.validate(email, password: "123456") else {
        handler(false)
        return
      }
    }
    controller?.showProgress("Reseting Password")
    apiService.resetPassword(email!, handler: { (result) in
      controller?.hideProgress()
      
      if result.isFailure {
        controller?.showMessage(ApiError.resetPasswordError(reason: result.error! as! BEErrorType))
      } else {
        controller?.showMessage("Password reset", message: result.value!)
      }
      
      handler(!result.isFailure)
    })
  }
  
  open func logout(_ controller : CoreProtocol?, handler : @escaping (_ success: Bool) -> Void){
    let contactId = session.getContactId()!
    let token = session.getAuthToken()!
    let registeredDeviceToken = session.getRegisteredAPNSToken()
    
    controller?.showProgress("Logout...")
    
    weak var weakSelf = self
    apiService.logoutUser(contactId, token : token, handler: { (result) in
      controller?.hideProgress()
      
      if registeredDeviceToken != nil {
        weakSelf?.pushNotificationDelete({ (success, error) in
          handler(success)
        })
        
        weakSelf?.clearSession()
      } else {
        weakSelf?.clearSession()
        
        handler(result.isSuccess)
      }
    })
  }
  
  open func checkContactsByEmailExisted(
    _ controller: CoreProtocol?,
    email: String,
    prospectTypes: [ProspectType],
    handler : @escaping (Bool?) -> Void
    ) {
    controller?.showProgress("Checking email")
    apiService.checkContactsByEmailExisted(email, prospectTypes: prospectTypes) { (result) in
      controller?.hideProgress()
      
      if result.isFailure {
        controller?.showMessage(ApiError.userEmailExists(reason: result.error! as! BEErrorType))
        handler(nil)
      } else {
        handler(result.value!)
      }
    }
  }
  
  open func getContact <ContactClass: BEContact> (_ controller : CoreProtocol?, contactClass: ContactClass.Type, handler : @escaping (Bool, ContactClass?) -> Void) {
    let contactId = session.getContactId()!
    
    controller?.showProgress("Retrieving Profile")
    
    weak var weakSelf = self
    apiService.getContact(contactId, contactClass: contactClass, handler: { (result) in
      controller?.hideProgress()
      
      if result.isFailure {
        controller?.showMessage(ApiError.profileError(reason: result.error! as! BEErrorType))
        handler(result.isSuccess, nil)
      } else {
        weakSelf?.session.setContact(result.value!)
        handler(result.isSuccess, result.value!)
      }
    })
  }
  
  /**
   Creates contact of provided class and persists it in session.
   
   - Note: Current server API returns only *contactId* on create request. So in order to return contact model (if requested) - *getContact()* request is performed. There might be situations (bad network conditions, etc.) when contact is created but *getContact()* request failed, so only *contactId* will be available.
   
   - parameters:
      - request: Contact request.
      - contactClass: Contact class.
      - fetchContact: Contact model will be fetched by *getContact()*. Default is *false*.
   */
  open func createContact <ContactClass: BEContact> (
    _ request : ContactRequest,
    contactClass: ContactClass.Type,
    fetchContact: Bool = false,
    handler : @escaping (_ contactId: String?, _ contact: ContactClass?, _ error: ApiError?) -> Void) {
    
    request.normalize()
    
    weak var weakSelf = self
    apiService.createContact(request, contactClass: contactClass, fetchContact: fetchContact) { (result) in
      if result.isFailure {
        handler(nil, nil, result.error as? ApiError)
      } else {
        let contactId = result.value?.contactId
        let contact = result.value?.contact
        
        if fetchContact {
          weakSelf?.session.setContact(contact)
        }
        
        handler(contactId, contact, nil)
      }
    }
  }
  
  /**
   Update contact and persist it in session.
   
   - Note: Current server API returns only *success* on update request. So in order to return contact model (if requested) - *getContact()* request is performed. There might be situations (bad network conditions, etc.) when contact is updated but *getContact()* request failed, so only *success* will be available.
   
   - parameters:
      - request: Contact request.
      - fetchContact: Contact model will be fetched by *getContact()*. Default is *false*.
   */
  open func updateContact <ContactClass: BEContact> (
    request : ContactRequest,
    contactClass : ContactClass.Type,
    fetchContact : Bool = false,
    handler : @escaping (_ success : Bool, _ contact : ContactClass?, _ error : BEErrorType?) -> Void) {
    
    request.normalize()
    
    weak var weakSelf = self
    apiService.updateContact(request: request, contactClass: contactClass, fetchContact: fetchContact) { (result) in
      if result.isFailure {
        handler(false, nil, result.error as? BEErrorType)
      } else {
        let contactId = request.getContactId()
        var contact: ContactClass?
        
        if let fetchedContact = result.value?.contact {
          contact = fetchedContact
          weakSelf?.session.setContact(fetchedContact)
        }
        
        handler(true, contact, nil)
      }
    }
  }
  
  /**
   Deletes contact from server and clears from session.
   
   - parameters:
      - contactId: Contact ID.
   */
  open func deleteContact(
    contactId: String,
    handler : @escaping (_ success: Bool, _ error: BEErrorType?) -> Void) {
    
    weak var weakSelf = self
    apiService.deleteContact(contactId: contactId) { (result) in
      if result.isFailure {
        handler(false, result.error as? BEErrorType)
      }
      else {
        weakSelf?.clearSession()
        
        handler(true, nil)
      }
    }
  }
  
  open func updatePassword(_ controller : UpdatePasswordProtocol?, password: String?, confirmPassword: String?, handler : @escaping (Bool) -> Void){
    
    if controller != nil {
      guard controller!.validate(password, confirmPassword: confirmPassword) else {
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
        controller?.showMessage(ApiError.updatePasswordError(reason: result.error! as! BEErrorType))
        handler(false)
      } else {
        handler(true)
      }
    })
  }
  
  open func getAvailableRewards(_ controller : CoreProtocol?, handler : @escaping (Bool, [BECoupon])->Void){
    self.getAvailableRewardsForCouponClass(controller, couponClass: BECoupon.self, handler: handler)
  }
  
  open func getAvailableRewardsForCouponClass <CouponClass: BECoupon> (_ controller : CoreProtocol?, couponClass: CouponClass.Type, handler : @escaping (Bool, [BECoupon])->Void){
    let contactId = session.getContactId()!
    
    controller?.showProgress("Retrieving Rewards")
    
    weak var weakSelf = self
    apiService.getUserOffers(contactId, couponClass: couponClass, handler : { (result) in
      controller?.hideProgress()
      
      if result.isFailure {
        controller?.showMessage(result.error! as! BEErrorType)
        handler(result.isSuccess, [])
      } else {
        let rewards = result.value!
        weakSelf?.session.saveRewards(rewards)
        handler(result.isSuccess, rewards)
      }
    })
  }
  
  open func getUserProgress(_ controller : CoreProtocol?, handler : @escaping (Double?, ApiError?)->Void){
    let contactId = session.getContactId()!
    
    controller?.showProgress("Getting Rewards")
    apiService.getProgress(contactId, handler : { (result) in
      controller?.hideProgress()
      
      var progressValue: Double?
      var error: ApiError?
      
      if result.isFailure {
        error = result.error as? ApiError
      }
      else {
        progressValue = result.value
      }
      
      handler(progressValue, error)
    })
  }
  
  open func getGiftCards(_ controller : CoreProtocol?, handler : @escaping (Bool, [BEGiftCard])->Void){
    self.getGiftCardsForGiftCardClass(controller, giftCardClass: BEGiftCard.self, handler: handler)
  }
  
  open func getGiftCardsForGiftCardClass <GiftCardClass: BEGiftCard> (_ controller : CoreProtocol?, giftCardClass: GiftCardClass.Type, handler : @escaping (Bool, [BEGiftCard])->Void){
    let contactId = session.getContactId()!
    let token = session.getAuthToken()!
    
    controller?.showProgress("Retrieving Cards")
    apiService.getGiftCards(contactId, token: token, giftCardClass: giftCardClass, handler: { (result) in
      controller?.hideProgress()
      
      if result.isFailure {
        controller?.showMessage(ApiError.giftCardsError(reason: result.error! as! BEErrorType))
        handler(result.isSuccess, [])
      } else {
        let cards = result.value!
        
        handler(result.isSuccess, cards)
      }
    })
  }
  
  open func startPayment(_ controller : CoreProtocol?, cardId : String?, coupons: [BECoupon], handler : @escaping (BarCodeInfo)->Void){
    
    if cardId == nil && coupons.count == 0 {
      let data = getBarCodeInfo(nil, cardId: cardId, coupons: coupons)
      handler(data)
      return
    }
    
    let contactId = session.getContactId()!
    let token = session.getAuthToken()!
    let couponsString : String = coupons.reduce("", { $0 == "" ? $1.number! : $0 + "," + $1.number! })
    
    controller?.showProgress("Generating Barcode")
    
    weak var weakSelf = self
    apiService.startPayment(contactId, token: token, paymentId: cardId, coupons: couponsString, handler : { (result) in
      controller?.hideProgress()
      
      if result.isFailure {
        controller?.showMessage(ApiError.paymentError(reason: result.error! as! BEErrorType))
        var data = weakSelf?.getBarCodeInfo(nil, cardId: cardId, coupons: coupons)
        if data == nil {
          data = BarCodeInfo(data: "", type: .memberId)
        }
        handler(data!)
      } else {
        let cards = result.value!
        
        var data = weakSelf?.getBarCodeInfo(result.value!, cardId: cardId, coupons: coupons)
        if data == nil {
          data = BarCodeInfo(data: "", type: .memberId)
        }
        handler(data!)
      }
    })
  }
  
  //MARK: - Push Notifications
  
  open func pushNotificationEnroll(_ deviceToken: String, handler: @escaping (_ success: Bool, _ error: BEErrorType?) -> Void) {
    
    guard let contactId = self.session.getContactId() else {
      handler(false, ApiError.unknown())
      return
    }
    
    weak var weakSelf = self
    apiService.pushNotificationEnroll(contactId, deviceToken: deviceToken, handler: { (result) in
      
      if result.isSuccess {
        weakSelf?.session.setRegisteredAPNSToken(deviceToken)
        
        handler(true, nil)
      }
      else {
        handler(false, result.error as? BEErrorType)
      }
    })
  }
  
  open func pushNotificationDelete(_ handler: @escaping (_ success: Bool, _ error: BEErrorType?) -> Void) {
    
    guard let contactId = self.session.getContactId() else {
      handler(false, ApiError.unknown())
      return
    }
    
    weak var weakSelf = self
    apiService.pushNotificationDelete(contactId, handler: { (result) in
      
      if result.isSuccess {
        weakSelf?.session.setRegisteredAPNSToken(nil)
        
        handler(true, nil)
      }
      else {
        handler(false, result.error as? BEErrorType)
      }
    })
  }
  
  open func pushNotificationGetMessages(_ contactId: String, maxResults: Int, handler : @escaping (_ messages: [BEPushNotificationMessage]?, _ error: BEErrorType?) -> Void) {
    
    guard let contactId = self.session.getContactId() else {
      handler(nil, ApiError.unknown())
      return
    }
    
    apiService.pushNotificationGetMessages(contactId, maxResults: maxResults, handler: { (result) in
      
      if result.isSuccess {
        handler(result.value, nil)
      }
      else {
        handler(nil, result.error as? BEErrorType)
      }
    })
  }
  
  open func pushNotificationUpdateStatus(_ messageId: String, status: PushNotificationStatus, handler : @escaping (_ success: Bool, _ error: BEErrorType?) -> Void) {
    
    guard let contactId = self.session.getContactId() else {
      handler(false, ApiError.unknown())
      return
    }
    
    apiService.pushNotificationUpdateStatus(messageId, status: status) { (result) in
      
      if result.isSuccess {
        handler(true, nil)
      }
      else {
        handler(false, result.error as? BEErrorType)
      }
    }
  }
  
  open func pushNotificationGetMessageById(_ messageId: String, handler : @escaping (_ message: BEPushNotificationMessage?, _ error: BEErrorType?) -> Void) {
    
    guard let contactId = self.session.getContactId() else {
      handler(nil, ApiError.unknown())
      return
    }
    
    apiService.pushNotificationGetMessageById(messageId) { (result) in
      
      if result.isSuccess {
        handler(result.value, nil)
      }
      else {
        handler(nil, result.error as? BEErrorType)
      }
    }
  }
  
  //MARK: - Locations
  open func getStoresAtLocation(_ controller : CoreProtocol?, coordinate: CLLocationCoordinate2D?, handler : @escaping ((_ success: Bool, _ stores : [BEStore]?) -> Void)) {
    self.getStoresAtLocationForStoreClass(controller, coordinate: coordinate, storeClass: BEStore.self, handler: handler)
  }
  
  open func getStoresAtLocationForStoreClass <StoreClass: BEStore> (_ controller : CoreProtocol?, coordinate: CLLocationCoordinate2D?, storeClass: StoreClass.Type, handler : @escaping ((_ success: Bool, _ stores : [BEStore]?) -> Void)) {
    let longitude: String? = (coordinate != nil) ? "\(coordinate!.longitude)" : nil
    let latitude: String? = (coordinate != nil) ? "\(coordinate!.latitude)" : nil
    let token = session.getAuthToken()
    
    controller?.showProgress("Retrieving Stores")
    apiService.getStoresAtLocation (longitude, latitude: latitude, token: token, storeClass: storeClass, handler: { (result) in
      controller?.hideProgress()
      
      if result.isFailure {
        controller?.showMessage(ApiError.findStoresError(reason: result.error! as! BEErrorType))
        handler(false, [])
      } else {
        handler(true, result.value!)
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
  //      } else {
  //        self.getBalanceForCard(controller, contactId: contactId, token: token, index: index + 1, cards: cards, handler: handler)
  //      }
  //    })
  //  }
  
  fileprivate func getBarCodeInfo(_ data: String?, cardId : String?, coupons : [BECoupon]) -> BarCodeInfo {
    if data == nil || data!.characters.count == 0{
      let contactId = session.getContactId()!
      
      return BarCodeInfo(data: contactId, type: .memberId)
    }
    else {
      let content = data!
      
      if cardId == nil && coupons.count > 0 {
        return BarCodeInfo(data: content, type: .rewardsToken)
      }
      else if cardId != nil  && coupons.count == 0 {
        return BarCodeInfo(data: content, type: .payToken)
      }
      else {
        return BarCodeInfo(data: content, type: .rewardsAndPayToken)
      }
    }
  }
}

public extension UIViewController {
  func validate(_ request : ContactRequest) -> Bool{
    if request.origin == nil {
      // Validate create contact request
      guard (request.getFirstName() != nil &&  !(request.getFirstName()?.isEmpty)!) else {
        self.showMessage("Registration Error", message: "Enter First Name")
        return false
      }
      guard (request.getLastName() != nil && !(request.getLastName()?.isEmpty)!) else {
        self.showMessage("Registration Error", message: "Enter Last Name")
        return false
      }
      guard (request.getPhone() != nil && (request.getPhone()?.isValidPhone())!) else {
        self.showMessage("Registration Error", message: "Please enter a valid phone number")
        return false
      }
      guard (request.getZipCode() != nil && (request.getZipCode()?.isValidZipCode())!) else {
        self.showMessage("Registration Error", message: "Enter 5 Digit Zipcode")
        return false
      }
      guard (request.getEmail() != nil && (request.getEmail()?.isValidEmail())!) else {
        self.showMessage("Registration Error", message: "Enter Valid Email")
        return false
      }
      guard (request.getPassword() != nil && !(request.getPassword()?.isEmpty)!) else {
        self.showMessage("Registration Error", message: "Enter Password")
        return false
      }
    }
    
    return true
  }
  
  func validate(_ email : String?, password : String?) -> Bool {
    guard (email?.isValidEmail())! else {
      self.showMessage("Login Error", message: "Enter Valid Email")
      return false
    }
    guard !(password?.isEmpty)! else {
      self.showMessage("Login Error", message: "Enter Password")
      return false
    }
    return true
  }
  
  func validate(_ password : String?, confirmPassword : String?) -> Bool {
    guard !(password?.isEmpty)! else {
      self.showMessage("Update Error", message: "Enter Password")
      return false
    }
    guard password == confirmPassword else {
      self.showMessage("Update Error", message: "Passwords do not match")
      return false
    }
    return true
  }
}


public struct BarCodeInfo {
  public let data: String
  public let type: BarCodeInfoType
  
  public enum BarCodeInfoType {
    case memberId
    case rewardsToken
    case payToken
    case rewardsAndPayToken
  }
}
