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

/**
 Main core model interface. Contains ApiCommunication as property. All request performed through ApiCommunication.
 Manages auth state of user and persists session-related data to provided session entity (BESessionProtocol).
 */

open class CoreServiceT <SessionManager: HTTPAlamofireManager>: BEAbstractRespondersHolder {
  public let apiService: ApiCommunication<SessionManager>
  let session: BESessionProtocol
  
  fileprivate var p_isAuthenticateInProgress = false
  open var isAuthenticateInProgress: Bool {
    get {
      return self.p_isAuthenticateInProgress
    }
  }
  
  public required init(apiKey: String, session: BESessionProtocol, apiUsername: String? = nil) {
    self.apiService = ApiCommunication(apiKey: apiKey, apiUsername: apiUsername)
    self.session = session
  }
  
  /**
   Returns current session model.
   */
  open func getSession() -> BESessionProtocol? {
    return session
  }
  
  /**
   Calls clearSession on session model.
   */
  open func clearSession() {
    self.session.clearSession()
  }
  
  /**
   Checks whether is user contact Id and access token available.
   */
  open func isAuthenticated() -> Bool{
    let contactId = self.session.getContactId()
    let token = self.session.getAuthToken()
    return contactId != nil && token != nil
  }
  
  /**
   Checks whether is server reachable.
   */
  open func isOnline() -> Bool {
    return self.apiService.isOnline()
  }
  
  open func addResponder(_ responder: BEApiResponder) {
    self.apiService.addResponder(responder)
  }
  
  open func removeResponder(_ responder: BEApiResponder) {
    self.apiService.addResponder(responder)
  }
  
  /**
   Performs create loyalty user request.
   */
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
  
  /**
   Performs register user request with checks for already existed.
   */
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
  
  /**
   Checks user session.
   */
  open func autoSignIn <ContactClass: BEContact> (_ controller: AuthenticationProtocol?, contactClass: ContactClass.Type, handler : @escaping ((_ success: Bool) -> Void)) {
    
    guard let contactId = self.session.getContactId() else {
      handler(false)
      return
    }
    
    guard let token = self.session.getAuthToken() else {
      handler(false)
      return
    }
    
    self.p_isAuthenticateInProgress = true
    controller?.showProgress("Attempting to Login")
    
    weak var weakSelf = self
    self.apiService.checkUserSession(contactId, token: token) { result in
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
  
  /**
   Authenticates user.
   */
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
  
  /**
   Performs reset password request.
   */
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
  
  /**
   Logouts user.
   */
  open func logout(_ controller : CoreProtocol?, handler : @escaping (_ success: Bool) -> Void){
    
    guard let contactId = self.session.getContactId() else {
      handler(false)
      return
    }
    
    guard let token = self.session.getAuthToken() else {
      handler(false)
      return
    }
    
    let registeredDeviceToken = self.session.getRegisteredAPNSToken()
    
    controller?.showProgress("Logout...")
    
    weak var weakSelf = self
    apiService.logoutUser(contactId, token : token, handler: { (result) in
      controller?.hideProgress()
      
      weakSelf?.clearSession()
      
      handler(result.isSuccess)
    })
  }
  
  /**
   Checks user exists by email.
   */
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
  
  /**
   Requests contact model from server.
   */
  open func getContact <ContactClass: BEContact> (_ controller : CoreProtocol?, contactClass: ContactClass.Type, handler : @escaping (Bool, ContactClass?) -> Void) {
    guard let contactId = self.session.getContactId() else {
      handler(false, nil)
      return
    }
    
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
  
  
  //MARK: - Contact
  
  /**
   Creates contact of provided class and persists it in session.
   
   - Note: Current server API returns only *contactId* on create request. So in order to return contact model (if requested) - *getContact()* request is performed. There might be situations (bad network conditions, etc.) when contact is created but *getContact()* request failed, so only *contactId* will be available.
   
   - Parameter request: Contact request.
   - Parameter contactClass: Contact class.
   - Parameter fetchContact: Contact model will be fetched by *getContact()*. Default is *false*.
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
   
   - Parameter request: Contact request.
   - Parameter fetchContact: Contact model will be fetched by *getContact()*. Default is *false*.
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
   
   - Parameter contactId: Contact ID.
   */
  open func deleteContact(
    contactId: String,
    handler : @escaping (_ success: Bool, _ error: BEErrorType?) -> Void) {
    
    weak var weakSelf = self
    apiService.deleteContact(contactId: contactId) { (result) in
      if result.isFailure {
        handler(false, result.error as? BEErrorType)
      } else {
        weakSelf?.clearSession()
        
        handler(true, nil)
      }
    }
  }
  
  /** Fetches contact by specific field. Completion handler returns contact (if found) or error (if occur).
   
   ## Note ##
   Currently it checks for exact match, i.e.
   ````
   isEqual = (fieldValue == contact[fetchField])
   ````
   
   - Parameter fetchField: Field by which fetch will be performed.
   - Parameter fieldValue: Fetch field value, i.e. query string.
   - Parameter prospectTypes: Prospect types list. Contact with specified prospect value will be evaluated only. If empty, prospect will be ignored. Default is *empty*.
   - Parameter contactClass: Contact model class.
   - Parameter handler: Completion handler.
   - Parameter success: Whether is request was successful.
   - Parameter contact: Contact model if found.
   - Parameter error: Error if occur.
   */
  
  open func fetchContactBy <ContactClass: BEContact> (
    fetchField: ContactFetchField,
    fieldValue: String,
    prospectTypes: [ProspectType] = [],
    contactClass: ContactClass.Type,
    handler: @escaping (_ success: Bool, _ contact: ContactClass?, _ error: BEErrorType?) -> Void
    ) {
    
    weak var weakSelf = self
    apiService.fetchContactBy(
      fetchField: fetchField,
      fieldValue: fieldValue,
      prospectTypes: prospectTypes,
      contactClass: contactClass,
      handler: { (result) in
        
        if result.isFailure {
          handler(false, nil, result.error as? BEErrorType)
        } else {
          if let contact = result.value {
            handler(true, contact, nil)
          } else {
            handler(true, nil, nil)
          }
        }
    })
  }
  
  //MARK: -
  
  /**
   Updates password.
   */
  open func updatePassword(_ controller : UpdatePasswordProtocol?, password: String?, confirmPassword: String?, handler : @escaping (Bool) -> Void){
    
    if controller != nil {
      guard controller!.validate(password, confirmPassword: confirmPassword) else {
        handler(false)
        return
      }
    }
    
    guard let contactId = self.session.getContactId() else {
      handler(false)
      return
    }
    
    guard let token = self.session.getAuthToken() else {
      handler(false)
      return
    }
    
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
  
  /**
   Gets available rewards for couponClass BECoupon.
   */
  open func getAvailableRewards(_ controller : CoreProtocol?, handler : @escaping (Bool, [BECoupon])->Void){
    self.getAvailableRewardsForCouponClass(controller, couponClass: BECoupon.self, handler: handler)
  }
  
  /**
   Gets available rewards for provided coupon class.
   */
  open func getAvailableRewardsForCouponClass <CouponClass: BECoupon> (_ controller : CoreProtocol?, couponClass: CouponClass.Type, handler : @escaping (Bool, [BECoupon])->Void){
    
    guard let contactId = self.session.getContactId() else {
      handler(false, [])
      return
    }
    
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
  
  /**
   Gets user progress.
   */
  open func getUserProgress(_ controller : CoreProtocol?, handler : @escaping (Double?, ApiError?)->Void){
    guard let contactId = self.session.getContactId() else {
      handler(nil, nil)
      return
    }
    
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
  
  /**
   Gets gift cards for giftCardClass BEGiftCard.
   */
  open func getGiftCards(_ controller : CoreProtocol?, handler : @escaping (Bool, [BEGiftCard])->Void){
    self.getGiftCardsForGiftCardClass(controller, giftCardClass: BEGiftCard.self, handler: handler)
  }
  
  /**
   Gets gift cards for provided coupon class.
   */
  open func getGiftCardsForGiftCardClass <GiftCardClass: BEGiftCard> (_ controller : CoreProtocol?, giftCardClass: GiftCardClass.Type, handler : @escaping (Bool, [BEGiftCard])->Void){
    
    guard let contactId = self.session.getContactId() else {
      handler(false, [])
      return
    }
    
    guard let token = self.session.getAuthToken() else {
      handler(false, [])
      return
    }
    
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
  
  /**
   Performs start payment request.
   */
  open func startPayment(_ controller : CoreProtocol?, cardId : String?, coupons: [BECoupon], handler : @escaping (BarCodeInfo)->Void){
    
    if cardId == nil && coupons.count == 0 {
      let data = getBarCodeInfo(nil, cardId: cardId, coupons: coupons)
      handler(data)
      return
    }
    
    guard let contactId = self.session.getContactId() else {
      let data = getBarCodeInfo(nil, cardId: cardId, coupons: coupons)
      handler(data)
      return
    }
    
    guard let token = self.session.getAuthToken() else {
      let data = getBarCodeInfo(nil, cardId: cardId, coupons: coupons)
      handler(data)
      return
    }
    
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
  
  /**
   Performs push enroll request.
   */
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
  
  /**
   Performs push delete request.
   */
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
  
  /**
   Gets user messages from user inbox.
   */
  open func pushNotificationGetMessages (maxResults: Int, handler : @escaping (_ messages: [BEPushNotificationMessage]?, _ error: BEErrorType?) -> Void) {
    
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
  
  /**
   Changes message status.
   
   Possible values:
   * READ
   * UNREAD
   * DELETED
   
   */
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
  
  /**
   Gets message for specific Id.
   */
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
  
  /**
   Performs stores at location request for storeClass BEStore.
   */
  open func getStoresAtLocation(_ controller : CoreProtocol?, coordinate: CLLocationCoordinate2D?, handler : @escaping ((_ success: Bool, _ stores : [BEStore]?) -> Void)) {
    self.getStoresAtLocationForStoreClass(controller, coordinate: coordinate, storeClass: BEStore.self, handler: handler)
  }
  
  /**
   Performs stores at location request for store class.
   */
  open func getStoresAtLocationForStoreClass <StoreClass: BEStore> (_ controller : CoreProtocol?, coordinate: CLLocationCoordinate2D?, storeClass: StoreClass.Type, handler : @escaping ((_ success: Bool, _ stores : [BEStore]?) -> Void)) {
    let longitude: String? = (coordinate != nil) ? "\(coordinate!.longitude)" : nil
    let latitude: String? = (coordinate != nil) ? "\(coordinate!.latitude)" : nil
    let token = self.session.getAuthToken()
    
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
  
  
  //MARK: - Transactions
  
  /**
   Performs track transaction request.
   
   - Note: This method can only be performed if API username provided.
   
   - Parameter transactionData: Can take any JSON string. Will interpret JSON as a parsed array and create searchable transaction object which can be used for campaigns and other generic transactional workflows.
   - Parameter handler: Completion handler.
   - Parameter transaction: Transaction model from API response.
   - Parameter error: Error if occur.
   */
  public func trackTransaction(
    transactionData: String,
    handler: @escaping (_ transaction: BETransaction?, _ error: BEErrorType?) -> Void) {
    
    guard let contactId = self.session.getContactId() else {
      handler(nil, ApiError.noContactIdInSession() )
      return
    }
    
    apiService.trackTransaction(
      contactId: contactId,
      transactionData: transactionData) { (result) in
        
        if result.isFailure {
          handler(nil, result.error as? BEErrorType)
        } else {
          handler(result.value?.transaction, nil)
        }
    }
  }
  
  /**
   Retrieve transaction events.
   
   * Dates are sent in the format YYYY-MM-DD.
   * If no dates are passed, all events for the _contactId_ will be returned.
   * To retrieve events for a specific date, set _startDate_ and _endDate_ to the same date.
   * If _startDate_ and _endDate_ are both set, all events in that range will be returned.
   * If only _startDate_ is set, all events from that day until now will be returned.
   * If only _endDate_ is set, all events until that day will be returned.
   
   - Parameter startDate: The beginning date for transaction events.
   - Parameter endDate: The end date for transaction events.
   - Parameter handler: Completion handler.
   - Parameter transactions: Transaction models.
   - Parameter error: Error if occur.
   */
  
  public func getTransactions(
    startDate: Date?,
    endDate: Date?,
    handler: @escaping (_ transactions: [BETransaction]?, _ error: BEErrorType?) -> Void) {
    
    guard let contactId = self.session.getContactId() else {
      handler(nil, ApiError.noContactIdInSession() )
      return
    }
    
    apiService.getTransactions(
      contactId: contactId,
      startDate: startDate,
      endDate: endDate) { (result) in
        
        if result.isFailure {
          handler(nil, result.error as? BEErrorType)
        } else {
          handler(result.value, nil)
        }
    }
  }
  
  //MARK: - Private
  
  fileprivate func getBarCodeInfo(_ data: String?, cardId : String?, coupons : [BECoupon]) -> BarCodeInfo {
    if data == nil || data!.characters.count == 0{
      guard let contactId = self.session.getContactId() else {
        return BarCodeInfo(data: "", type: .memberId)
      }
      
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
