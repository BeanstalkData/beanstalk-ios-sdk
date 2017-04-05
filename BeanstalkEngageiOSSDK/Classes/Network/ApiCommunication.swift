//
//  ApiCommunication.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import AlamofireObjectMapper

public struct BEApiResponder: Equatable, WeakResponderHolder {
  public weak var responder: AnyObject?
  
  public let networkStatusChanged: ((_ isOnline: Bool) -> Void)?
  
  //MARK: -
  
  public func isEmpty() -> Bool {
    return (self.responder == nil)
  }
  
  public init(responder: AnyObject?, networkStatusChanged: ((_ isOnline: Bool) -> Void)? = nil) {
    self.responder = responder
    self.networkStatusChanged = networkStatusChanged
  }
}

public func ==(left: BEApiResponder, right: BEApiResponder) -> Bool {
  return left.responder === right.responder
}

open class ApiCommunication <SessionManagerClass: HTTPAlamofireManager>: BERespondersHolder <BEApiResponder> {
  fileprivate let beanstalUrl = "proc.beanstalkdata.com"
  fileprivate let BASE_URL: String
  fileprivate let apiKey: String
  
  internal let reachabilityManager: Alamofire.NetworkReachabilityManager
  
  internal var dataGenerator: MockDataGenerator?
  
  public required init(apiKey: String) {
    self.BASE_URL = "https://" + beanstalUrl
    self.apiKey = apiKey
    
    self.reachabilityManager = Alamofire.NetworkReachabilityManager(host: beanstalUrl)!
    
    super.init()
    
    weak var weakSelf = self
    self.reachabilityManager.listener = { status in
      print("Network Status Changed: \(status)")
      weakSelf?.notifyNetworkReachabilityObservers()
    }
    self.reachabilityManager.startListening()
  }
  
  fileprivate func notifyNetworkReachabilityObservers() {
    let isOnline = self.isOnline()
    self.enumerateObservers { (i) in
      i.networkStatusChanged?(isOnline)
    }
  }
  
  open func isOnline() -> Bool {
    return self.reachabilityManager.isReachable
  }
  
  open func checkContactsByEmailExisted(_ email: String, prospectTypes: [ProspectType], handler: @escaping (Result<Bool>) -> Void) {
    if (isOnline()) {
      let params = ["type": "email",
                    "key": self.apiKey,
                    "q": email
      ]
      SessionManagerClass.getSharedInstance().request(BASE_URL + "/contacts", method: .get, parameters : params)
        .validate(getDefaultErrorHandler())
        .responseString {
          response in
          if response.result.isSuccess {
            if response.result.value == Optional("null") {
              handler(.success(false))
            } else {
              let responseData = response.result.value?.data(using: String.Encoding.utf8)
              var jsonResponse : AnyObject? = nil
              
              do {
                jsonResponse = try JSONSerialization.jsonObject(with: responseData!, options: []) as? AnyObject
              } catch { }
              
              guard let data = jsonResponse as? [AnyObject] else {
                handler(.success(false))
                return
              }
              
              guard data.count >= 1 else {
                handler(.success(false))
                return
              }
              
              for contactData in data {
                if let contact = contactData as? [String : AnyObject] {
                  var emailEquals = false
                  var prospectEquals = true
                  
                  
                  // check for email equals
                  guard let contactEmail = contact["contactEmail"] as? String else {
                    continue
                  }
                  
                  if contactEmail == email {
                    emailEquals = true
                    
                    // check for required prospect type
                    if let prospect = contact["Prospect"] as? String {
                      // we need initial 'false' if desired prospect type specified
                      var contactProspectEquals = (prospectTypes.count == 0)
                      
                      for prospectType in prospectTypes {
                        if prospectType == prospect {
                          contactProspectEquals = true
                          break
                        }
                      }
                      
                      prospectEquals = contactProspectEquals
                    }
                  }
                  
                  // if both email and prospect satusfies - contact exists
                  if emailEquals && prospectEquals {
                    handler(.success(true))
                    return
                  }
                }
              }
              
              handler(.failure(ApiError.unknown()))
            }
          } else {
            handler(.failure(ApiError.network(error: response.result.error)))
          }
      }
    } else {
      handler(.failure(ApiError.networkConnectionError()))
    }
  }
  
  open func checkContactsByPhoneExisted(_ phone: String, prospectTypes: [ProspectType], handler: @escaping (Result<Bool>) -> Void) {
    if (isOnline()) {
      let params = ["type": "cell_number",
                    "key": self.apiKey,
                    "q": phone
      ]
      SessionManagerClass.getSharedInstance().request(BASE_URL + "/contacts", method: .get, parameters : params)
        .validate(getDefaultErrorHandler())
        .responseString {
          response in
          if response.result.isSuccess {
            if response.result.value == Optional("null") {
              handler(.success(false))
            } else {
              let responseData = response.result.value?.data(using: String.Encoding.utf8)
              var jsonResponse : AnyObject? = nil
              
              do {
                jsonResponse = try JSONSerialization.jsonObject(with: responseData!, options: []) as? AnyObject
              } catch { }
              
              guard let data = jsonResponse as? [AnyObject], data.count >= 1 else {
                handler(.success(false))
                return
              }
              
              for contactData in data {
                if let contact = contactData as? [String : AnyObject] {
                  var phoneEquals = false
                  var prospectEquals = true
                  
                  
                  // check for email equals
                  guard let contactPhone = contact["Cell_Number"] as? String else {
                    continue
                  }
                  
                  if contactPhone == phone {
                    phoneEquals = true
                    
                    // check for required prospect type
                    if let prospect = contact["Prospect"] as? String {
                      // we need initial 'false' if desired prospect type specified
                      var contactProspectEquals = (prospectTypes.count == 0)
                      
                      for prospectType in prospectTypes {
                        if prospectType == prospect {
                          contactProspectEquals = true
                          break
                        }
                      }
                      
                      prospectEquals = contactProspectEquals
                    }
                  }
                  
                  // if both email and prospect satusfies - contact exists
                  if phoneEquals && prospectEquals {
                    handler(.success(true))
                    return
                  }
                }
              }
              
              handler(.failure(ApiError.unknown()))
            }
          } else {
            handler(.failure(ApiError.network(error: response.result.error)))
          }
      }
    } else {
      handler(.failure(ApiError.networkConnectionError()))
    }
  }
  
  open func createLoyaltyAccount (_ request : ContactRequest, handler: @escaping (Result<BELoyaltyUser?>) -> Void) {
    if (isOnline()) {
      
      var params = Mapper().toJSON(request)
      params["Source"] = "iosapp"
      
      SessionManagerClass.getSharedInstance().request(BASE_URL + "/addPaymentLoyaltyAccount/?key=" + self.apiKey, method: .post, parameters: params)
        .validate(getDefaultErrorHandler())
        .responseObject(completionHandler: { (response : DataResponse<BELoyaltyUser>) in
          if (response.result.isSuccess) {
            if response.result.value != nil {
              handler(.success(response.result.value))
            } else {
              handler(.failure(ApiError.registrationFailed(reason : nil)))
            }
          } else {
            if (response.response?.statusCode == 200) {
              handler(.failure(ApiError.registrationFailed(reason : nil)))
            } else {
              handler(.failure(ApiError.network(error: response.result.error)))
            }
          }
        })
    } else {
      handler(.failure(ApiError.networkConnectionError()))
    }
  }
  
  
  //MARK: - Contact
  
  /**
   Create contact request.
   
   - Note: Current server API returns only *contactId* on create request. So in order to return contact model (if requested) - *getContact()* request is performed. There might be situations (bad network conditions, etc.) when contact is created but *getContact()* request failed, so only *contactId* will be available.
   
   - parameters:
      - request: Contact request.
      - contactClass: Contact class.
      - fetchContact: Contact model will be fetched by *getContact()*. Default is *false*.
   */
  open func createContact <ContactClass: Mappable> (
    _ request : ContactRequest,
    contactClass: ContactClass.Type,
    fetchContact: Bool = false,
    handler: @escaping (_ result: Result<ContactRequestResponse <ContactClass>>) -> Void) {
    
    guard isOnline() else {
      handler(.failure(ApiError.networkConnectionError()))
      return
    }
    
    var params = Mapper().toJSON(request)
    params["Cell_Number"] = params["CellNumber"]
    params["Source"] = "iosapp"
    
    weak var weakSelf = self
    SessionManagerClass.getSharedInstance()
      .request(BASE_URL + "/addContact/?key=" + self.apiKey, method: .post, parameters: params)
      .validate(getDefaultErrorHandler())
      .responseJSON { response in
        
        // check for successful request
        guard response.result.isSuccess else {
          if (response.response?.statusCode == 200) {
            handler(.failure(ApiError.createContactFailed(reason : "Failed with status 200")))
          } else {
            handler(.failure(ApiError.network(error: response.result.error)))
          }
          return
        }
        
        // check for response value
        guard let data = response.result.value as? [String], data.count == 2 else {
          handler(.failure(ApiError.createContactFailed(reason : "Incorrect response data")))
          return
        }
        
        // check for response contact id
        var newContactId: String? = nil
        
        if "Add" == data[1]{
          newContactId = data[0]
        } else if "Update" == data[1]{
          newContactId = data[0]
        }
        
        guard let contactId = newContactId else {
          handler(.failure(ApiError.createContactFailed(reason : "Failed to parse contact id")))
          return
        }
        
        // fetch contact model if requested
        
        if fetchContact {
          weakSelf?.getContact(contactId, contactClass: contactClass, handler: { (result) in
            let createContactResponse = ContactRequestResponse <ContactClass>(
              contactId: contactId,
              contact: result.value,
              fetchContactRequested: fetchContact
            )
            
            handler(.success(createContactResponse))
          })
        }
        else {
          let createContactResponse = ContactRequestResponse <ContactClass>(
            contactId: contactId,
            contact: nil,
            fetchContactRequested: fetchContact
          )
          
          handler(.success(createContactResponse))
        }
    }
  }
  
  /**
   Delete contact request.
   
   - parameters:
      - contactId: Contact ID.
   */
  open func deleteContact(
    contactId: String,
    handler : @escaping (_ result: Result<Any>) -> Void) {
    
    guard isOnline() else {
      handler(.failure(ApiError.networkConnectionError()))
      return
    }
    
    var params = [
      "ContactID": contactId,
      "key": self.apiKey
    ]
    
    weak var weakSelf = self
    SessionManagerClass.getSharedInstance()
      .request(BASE_URL + "/deleteContact/", method: .post, parameters: params)
      .validate(getDefaultErrorHandler())
      .responseObject { (dataResponse : DataResponse<ServerResponse>) in
        
        // check for successful request
        
        guard weakSelf?.handle(
          serverResponse: dataResponse,
          onFailError: ApiError.deleteContactFailed(reason: nil),
          serverErrorHandler: handler) ?? true else {
            return
        }
        
        handler(.success("success"))
    }
  }
  
  /**
   Update contact request.
   
   - Note: Current server API returns only *success* on update request. So in order to return contact model (if requested) - *getContact()* request is performed. There might be situations (bad network conditions, etc.) when contact is created but *getContact()* request failed, so only *success* will be available.
   
   - parameters:
      - request: Contact request.
      - contactClass: Contact class.
      - fetchContact: Contact model will be fetched by *getContact()*. Default is *false*.
   */
  open func updateContact <ContactClass: Mappable> (
    request : ContactRequest,
    contactClass: ContactClass.Type,
    fetchContact: Bool = false,
    handler: @escaping (_ result: Result<ContactRequestResponse <ContactClass>>) -> Void) {
    
    guard isOnline() else {
      handler(.failure(ApiError.networkConnectionError()))
      return
    }
    
    var params = Mapper().toJSON(request)
    params["Cell_Number"] = params["CellNumber"]
    params["Source"] = "iosapp"
    
    weak var weakSelf = self
    SessionManagerClass.getSharedInstance()
      .request(BASE_URL + "/addContact/?key=" + self.apiKey, method: .post, parameters: params)
      .validate(getDefaultErrorHandler())
      .responseJSON { response in
        
        // check for successful request
        guard response.result.isSuccess else {
          if (response.response?.statusCode == 200) {
            handler(.failure(ApiError.createContactFailed(reason : "Failed with status 200")))
          } else {
            handler(.failure(ApiError.network(error: response.result.error)))
          }
          return
        }
        
        // check for response value
        guard let data = response.result.value as? [String], data.count >= 1 else {
          handler(.failure(ApiError.updateContactFailed(reason : "Incorrect response data")))
          return
        }
        
        let contactId = data[0]
        
        // fetch contact model if requested
        
        if fetchContact {
          weakSelf?.getContact(contactId, contactClass: contactClass, handler: { (result) in
            let createContactResponse = ContactRequestResponse <ContactClass>(
              contactId: contactId,
              contact: result.value,
              fetchContactRequested: fetchContact
            )
            
            handler(.success(createContactResponse))
          })
        }
        else {
          let createContactResponse = ContactRequestResponse <ContactClass>(
            contactId: contactId,
            contact: nil,
            fetchContactRequested: fetchContact
          )
          
          handler(.success(createContactResponse))
        }
    }
  }
  
  open func fetchContactBy <ContactClass: Mappable> (
    fetchField: ContactFetchField,
    fieldValue: String,
    prospectTypes: [ProspectType],
    contactClass: ContactClass.Type,
    handler: @escaping (Result<ContactClass?>) -> Void
    ) {
    
    guard isOnline() else {
      handler(.failure(ApiError.networkConnectionError()))
      return
    }
    
    let params = [
      "type": fetchField.requestValue(),
      "key": self.apiKey,
      "q": fieldValue
    ]
    
    SessionManagerClass.getSharedInstance().request(BASE_URL + "/contacts", method: .get, parameters : params)
      .validate(getDefaultErrorHandler())
      .responseString {
        response in
        
        guard response.result.isSuccess else {
          if (response.response?.statusCode == 200) {
            handler(.failure(ApiError.fetchContactFailed(reason : "Failed with status 200")))
          } else {
            handler(.failure(ApiError.network(error: response.result.error)))
          }
          return
        }
        
        if response.result.value == Optional("null") {
          handler(.success(nil))
          return
        }
        
        let responseData = response.result.value?.data(using: String.Encoding.utf8)
        var jsonResponse : AnyObject? = nil
        
        do {
          jsonResponse = try JSONSerialization.jsonObject(with: responseData!, options: []) as? AnyObject
        } catch { }
        
        guard let data = jsonResponse as? [[String : Any]], data.count >= 1 else {
          handler(.success(nil))
          return
        }
        
        for contactData in data {
          var fieldEquals = false
          var prospectEquals = true
          
          
          // check for email equals
          guard let contactFieldValue = contactData[fetchField.fieldName()] as? String else {
            continue
          }
          
          if contactFieldValue == fieldValue {
            fieldEquals = true
            
            // check for required prospect type
            if let prospect = contactData["Prospect"] as? String {
              // we need initial 'false' if desired prospect type specified
              var contactProspectEquals = (prospectTypes.count == 0)
              
              for prospectType in prospectTypes {
                if prospectType == prospect {
                  contactProspectEquals = true
                  break
                }
              }
              
              prospectEquals = contactProspectEquals
            }
          }
          
          // if both email and prospect satusfies - contact exists
          if fieldEquals && prospectEquals {
            let map = Map(mappingType: .fromJSON, JSON: contactData)
            
            var contact = ContactClass(map: map)
            contact?.mapping(map: map)
            
            handler(.success(contact))
            return
          }
        }
        
        handler(.success(nil))
    }
  }
  
  
  //MARK: -
  
  open func createUser(_ email: String, password: String, contactId: String, handler: @escaping (Result<Any>) -> Void) {
    
    if (isOnline()) {
      let params = ["email": email,
                    "password": password,
                    "key": self.apiKey,
                    "contact": contactId
      ]
      
      SessionManagerClass.getSharedInstance().request(BASE_URL + "/addUser/", method: .post, parameters: params)
        .validate(getDefaultErrorHandler())
        .responseString {
          response in
          if (response.result.isSuccess) {
            if (response.result.value != nil) {
              if response.result.value == Optional("Success"){
                handler(.success("success"))
              } else {
                handler(.failure(ApiError.registrationFailed(reason : nil)))
              }
            } else {
              handler(.failure(ApiError.registrationFailed(reason : nil)))
            }
          } else {
            handler(.failure(ApiError.network(error: response.result.error)))
          }
      }
    } else {
      handler(.failure(ApiError.networkConnectionError()))
    }
  }
  
  open func authenticateUser(_ email: String, password: String, handler: @escaping (Result<AuthenticateResponse>) -> Void) {
    
    if (isOnline()) {
      let params = ["email": email,
                    "password": password,
                    "key": self.apiKey,
                    "time": "-1"
      ]
      SessionManagerClass.getSharedInstance().request(BASE_URL + "/authenticateUser/", method: .post, parameters: params)
        .validate(getErrorHandler("Login failed. Please try again."))
        .responseString { response in
          if (response.result.isSuccess) {
            let responseData = response.result.value?.data(using: String.Encoding.utf8)
            var jsonResponse : AnyObject? = nil
            
            do {
              jsonResponse = try JSONSerialization.jsonObject(with: responseData!, options: []) as? AnyObject
            } catch { }
            guard let data = jsonResponse as? [AnyObject], data.count == 2 else {
              handler(.failure(ApiError.authenticatFailed(reason: response.result.value)))
              return
            }
            let authResponse = AuthenticateResponse()
            authResponse.contactId = String(data[0] as! Int)
            authResponse.token = data[1] as? String
            handler(.success(authResponse))
          } else {
            handler(.failure(ApiError.network(error: response.result.error)))
          }
      }
    } else {
      handler(.failure(ApiError.networkConnectionError()))
    }
  }
  
  open func checkUserSession(_ contactId: String, token : String, handler: @escaping (Result<Any>) -> Void) {
    
    if (isOnline()) {
      let params = ["contact": contactId,
                    "token" : token]
      SessionManagerClass.getSharedInstance().request(BASE_URL + "/checkSession/", method: .post, parameters: params)
        .validate(getDefaultErrorHandler())
        .responseString {
          response in
          if (response.result.isSuccess) {
            if response.result.value == Optional("valid"){
              handler(.success("valid"))
            } else {
              handler(.failure(ApiError.unknown()))
            }
          } else {
            handler(.failure(ApiError.network(error: response.result.error)))
          }
      }
    } else {
      handler(.failure(ApiError.networkConnectionError()))
    }
  }
  
  open func resetPassword(_ email: String, handler: @escaping (Result<String?>) -> Void) {
    
    if (isOnline()) {
      let params = ["user": email]
      SessionManagerClass.getSharedInstance().request(BASE_URL + "/bsdLoyalty/ResetPassword.php?key=" + self.apiKey, method: .post, parameters: params)
        .validate(getDefaultErrorHandler())
        .responseString {
          response in
          if (response.result.isSuccess) {
            if (response.result.value?.characters.count)! > 0 {
              handler(.failure(ApiError.resetPasswordError(reason: response.result.value)))
            } else {
              handler(.success(response.result.value))
            }
          } else {
            handler(.failure(ApiError.network(error: response.result.error)))
          }
      }
    } else {
      handler(.failure(ApiError.networkConnectionError()))
    }
  }
  
  open func logoutUser(_ contactId: String, token : String, handler: @escaping (Result<Any>) -> Void) {
    if (isOnline()) {
      let params = ["contact": contactId,
                    "token" : token]
      SessionManagerClass.getSharedInstance().request(BASE_URL + "/logoutUser/", method: .post, parameters: params)
        .validate(getDefaultErrorHandler())
        .responseString {
          response in
          if (response.result.isSuccess) {
            if response.result.value == Optional("error") ||
              response.result.value == Optional("logged out"){
              handler(.success("logged out"))
            } else {
              handler(.failure(ApiError.unknown()))
            }
          } else {
            handler(.failure(ApiError.network(error: response.result.error)))
          }
      }
    } else {
      handler(.failure(ApiError.networkConnectionError()))
    }
  }
  
  open func getContact <ContactClass: Mappable> (_ contactId: String, contactClass: ContactClass.Type, handler: @escaping (Result<ContactClass>) -> Void) {
    if (isOnline()) {
      let params = [
        "key": self.apiKey,
        "q": contactId
      ]
      
      let map = Map(mappingType: .fromJSON, JSON: ["24": "23"])
      var tmp: ContactClass? = ContactClass(map: map)
      tmp?.mapping(map: map)
      print(tmp.debugDescription)
      
      SessionManagerClass.getSharedInstance().request(BASE_URL + "/contacts", method: .get, parameters: params)
        .validate(getDefaultErrorHandler())
        .responseArray {
          (response : DataResponse<[ContactClass]>) in
          if (response.result.isSuccess) {
            if let data = response.result.value, data.count == 1 {
              handler(.success(data[0]))
            } else {
              handler(.failure(ApiError.unknown()))
            }
          } else {
            handler(.failure(ApiError.network(error: response.result.error)))
          }
      }
    } else {
      handler(.failure(ApiError.networkConnectionError()))
    }
  }
  
  open func updatePassword(_ password : String, contactId : String, token: String, handler : @escaping (Result<Any>)->Void){
    
    if (isOnline()) {
      let params = ["token": token,
                    "password": password,
                    "key": self.apiKey,
                    "contact": contactId
      ]
      SessionManagerClass.getSharedInstance().request(BASE_URL + "/bsdLoyalty/?function=updatePassword", method: .post, parameters: params)
        .validate(getDefaultErrorHandler())
        .responseString {
          response in
          if (response.result.isSuccess) {
            if (response.result.value != nil) {
              if response.result.value == Optional("success"){
                handler(.success("success"))
              } else {
                handler(.failure(ApiError.dataSerialization(reason : "No data available!")))
              }
            } else {
              handler(.failure(ApiError.dataSerialization(reason : "No data available!")))
            }
          } else {
            handler(.failure(ApiError.network(error: response.result.error)))
          }
      }
    } else {
      handler(.failure(ApiError.networkConnectionError()))
    }
  }
  
  open func getUserOffers <CouponClass: BECoupon> (_ contactId : String, couponClass: CouponClass.Type, handler : @escaping (Result<[BECoupon]>) -> Void){
    
    if (isOnline()) {
      let params = [
        "key": self.apiKey,
        "Card": contactId
      ]
      
      weak var weakSelf = self
      SessionManagerClass.getSharedInstance().request(BASE_URL + "/bsdLoyalty/getOffersM.php", method: .get, parameters: params)
        .validate(getDefaultErrorHandler())
        .responseObject {
          (response : DataResponse<CouponResponse<CouponClass>>) in
          if weakSelf?.dataGenerator != nil {
            var coupons: [BECoupon]? = weakSelf?.dataGenerator!.getUserOffers().coupons
            if coupons == nil {
              coupons = []
            }
            handler(.success(coupons!))
          } else {
            if (response.result.isSuccess) {
              if let data = response.result.value {
                let coupons: [BECoupon] = (data.coupons != nil) ? data.coupons! : []
                handler(.success(coupons))
              } else {
                handler(.failure(ApiError.unknown()))
              }
            } else if response.response?.statusCode == 200 {
              handler(.success([]))
            } else {
              handler(.failure(ApiError.network(error: response.result.error)))
            }
          }
      }
    } else {
      handler(.failure(ApiError.networkConnectionError()))
    }
  }
  
  open func getProgress(_ contactId: String, handler: @escaping (Result<Double>) -> Void) {
    
    if (isOnline()) {
      let params = [
        "contact": contactId
      ]
      
      weak var weakSelf = self
      SessionManagerClass.getSharedInstance().request(BASE_URL + "/bsdLoyalty/getProgress.php?key=" + self.apiKey, method: .post, parameters: params)
        .validate(getDefaultErrorHandler())
        .responseObject {
          (response : DataResponse<RewardsCountResponse>) in
          if weakSelf?.dataGenerator != nil {
            var count: Double? = weakSelf?.dataGenerator!.getUserProgress().getCount()
            if count == nil {
              count = 0
            }
            handler(.success(count!))
          } else {
            if (response.result.isSuccess) {
              if let data = response.result.value {
                handler(.success(data.getCount()))
              } else {
                handler(.failure(ApiError.unknown()))
              }
            } else if response.response?.statusCode == 200 {
              handler(.failure(ApiError.unknown()))
            } else {
              handler(.failure(ApiError.network(error: response.result.error)))
            }
          }
      }
    } else {
      handler(.failure(ApiError.networkConnectionError()))
    }
  }
  
  open func getGiftCards <GiftCardClass: BEGiftCard> (_ contactId: String, token : String, giftCardClass: GiftCardClass.Type, handler : @escaping (Result<[BEGiftCard]>) -> Void) {
    
    if (isOnline()) {
      let params = [
        "contactId" : contactId,
        "token" : token
      ]
      
      weak var weakSelf = self
      SessionManagerClass.getSharedInstance().request(BASE_URL + "/bsdPayment/list?key=" + self.apiKey, method: .get, parameters: params)
        .validate(getDefaultErrorHandler())
        .responseObject {
          (response : DataResponse<GCResponse<GiftCardClass>>) in
          if weakSelf?.dataGenerator != nil {
            var cards = weakSelf?.dataGenerator!.getUserGiftCards().getCards()
            if cards == nil {
              cards = []
            }
            handler(.success(cards!))
          } else {
            if (response.result.isSuccess) {
              if let data = response.result.value {
                handler(.success(data.getCards() != nil ? data.getCards()! : []))
              } else {
                handler(.failure(ApiError.unknown()))
              }
            } else if response.response?.statusCode == 200 {
              handler(.failure(ApiError.unknown()))
            } else {
              handler(.failure(ApiError.network(error: response.result.error)))
            }
          }
      }
    } else {
      handler(.failure(ApiError.networkConnectionError()))
    }
  }
  
  open func getGiftCardBalance(_ contactId: String, token : String, number : String, handler : @escaping (Result<String?>) -> Void){
    
    if (isOnline()) {
      let params = [
        "contactId" : contactId,
        "token" : token,
        "cardNumber" : number
      ]
      
      weak var weakSelf = self
      SessionManagerClass.getSharedInstance().request(BASE_URL + "/bsdPayment/inquiry?key=" + self.apiKey, method: .get, parameters: params)
        .validate(getDefaultErrorHandler())
        .responseObject {
          (response : DataResponse<GCBResponse>) in
          if weakSelf?.dataGenerator != nil {
            handler(.success(weakSelf?.dataGenerator!.getUserGiftCardBalance().getCardBalance()))
          } else {
            if (response.result.isSuccess) {
              if let data = response.result.value {
                handler(.success(data.getCardBalance()))
              } else {
                handler(.failure(ApiError.unknown()))
              }
            } else if response.response?.statusCode == 200 {
              handler(.failure(ApiError.unknown()))
            }
            else {
              handler(.failure(ApiError.network(error: response.result.error)))
            }
          }
      }
    } else {
      handler(.failure(ApiError.networkConnectionError()))
    }
  }
  
  open func startPayment(_ contactId: String, token: String, paymentId: String?, coupons: String, handler : @escaping (Result<String?>)->Void){
    
    if (isOnline()) {
      var params = [
        "contactId" : contactId,
        "token" : token,
        "key" : self.apiKey
      ]
      if paymentId != nil{
        params["paymentId"] = paymentId!
      }
      if coupons.characters.count > 0{
        params["coupons"] = coupons
      } else {
        params["coupons"] = ""
      }
      
      weak var weakSelf = self
      SessionManagerClass.getSharedInstance().request(BASE_URL + "/bsdPayment/startPayment", method: .get, parameters: params)
        .validate(getDefaultErrorHandler())
        .responseObject {
          (response : DataResponse<PaymentResponse>) in
          if weakSelf?.dataGenerator != nil {
            handler(.success(weakSelf?.dataGenerator!.getUserPayment().token))
          } else {
            if (response.result.isSuccess) {
              if let data = response.result.value {
                handler(.success(data.token))
              } else {
                handler(.failure(ApiError.unknown()))
              }
            } else if response.response?.statusCode == 200 {
              handler(.failure(ApiError.unknown()))
            }
            else {
              handler(.failure(ApiError.network(error: response.result.error)))
            }
          }
      }
    } else {
      handler(.failure(ApiError.networkConnectionError()))
    }
  }
  
  //MARK: - Locations
  
  open func getStoresAtLocation <StoreClass: BEStore> (_ longitude: String?, latitude: String?, token : String?, storeClass: StoreClass.Type, handler : @escaping (Result<[BEStore]?>) -> Void) {
    
    if (isOnline()) {
      
      var params = Dictionary<String, String>()
      if longitude != nil {
        params["long"] = longitude!
      }
      
      if latitude != nil {
        params["lat"] = latitude!
      }
      
      if (token != nil) {
        params["token"] = token!
      }
      
      SessionManagerClass.getSharedInstance().request(BASE_URL + "/bsdStores/locate?key=" + self.apiKey, method: .get, parameters: params)
        .validate(getDefaultErrorHandler())
        .responseObject {
          (response : DataResponse<StoresResponse<StoreClass>>) in
          
          if (response.result.isSuccess) {
            if let data = response.result.value {
              if (data.failed()) {
                handler(.failure(ApiError.dataSerialization(reason: "Bad request!")))
              } else {
                handler(.success(data.getStores()))
              }
            } else {
              handler(.failure(ApiError.unknown()))
            }
          } else if response.response?.statusCode == 200 {
            handler(.success([]))
          } else {
            handler(.failure(ApiError.network(error: response.result.error)))
          }
      }
    } else {
      handler(.failure(ApiError.networkConnectionError()))
    }
  }
  
  
  //MARK: - Push Notifications
  
  public func pushNotificationEnroll(_ contactId: String, deviceToken: String, handler : @escaping (Result<Any?>)->Void) {
    
    guard isOnline() else {
      handler(.failure(ApiError.networkConnectionError()))
      return
    }
    
    let params = [
      "contact_id" : contactId,
      "deviceToken" : deviceToken,
      "key" : self.apiKey,
      "platform" : "iOS"
    ]
    
    weak var weakSelf = self
    SessionManagerClass.getSharedInstance().request(BASE_URL + "/pushNotificationEnroll", method: .get, parameters: params)
      .validate(getDefaultErrorHandler())
      .responseObject { (response : DataResponse<PushNotificationResponse>) in
        
        if weakSelf?.dataGenerator != nil {
          handler(.success("success"))
          return
        }
        
        if (response.result.isSuccess) {
          if let result = response.result.value {
            if (result.failed()) {
              handler(.failure(ApiError.dataSerialization(reason: "Bad request!")))
            } else {
              handler(.success("success"))
            }
          } else {
            handler(.failure(ApiError.unknown()))
          }
        } else if response.response?.statusCode == 200 {
          handler(.success("success"))
        } else {
          handler(.failure(ApiError.network(error: response.result.error)))
        }
    }
  }
  
  public func pushNotificationDelete(_ contactId: String, handler : @escaping (Result<Any>)->Void) {
    
    guard isOnline() else {
      handler(.failure(ApiError.networkConnectionError()))
      return
    }
    
    let params = [
      "contact_id" : contactId,
      "key" : self.apiKey
    ]
    
    weak var weakSelf = self
    SessionManagerClass.getSharedInstance().request(BASE_URL + "/pushNotificationDelete", method: .get, parameters: params)
      .validate(getDefaultErrorHandler())
      .responseObject { (response : DataResponse<PushNotificationResponse>) in
        
        if weakSelf?.dataGenerator != nil {
          handler(.success("success"))
          return
        }
        
        if (response.result.isSuccess) {
          if let result = response.result.value {
            if (result.failed()) {
              handler(.failure(ApiError.dataSerialization(reason: "Bad request!")))
            } else {
              handler(.success("success"))
            }
          } else {
            handler(.failure(ApiError.unknown()))
          }
        } else if response.response?.statusCode == 200 {
          handler(.success("success"))
        } else {
          handler(.failure(ApiError.network(error: response.result.error)))
        }
    }
  }
  
  public func pushNotificationGetMessages(_ contactId: String, maxResults: Int, handler : @escaping (Result<[BEPushNotificationMessage]>) -> Void) {
    
    guard isOnline() else {
      handler(.failure(ApiError.networkConnectionError()))
      return
    }
    
    let params: [String: Any] = [
      "contactId" : contactId,
      "key" : self.apiKey,
      "maxResults": NSNumber(value: maxResults)
    ]
    
    weak var weakSelf = self
    SessionManagerClass.getSharedInstance().request(BASE_URL + "/pushNotification/getMessages", method: .get, parameters: params)
      .validate(getDefaultErrorHandler())
      .responseArray {
        (response : DataResponse <[BEPushNotificationMessage]>) in
        
        if weakSelf?.dataGenerator != nil {
          handler(.success([]))
          return
        }
        
        if (response.result.isSuccess) {
          if let result = response.result.value {
            handler(.success(result))
          } else {
            handler(.failure(ApiError.unknown()))
          }
        } else if response.response?.statusCode == 200 {
          handler(.success([]))
        } else {
          handler(.failure(ApiError.network(error: response.result.error)))
        }
    }
  }
  
  public func pushNotificationUpdateStatus(_ messageId: String, status: PushNotificationStatus, handler : @escaping (Result<Any>) -> Void) {
    
    guard isOnline() else {
      handler(.failure(ApiError.networkConnectionError()))
      return
    }
    
    let params = [
      "message_id" : messageId,
      "key" : self.apiKey,
      "action": status.rawValue
    ]
    
    weak var weakSelf = self
    SessionManagerClass.getSharedInstance().request(BASE_URL + "/pushNotification/updateStatus", method: .get, parameters: params)
      .validate(getDefaultErrorHandler())
      .responseObject {
        (response : DataResponse<PushNotificationResponse>) in
        
        if weakSelf?.dataGenerator != nil {
          handler(.success("success"))
          return
        }
        
        if (response.result.isSuccess) {
          if let result = response.result.value {
            handler(.success(result))
          } else {
            handler(.failure(ApiError.unknown()))
          }
        } else if response.response?.statusCode == 200 {
          handler(.success("success"))
        } else {
          handler(.failure(ApiError.network(error: response.result.error)))
        }
    }
  }
  
  public func pushNotificationGetMessageById(_ messageId: String, handler : @escaping (Result<BEPushNotificationMessage>) -> Void) {
    
    guard isOnline() else {
      handler(.failure(ApiError.networkConnectionError()))
      return
    }
    
    let params = [
      "msg_id" : messageId,
      "key" : self.apiKey
    ]
    
    weak var weakSelf = self
    SessionManagerClass.getSharedInstance().request(BASE_URL + "/pushNotification/getMessageById", method: .get, parameters: params)
      .validate(getDefaultErrorHandler())
      .responseObject {
        (response : DataResponse<BEPushNotificationMessage>) in
        
        if weakSelf?.dataGenerator != nil {
          handler(.failure(ApiError.unknown()))
          return
        }
        
        if (response.result.isSuccess) {
          if let result = response.result.value {
            handler(.success(result))
          } else {
            handler(.failure(ApiError.unknown()))
          }
        } else if response.response?.statusCode == 200 {
          handler(.failure(ApiError.unknown()))
        } else {
          handler(.failure(ApiError.network(error: response.result.error)))
        }
    }
  }
  
  
  //MARK: - Tracking
  
  func trackTransaction(_ contactId: String, userName: String, transactionData: AnyObject, handler: @escaping (Result<Any>)->Void) {
    
    if (isOnline()) {
      let params = [
        "contactId" : contactId,
        "userName" : userName,
        "key" : self.apiKey,
        "details" : transactionData
        ] as [String : Any]
      
      weak var weakSelf = self
      SessionManagerClass.getSharedInstance().request(BASE_URL + "/bsdTransactions/add/", method: .get, parameters: params)
        .validate(getDefaultErrorHandler())
        .responseObject {
          (response : DataResponse<TrackTransactionResponse>) in
          if weakSelf?.dataGenerator != nil {
            handler(.success("success"))
          } else {
            if (response.result.isSuccess) {
              if let result = response.result.value {
                handler(.success(result))
              } else {
                handler(.failure(ApiError.unknown()))
              }
            } else if response.response?.statusCode == 200 {
              handler(.success("success"))
            } else {
              handler(.failure(ApiError.network(error: response.result.error)))
            }
          }
      }
    } else {
      handler(.failure(ApiError.networkConnectionError()))
    }
  }
  
  
  //MARK: - Private
  
  fileprivate func getErrorHandler(_ defaultMessage: String) -> DataRequest.Validation {
    let validation : DataRequest.Validation = { (urlRequest, ulrResponse, data) -> Request.ValidationResult in
      
      let acceptableStatusCodes: Range<Int> = 200..<300
      if acceptableStatusCodes.contains(ulrResponse.statusCode) {
        
        return .success
      } else {
        
        var failureReason = defaultMessage
        
        if (ulrResponse.statusCode == 400) {
          //TODO: Handle custom error
          failureReason = "Response status code was unacceptable: \(ulrResponse.statusCode)"
        } else if (ulrResponse.statusCode == 404) {
          
        }
        
        //TODO: Create corresponding error
//        let error = NSError(
//          domain: Error.domain,
//          code: Error.Code.StatusCodeValidationFailed.rawValue,
//          userInfo: [
//            NSLocalizedFailureReasonErrorKey: failureReason,
//            Error.UserInfoKeys.StatusCode: ulrResponse.statusCode
//          ]
//        )
        
        let error = ApiError.unacceptableStatusCodeError(reason: failureReason, statusCode: ulrResponse.statusCode)
        
        return .failure(error)
      }
    }
    
    return validation
  }
  
  fileprivate func getDefaultErrorHandler() -> DataRequest.Validation {
    return getErrorHandler("Got error while processing your request.")
  }
  
  fileprivate func handle(
    serverResponse: DataResponse<ServerResponse>,
    onFailError: ApiError,
    serverErrorHandler: (_ result: Result<Any>) -> Void) -> Bool {
    
    guard serverResponse.result.isSuccess else {
      serverErrorHandler(.failure(ApiError.network(error: serverResponse.result.error)))
      return false
    }
    
    guard let response = serverResponse.result.value else {
      serverErrorHandler(.failure(ApiError.dataSerialization(reason: "Failed to parse response")))
      return false
    }
    
    guard response.isSuccess() else {
      serverErrorHandler(.failure(onFailError))
      return false
    }
    
    return true
  }
}

open class HTTPAlamofireManager: Alamofire.SessionManager {
  open class func getSharedInstance() -> Alamofire.SessionManager {
    return Alamofire.SessionManager.default
  }
  
  open class func defaultSessionConfiguration() -> URLSessionConfiguration {
    return URLSessionConfiguration.default
  }
}

open class HTTPTimberjackManager: HTTPAlamofireManager {
  static internal let shared: Alamofire.SessionManager = {
    let configuration = HTTPTimberjackManager.defaultSessionConfiguration()
    let manager = HTTPTimberjackManager(configuration: configuration)
    return manager
  }()
  
  open override class func getSharedInstance() -> Alamofire.SessionManager {
    return shared
  }
  
  open override class func defaultSessionConfiguration() -> URLSessionConfiguration {
    return Timberjack.defaultSessionConfiguration()
  }
}

public enum ProspectType: String {
  case Loyalty = "loyalty"
  case eClub = "eclub"
}

func ==(left: ProspectType, right: String) -> Bool {
  let strValue = left.rawValue
  
  return strValue.caseInsensitiveCompare(right) == ComparisonResult.orderedSame
}

public enum ContactFetchField: String {
  case phoneNumber = "cell_number"
  case email = "email"
  case fKey = "fkey"
  
  public func requestValue() -> String {
    return self.rawValue
  }
  
  public func fieldName() -> String {
    return self.rawValue
  }
}
