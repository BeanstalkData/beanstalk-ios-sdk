//
//  CoreService.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire

public typealias CoreService = CoreServiceT<HTTPAlamofireManager>

/**
 Main core model interface. Contains ApiCommunication as property. All request performed through ApiCommunication.
 Manages auth state of user and persists session-related data to provided session entity (BESessionProtocol).
 */

open class CoreServiceT <SessionManager: HTTPAlamofireManager>: BEAbstractRespondersHolder {
  public let apiService: ApiCommunication<SessionManager>
  let session: BESessionProtocol
  
  public private(set) var isAuthenticateInProgress: Bool = false
  
  open var validator: BERequestValidatorProtocol
  
  /**
   LocationTracker instance. Can be accessed as public property to call its methods.
   - Property onDidUpdate: By default is assigned by CoreService. Default implementation will send location data by calling *relocateContact*.
   - Property onDidChangePermissions: Can be assigned to track whether is location permissions denied at some point in order to appropriately notify user. Default implementation does nothing.
   - Property onDidFail: Can be assigned to track whether is some error occur. Default implementation does nothing.
   - Completion handlers can be reset to default by calling *subscribeForLocationTracking* on CoreService instance.
   */
  open var locationTracker: LocationTracker?
  
  public required init(apiKey: String, session: BESessionProtocol, apiUsername: String? = nil) {
    self.apiService = ApiCommunication(apiKey: apiKey, apiUsername: apiUsername)
    self.session = session
    self.validator = BERequestValidator()
    
    self.locationTracker = LocationTracker()
    self.subscribeForLocationTracking(relocateContactHandler: { (_, _) in })
  }
  
  public required init(apiKey: String, session: BESessionProtocol, apiUsername: String? = nil, beanstalkUrl: String) {
    self.apiService = ApiCommunication(apiKey: apiKey, apiUsername: apiUsername, beanstalkUrl: beanstalkUrl)
    self.session = session
    self.validator = BERequestValidator()
    
    self.locationTracker = LocationTracker()
    self.subscribeForLocationTracking(relocateContactHandler: { (_, _) in })
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
  open func registerLoyaltyAccount <ContactClass: BEContact> (request: ContactRequest, contactClass: ContactClass.Type, handler: @escaping (_ success: Bool, _ error: BEErrorType?) -> Void){
    guard self.validator.validate(createRequest: request, errorHandler: { handler(false, $0) }) else {
      handler(false, ApiError.unknown())
      return
    }
    
    request.normalize()
    guard let email = request.getEmail(), let password = request.getPassword() else {
      handler(false, ApiError.createContactFailed(reason: "No email or password in reauest"))
      return
    }
    
    apiService.createLoyaltyAccount(request, handler: {[weak self] result in
      if result.isFailure {
        handler(false, result.error as? BEErrorType)
        return
      }
      
      self?.auth( email: request.getEmail()!, password: request.getPassword()!, contactClass: contactClass, handler: { (authSuccess, authError) in
        guard authSuccess else {
          handler(authSuccess, authError)
          return
        }
        
        self?.checkLoyaltyAccount(handler: { (checkSuccess, checkError) in
          handler(authSuccess, authError)
        })
      })
    })
  }
  
  /**
   Utility call to check account is configured correctly after registerLoyaltyAccount is performed.
   Called after successful registerLoyaltyAccount.
   
   - Parameter handler: Completion handler.
   - Parameter success: Whether is request was successful.
   - Parameter error: Error if occur.
   */
  open func checkLoyaltyAccount(handler: @escaping (_ success: Bool, _ error: BEErrorType?) -> Void) {
    
    guard let contactId = self.session.getContactId() else {
      handler(false, ApiError.noContactIdInSession())
      return
    }
    
    apiService.checkLoyaltyAccount(contactId: contactId) { (result) in
      result.isFailure ?
        handler(false, result.error as? BEErrorType) :
        handler(true, nil)
    }
  }
  
  /**
   Performs register user request with checks for already existed.
   */
  open func register <ContactClass: BEContact> (request : ContactRequest, contactClass: ContactClass.Type, handler: @escaping (_ success: Bool, BEErrorType?) -> Void) {
    guard self.validator.validate(createRequest: request, errorHandler: { handler(false, $0) }) else {
      handler(false, ApiError.unknown())
      return
    }
    
    request.normalize()
    guard let email = request.getEmail(), let password = request.getPassword(), let phone = request.getPhone() else {
      handler(false, ApiError.createContactFailed(reason: "No required params in reauest"))
      return
    }
    
    apiService.checkContactsByEmailExisted(email, prospectTypes: [.eClub, .Loyalty], handler: {[weak self] (result) in
      guard let `self` = self else { return }
      
      if result.isFailure {
        handler(false, result.error as? BEErrorType)
        return
      }
      
      var updateExisted = result.value!
      
      self.apiService.checkContactsByPhoneExisted(phone, prospectTypes: [], handler: {[weak self] (result) in
        guard let `self` = self else { return }
        if result.isFailure {
          handler(false, result.error as? BEErrorType)
          return
        }
        
        updateExisted = updateExisted || result.value!
        
        self.apiService.createContact(request, contactClass: contactClass, handler: {[weak self] (result) in
          guard let `self` = self else { return }
          if result.isFailure {
            handler(false, result.error as? BEErrorType)
            return
          }
          
          guard !updateExisted else {
            self.auth(email: request.getEmail()!, password: request.getPassword()!, contactClass: contactClass, handler: handler)
            return
          }
          
          let contactId = result.value!.contactId
          self.apiService.createUser(email, password: password, contactId: contactId, handler: {[weak self] (result) in
            if result.isFailure {
              handler(false, result.error as? BEErrorType)
              return
            }
            
            self?.auth(email: email, password: password, contactClass: contactClass, handler: handler)
          })
        })
      })
    })
  }
  
  /**
   Checks user session.
   */
  open func autoSignIn <ContactClass: BEContact> (contactClass: ContactClass.Type, handler: @escaping ((_ success: Bool, _ error: BEErrorType?) -> Void)) {
    
    guard let contactId = self.session.getContactId() else {
      handler(false, ApiError.missingParameterError(reason: ""))
      return
    }
    
    guard let token = self.session.getAuthToken() else {
      handler(false, ApiError.missingParameterError(reason: ""))
      return
    }
    
    self.isAuthenticateInProgress = true
    
    self.apiService.checkUserSession(contactId, token: token) {[weak self] result in
      
      if result.isFailure {
        self?.isAuthenticateInProgress = false
        handler(false, result.error as? BEErrorType)
        return
      }
      
      self?.handleLoginComplete(contactId, token: token, contactClass: contactClass, handler: { (success, error) in
        self?.isAuthenticateInProgress = false
        handler(success, error)
      })
    }
  }
  
  /**
   Authenticates user.
   */
  open func authenticate <ContactClass: BEContact> (email: String?, password: String?, contactClass: ContactClass.Type, handler: @escaping ((_ success: Bool, _ error: BEErrorType?) -> Void)) {
    guard let email = email, let password = password else {
      return handler(false, ApiError.unknown())
    }
    
    guard self.validator.validate(email: email, password: password, errorHandler: { handler(false, $0) }) else {
      return handler(false, ApiError.unknown())
    }
    
    self.isAuthenticateInProgress = true
    
    self.apiService.authenticateUser(email, password: password, handler: {[weak self] (result) in
      
      if result.isFailure {
        self?.isAuthenticateInProgress = false
        handler(false, result.error as? BEErrorType)
        return
      }
      
      let contactId = result.value!.contactId
      let token = result.value!.token
      self?.handleLoginComplete(contactId, token: token, contactClass: contactClass, handler: { (success, error) in
        self?.isAuthenticateInProgress = false
        handler(success, error)
      })
    })
  }
  
  fileprivate func auth <ContactClass: BEContact> (email: String, password: String, contactClass: ContactClass.Type, handler: @escaping (_ success: Bool, _ error: BEErrorType?) -> Void) {
    self.isAuthenticateInProgress = true
    
    apiService.authenticateUser(email, password: password, handler: {[weak self] result in
      if result.isFailure {
        self?.isAuthenticateInProgress = false
        handler(false, result.error as? BEErrorType)
        return
      }
      
      guard let contactId = result.value?.contactId, let token = result.value?.token else {
        handler(false, ApiError.dataSerialization(reason: "No contactId or token"))
        return
      }
      
      self?.handleLoginComplete(contactId, token: token, contactClass: contactClass, handler: { (success, error) in
        self?.isAuthenticateInProgress = false
        handler(success, error)
      })
    })
  }
  
  /**
   Authenticate user with Facebook account
   
   - Parameter facebookId: facebook ID
   - Parameter facebookToken: facebook token
   - Parameter contactClass: Contact class.
   - Parameter handler: Completion handler.
   - Parameter success: Whether is request was successful.
   - Parameter error: Error if occur.
   
   */
  open func authWithFacebookUser<ContactClass: BEContact>(facebookId: String,
                                                          facebookToken: String,
                                                          contactClass: ContactClass.Type,
                                                          handler: @escaping (_ success: Bool, _ error: BEErrorType?) -> Void) {
    
    self.isAuthenticateInProgress = true
    
    apiService.checkFacebookAccountExisted(facebookId: facebookId, facebookToken: facebookToken) {[weak self] result in
      switch result {
      case .success(let response):
        self?.handleLoginComplete(response.contactId, token: response.contactToken, contactClass: contactClass, handler: { (success, error) in
          self?.isAuthenticateInProgress = false
          handler(success, error)
        })
        
      case .failure(let error):
        self?.isAuthenticateInProgress = false
        handler(false, error as? BEErrorType)
      }
    }
  }
  
  /**
   Authenticate user with Google account
   
   - Parameter googleId: google ID
   - Parameter googleToken: google token
   - Parameter contactClass: Contact class.
   - Parameter handler: Completion handler.
   - Parameter success: Whether is request was successful.
   - Parameter error: Error if occur.
   */
  open func authWithGoogleUser<ContactClass: BEContact>(googleId: String,
                                                        googleToken: String,
                                                        contactClass: ContactClass.Type,
                                                        handler: @escaping (_ success: Bool, _ error: BEErrorType?) -> Void) {
    
    self.isAuthenticateInProgress = true
    
    apiService.checkGoogleAccountExisted(googleId: googleId, googleToken: googleToken) {[weak self] result in
      switch result {
      case .success(let response):
        self?.handleLoginComplete(response.contactId, token: response.contactToken, contactClass: contactClass, handler: { (success, error) in
          self?.isAuthenticateInProgress = false
          handler(success, error)
        })
        
      case .failure(let error):
        self?.isAuthenticateInProgress = false
        handler(false, error as? BEErrorType)
      }
    }
  }
  
  fileprivate func handleLoginComplete <ContactClass: BEContact> (_ contactId : String?, token : String?, contactClass: ContactClass.Type, handler: @escaping (_ success: Bool, _ error: BEErrorType?) -> Void) {
    
    guard let contactId = contactId, let token = token else {
      self.clearSession()
      handler(false, ApiError.missingParameterError(reason: "No params contactId or token"))
      return
    }
    
    apiService.getContact(contactId, contactClass: contactClass, handler: {[weak self] (result) in
      guard result.isSuccess else {
        self?.session.setContact(nil)
        handler(false, result.error as? BEErrorType)
        return
      }
      
      self?.session.setContact(result.value!)
      self?.session.setAuthToke(token)
      handler(true, nil)
    })
  }
  
  /**
   Performs reset password request.
   */
  open func resetPassword(email : String?, handler: @escaping (_ success: Bool, _ error: BEErrorType?) -> Void) {
    guard self.validator.validate(email: email, errorHandler: { handler(false, $0) }) else {
      return handler(false, ApiError.unknown())
    }
    
    apiService.resetPassword(email!, handler: { (result) in
      if result.isFailure {
        handler(false, result.error as? BEErrorType)
        return
      }
      
      handler(true, nil)
    })
  }
  
  /**
   Logouts user.
   */
  open func logout(handler: @escaping (_ success: Bool, _ error: BEErrorType?) -> Void) {
    guard let contactId = self.session.getContactId(), let token = self.session.getAuthToken() else {
      handler(false, ApiError.missingParameterError(reason: ""))
      return
    }
    
    apiService.logoutUser(contactId, token : token, handler: {[weak self] (result) in
      self?.clearSession()
      
      handler(result.isSuccess, nil)
    })
  }
  
  //MARK: - Contact
  
  /**
   Requests contact model from server.
   */
  open func getContact <ContactClass: BEContact> (contactClass: ContactClass.Type, handler: @escaping (_ success: Bool, _ contact: ContactClass?, _ error: BEErrorType?) -> Void) {
    guard let contactId = self.session.getContactId() else {
      handler(false, nil, ApiError.missingParameterError(reason: ""))
      return
    }
    
    apiService.getContact(contactId, contactClass: contactClass, handler: {[weak self] result in
      if result.isFailure {
        handler(false, nil, result.error as? BEErrorType)
        return
      }
      
      self?.session.setContact(result.value)
      handler(true, result.value, nil)
    })
  }
  
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
    handler: @escaping (_ success : Bool, _ contactId: String?, _ contact: ContactClass?, _ error: BEErrorType?) -> Void) {
    
    request.normalize()
    
    apiService.createContact(request, contactClass: contactClass, fetchContact: fetchContact) {[weak self] result in
      if result.isFailure {
        handler(false, nil, nil, result.error as? BEErrorType)
        return
      }
      let contactId = result.value?.contactId
      let contact = result.value?.contact
      
      if fetchContact {
        self?.session.setContact(contact)
      }
      
      handler(true, contactId, contact, nil)
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
    handler: @escaping (_ success : Bool, _ contact : ContactClass?, _ error : BEErrorType?) -> Void) {
    
    request.normalize()
    
    apiService.updateContact(request: request, contactClass: contactClass, fetchContact: fetchContact) {[weak self] result in
      if result.isFailure {
        handler(false, nil, result.error as? BEErrorType)
        return
      }
      
      if let contact = result.value?.contact {
        self?.session.setContact(contact)
      }
      
      handler(true, result.value?.contact, nil)
    }
  }
  
  /**
   Sends a contact’s Geo Location data to server.
   
   - Parameter latitude: Latitude string.
   - Parameter longitude: Longitude string.
   - Parameter handler: Completion handler.
   - Parameter success: Whether is request was successful.
   - Parameter error: Error if occur.
   */
  
  open func relocateContact( latitude: String, longitude: String, handler: @escaping (_ success: Bool, _ error: BEErrorType?) -> Void) {
    guard let contactId = self.session.getContactId() else {
      handler(false, ApiError.noContactIdInSession())
      return
    }
    
    apiService.relocateContact( contactId: contactId, latitude: latitude, longitude: longitude, handler: {[weak self] result in
      if result.isFailure {
        handler(false, result.error as? BEErrorType)
        return
      }
      
      let value = result.value ?? false
      handler(value, nil)
    })
  }
  
  /**
   Retrieves image data from Beanstalk.
   
   - Parameter handler: Completion handler.
   - Parameter geoAssets: Geo assets response model.
   - Parameter error: Error if occur.
   */
  
  open func getContactGeoAssets( handler: @escaping (_ geoAssets: ContactGeoAssetsResponse?, _ error: BEErrorType?) -> Void) {
    guard let contactId = self.session.getContactId() else {
      handler(nil, ApiError.noContactIdInSession())
      return
    }
    
    apiService.getContactGeoAssets( contactId: contactId, handler: { (result) in
      if result.isFailure {
        handler(nil, result.error as? BEErrorType)
        return
      }
      
      guard let response = result.value else {
        handler(nil, ApiError.unknown())
        return
      }
      
      handler(response, nil)
    })
  }
  
  /**
   Deletes contact from server and clears from session.
   
   - Parameter contactId: Contact ID.
   */
  open func deleteContact( contactId: String, handler: @escaping (_ success: Bool, _ error: BEErrorType?) -> Void) {
    apiService.deleteContact(contactId: contactId) {[weak self] result in
      if result.isFailure {
        handler(false, result.error as? BEErrorType)
        return
      }
      
      self?.clearSession()
      
      handler(true, nil)
    }
  }
  
  /** Fetches contact by specific field. Completion handler returns contact (if found) or error (if occur).
   
   - Parameter fetchField: Field by which fetch will be performed.
   - Parameter fieldValue: Fetch field value, i.e. query string.
   - Parameter caseSensitive: Indicates whether is field values should be compared in case-sensitive manner. Default is _false_.
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
    caseSensitive: Bool = false,
    prospectTypes: [ProspectType] = [],
    contactClass: ContactClass.Type,
    handler: @escaping (_ success: Bool, _ contact: ContactClass?, _ error: BEErrorType?) -> Void
    ) {
    
    apiService.fetchContactBy(
      fetchField: fetchField,
      fieldValue: fieldValue,
      caseSensitive: caseSensitive,
      prospectTypes: prospectTypes,
      contactClass: contactClass,
      handler: { result in
        if result.isFailure {
          handler(false, nil, result.error as? BEErrorType)
          return
        }
        
        handler(true, result.value ?? nil, nil)
    })
  }
  
  /**
   Checks user exists by email.
   */
  open func checkContactsByEmailExisted( email: String, prospectTypes: [ProspectType], handler: @escaping (_ success: Bool, _ existed: Bool?, _ error: BEErrorType?) -> Void) {
    apiService.checkContactsByEmailExisted(email, prospectTypes: prospectTypes) { (result) in
      if result.isFailure {
        handler(false, nil, result.error as? BEErrorType)
        return
      }
      
      handler(true, result.value, nil)
    }
  }
  
  /**
   Checks user exists by phone number.
   */
  open func checkContactsByPhoneExisted( phoneNumber: String, prospectTypes: [ProspectType], handler: @escaping (_ success: Bool, _ existed: Bool?, _ error: BEErrorType?) -> Void) {
    apiService.checkContactsByPhoneExisted(phoneNumber.formatPhoneNumberToNationalSignificant(), prospectTypes: prospectTypes) { (result) in
      if result.isFailure {
        handler(false, nil, result.error as? BEErrorType)
        return
      }
      
      handler(true, result.value, nil)
    }
  }
  
  //MARK: -
  
  /**
   Updates password.
   */
  open func updatePassword(password: String?, confirmPassword: String?, handler: @escaping (_ success: Bool, _ error: BEErrorType?) -> Void) {
    guard self.validator.validate(password: password, confirmPassword: confirmPassword, errorHandler: { handler(false, $0) }) else {
      handler(false, ApiError.unknown())
      return
    }
    
    guard let contactId = self.session.getContactId(), let token = self.session.getAuthToken() else {
      handler(false, ApiError.missingParameterError(reason: ""))
      return
    }
    
    apiService.updatePassword(password!, contactId: contactId, token: token, handler: { result in
      if result.isFailure {
        handler(false, result.error as? BEErrorType)
        return
      }
      
      handler(true, nil)
    })
  }
  
  /**
   Gets available rewards for couponClass BECoupon.
   */
  open func getAvailableRewards(handler: @escaping (_ success: Bool, _ coupons: [BECouponProtocol], _ error: BEErrorType?)->Void){
    self.getAvailableRewards(couponClass: BECoupon.self, handler: handler)
  }
  
  /**
   Gets available rewards for provided coupon class.
   */
  open func getAvailableRewards <CouponClass: BECoupon> (couponClass: CouponClass.Type, handler: @escaping (_ success: Bool, _ coupons: [BECouponProtocol], _ error: BEErrorType?)->Void){
    guard let contactId = self.session.getContactId() else {
      handler(false, [], ApiError.missingParameterError(reason: ""))
      return
    }
    
    apiService.getUserOffers(contactId, couponClass: couponClass, handler: {[weak self] result in
      if result.isFailure {
        handler(false, [], result.error as? BEErrorType)
        return
      }
      
      let rewards = result.value
      self?.session.saveRewards(rewards)
      handler(true, rewards ?? [], nil)
    })
  }
  
  /**
   Gets user progress.
   */
  open func getUserProgress(handler: @escaping (_ success: Bool, _ progress: Double?, _ error: BEErrorType?)->Void){
    guard let contactId = self.session.getContactId() else {
      handler(false, nil, ApiError.missingParameterError(reason: ""))
      return
    }
    
    apiService.getProgress(contactId, handler: { result in
      if result.isFailure {
        handler(false, nil, result.error as? BEErrorType)
        return
      }
      
      handler(true, result.value, nil)
    })
  }
  
  /**
   Gets gift cards for giftCardClass BEGiftCard.
   */
  open func getGiftCards(handler: @escaping (_ success: Bool, _ cards: [BEGiftCard], _ error: BEErrorType?)->Void){
    self.getGiftCards(giftCardClass: BEGiftCard.self, handler: handler)
  }
  
  /**
   Gets gift cards for provided coupon class.
   */
  open func getGiftCards <GiftCardClass: BEGiftCard> (giftCardClass: GiftCardClass.Type, handler: @escaping (_ success: Bool, _ cards: [BEGiftCard], _ error: BEErrorType?)->Void){
    
    guard let contactId = self.session.getContactId(), let token = self.session.getAuthToken() else {
      handler(false, [], ApiError.missingParameterError(reason: ""))
      return
    }
    
    apiService.getGiftCards(contactId, token: token, giftCardClass: giftCardClass, handler: { result in
      if result.isFailure {
        handler(false, [], result.error as? BEErrorType)
        return
      }
      
      let cards = result.value
      handler(true, cards ?? [], nil)
    })
  }
  
  /**
   Performs start payment request.
   */
  open func startPayment(cardId : String?, coupons: [BECouponProtocol], handler: @escaping (_ success: Bool, BarCodeInfo, _ error: BEErrorType?)->Void){
    
    if cardId == nil && coupons.count == 0 {
      let data = getBarCodeInfo(nil, cardId: cardId, coupons: coupons)
      handler(true, data, nil)
      return
    }
    
    guard let contactId = self.session.getContactId(),
      let token = self.session.getAuthToken() else {
        let data = getBarCodeInfo(nil, cardId: cardId, coupons: coupons)
        handler(true, data, nil)
        return
    }
    
    let couponsString : String = coupons.reduce("", { $0 == "" ? $1.number! : $0 + "," + $1.number! })
    
    apiService.startPayment(contactId, token: token, paymentId: cardId, coupons: couponsString, handler: {[weak self] result in
      
      guard result.isSuccess else {
        let data = self?.getBarCodeInfo(nil, cardId: cardId, coupons: coupons) ?? BarCodeInfo(data: "", type: .memberId)
        return handler(false, data, ApiError.paymentError(reason: result.error as? BEErrorType))
      }
      
      let number = result.value ?? nil
      
      var data = self?.getBarCodeInfo(number, cardId: cardId, coupons: coupons) ?? BarCodeInfo(data: "", type: .memberId)
      handler(true, data, nil)
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
    
    apiService.pushNotificationEnroll(contactId, deviceToken: deviceToken, handler: {[weak self] result in
      guard result.isSuccess else {
        handler(false, result.error as? BEErrorType)
        return
      }
      
      self?.session.setRegisteredAPNSToken(deviceToken)
      handler(true, nil)
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
    
    apiService.pushNotificationDelete(contactId, handler: {[weak self] result in
      guard result.isSuccess else {
        handler(false, result.error as? BEErrorType)
        return
      }
      
      self?.session.setRegisteredAPNSToken(nil)
      handler(true, nil)
    })
  }
  
  /**
   Gets user messages from user inbox.
   */
  open func pushNotificationGetMessages (maxResults: Int, handler: @escaping (_ success: Bool, _ messages: [BEPushNotificationMessage]?, _ error: BEErrorType?) -> Void) {
    guard let contactId = self.session.getContactId() else {
      handler(false, nil, ApiError.unknown())
      return
    }
    
    apiService.pushNotificationGetMessages(contactId, maxResults: maxResults, handler: {[weak self] result in
      guard result.isSuccess else {
        handler(false, nil, result.error as? BEErrorType)
        return
      }
      
      handler(true, result.value, nil)
    })
  }
  
  /**
   Changes message status.
   
   Possible values:
   * Read
   * Unread
   * Delete
   
   - Parameter messageId: Message ID.
   - Parameter status: Message status.
   - Parameter handler: Completion handler.
   - Parameter success: Whether is request was successful.
   - Parameter error: Error if occur.
   */
  open func pushNotificationUpdateStatus(_ messageId: String, status: PushNotificationStatus, handler: @escaping (_ success: Bool, _ error: BEErrorType?) -> Void) {
    guard self.session.getContactId() != nil else {
      handler(false, ApiError.noContactIdInSession())
      return
    }
    
    apiService.pushNotificationUpdateStatus(messageId, status: status) { result in
      if result.isSuccess {
        handler(true, nil)
        return
      }
      
      handler(false, result.error as? BEErrorType)
    }
  }
  
  /**
   Gets message for specific Id.
   */
  open func pushNotificationGetMessageById(_ messageId: String, handler: @escaping (_ success: Bool, _ message: BEPushNotificationMessage?, _ error: BEErrorType?) -> Void) {
    guard self.session.getContactId() != nil else {
      handler(false, nil, ApiError.noContactIdInSession())
      return
    }
    
    apiService.pushNotificationGetMessageById(messageId) { result in
      if result.isSuccess {
        handler(true, result.value, nil)
        return
      }
      
      handler(false, nil, result.error as? BEErrorType)
    }
  }
  
  //MARK: - Locations
  
  /**
   Performs stores at location request for storeClass BEStore.
   */
  open func getStoresAtLocation(coordinate: CLLocationCoordinate2D?, handler: @escaping ((_ success: Bool, _ stores : [BEStoreProtocol]?, _ error: BEErrorType?) -> Void)) {
    self.getStoresAtLocation(coordinate: coordinate, storeClass: BEStore.self, handler: handler)
  }
  
  /**
   Performs stores at location request for store class.
   */
  open func getStoresAtLocation <StoreClass> (coordinate: CLLocationCoordinate2D?, version: String? = nil, storeClass: StoreClass.Type, handler: @escaping ((_ success: Bool, _ stores : [BEStoreProtocol]?, _ error: BEErrorType?) -> Void)) where StoreClass: BEStoreProtocol {
    let longitude: String? = (coordinate != nil) ? "\(coordinate!.longitude)" : nil
    let latitude: String? = (coordinate != nil) ? "\(coordinate!.latitude)" : nil
    let token = self.session.getAuthToken()
    
    apiService.getStoresAtLocation (longitude, latitude: latitude, token: token, version: version, storeClass: storeClass, handler: { result in
      if result.isFailure {
        handler(false, [], result.error as? BEErrorType)
        return
      }
      
      handler(true, result.value!, nil)
    })
  }
  
  /**
   Performs store with storeNumber for store class
   */
  
  open func getStore <StoreClass> (storeNumber: String?, version: String? = nil, storeClass: StoreClass.Type, handler: @escaping ((_ success: Bool, _ store : BEStoreProtocol?, _ error: BEErrorType?) -> Void)) where StoreClass: BEStoreProtocol {
    let token = self.session.getAuthToken()
    
    apiService.getStore(storeId: storeNumber, token: token, version: version, storeClass: storeClass) { result in
      guard result.isSuccess else {
        return handler(false, nil, result.error as? BEErrorType)
      }
      
      handler(true, result.value!, nil)
    }
  }
  
  //MARK: - Transactions
  
  /**
   Performs track transaction request.
   
   - Note: This method can only be performed if API username provided.
   
   - Parameter transactionData: Can take any JSON string. Will interpret JSON as a parsed array and create searchable transaction object which can be used for campaigns and other generic transactional workflows.
   - Parameter handler: Completion handler.
   - Parameter transaction: Transaction model from API response.
   - Parameter error: Error if occur.
   */
  open func trackTransaction( transactionData: String, handler: @escaping (_ transaction: BETransaction?, _ error: BEErrorType?) -> Void) {
    guard let contactId = self.session.getContactId() else {
      handler(nil, ApiError.noContactIdInSession() )
      return
    }
    
    apiService.trackTransaction( contactId: contactId, transactionData: transactionData) { (result) in
      if result.isFailure {
        handler(nil, result.error as? BEErrorType)
        return
      }
      
      handler(result.value?.transaction, nil)
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
  
  open func getTransactions( startDate: Date?, endDate: Date?, handler: @escaping (_ transactions: [BETransaction]?, _ error: BEErrorType?) -> Void) {
    guard let contactId = self.session.getContactId() else {
      handler(nil, ApiError.noContactIdInSession() )
      return
    }
    
    apiService.getTransactions( contactId: contactId, startDate: startDate, endDate: endDate) { (result) in
      if result.isFailure {
        handler(nil, result.error as? BEErrorType)
        return
      }
      
      handler(result.value, nil)
    }
  }
  
  //MARK: - Support
  
  /**
   Sends support request.
   
   - Parameter supportRequest: Support request model. All fields should be filled.
   - Parameter handler: Completion handler.
   - Parameter error: Error if occur.
   */
  
  public func sendSupportRequest( supportRequest: SupportRequest, handler: @escaping (_ error: BEErrorType?) -> Void) {
    apiService.sendSupportRequest( supportRequest: supportRequest) { error in
      handler(error)
    }
  }
  
  //MARK: - Location Tracking
  
  open func subscribeForLocationTracking(relocateContactHandler: @escaping (Bool, BEErrorType?) -> Void) {
    self.locationTracker?.onDidUpdate = {[weak self] location in
      self?.relocateContact( latitude: "\(location.latitude)", longitude: "\(location.longitude)", handler: relocateContactHandler)
    }
    
    self.locationTracker?.onDidChangePermissions = { (granted) in
      
    }
    
    self.locationTracker?.onDidFail = { (error) in
      
    }
  }
  
  //MARK: - Private
  
  fileprivate func getBarCodeInfo(_ data: String?, cardId : String?, coupons : [BECouponProtocol]) -> BarCodeInfo {
    guard let content = data, !content.isEmpty else {
      let contactId = self.session.getContactId() ?? ""
      return BarCodeInfo(data: contactId, type: .memberId)
    }
    
    if cardId == nil && coupons.count > 0 {
      return BarCodeInfo(data: content, type: .rewardsToken)
    }
    
    if cardId != nil  && coupons.count == 0 {
      return BarCodeInfo(data: content, type: .payToken)
    }
    
    return BarCodeInfo(data: content, type: .rewardsAndPayToken)
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
