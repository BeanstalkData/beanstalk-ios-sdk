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
import Reachability

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

fileprivate let kDefaultBeanstalkUrl = "proc.beanstalkdata.com"

/**
 Contains majority of API calls. It is utilized by CoreService. Can be used directly.
 */
open class ApiCommunication <SessionManagerClass: HTTPTimberjackManager>: BERespondersHolder <BEApiResponder> {
  
  fileprivate let BASE_URL: String
  fileprivate let apiKey: String
  fileprivate let apiUsername: String?
  
  internal let reachability: Reachability
  
  internal var dataGenerator: MockDataGenerator?
  
  internal let transactionDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    return dateFormatter
  }()
  
  public required init(apiKey: String, apiUsername: String? = nil, beanstalkUrl: String = kDefaultBeanstalkUrl) {
    self.apiKey = apiKey
    self.apiUsername = apiUsername
    self.BASE_URL = "https://" + beanstalkUrl
    
    self.reachability = Reachability(hostname: beanstalkUrl)!
    
    super.init()
    
    reachability.whenReachable = {[weak self] reachability in
      print("Reachable via \(reachability.connection.description)")
      self?.notifyNetworkReachabilityObservers()
    }
    reachability.whenUnreachable = {[weak self] _ in
      print("Not reachable")
      self?.notifyNetworkReachabilityObservers()
    }
    
    do {
      try reachability.startNotifier()
    } catch {
      print("Unable to start notifier")
    }
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.notifyNetworkReachabilityObservers),
      name: NSNotification.Name.UIApplicationWillEnterForeground,
      object: nil
    )
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc fileprivate func notifyNetworkReachabilityObservers() {
    let isOnline = self.isOnline()
    self.enumerateObservers { (i) in
      i.networkStatusChanged?(isOnline)
    }
  }
  
  open func isOnline() -> Bool {
    return self.reachability.connection != .none
  }
  
  open func checkContactsByEmailExisted(_ email: String, prospectTypes: [ProspectType], handler: @escaping (Result<Bool>) -> Void) {
    if (isOnline()) {
      let params = ["type": "email",
                    "key": self.apiKey,
                    "q": email
      ]
      SessionManagerClass.getSharedInstance().request(BASE_URL + "/contacts/", method: .get, parameters : params)
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
                jsonResponse = try JSONSerialization.jsonObject(with: responseData!, options: []) as AnyObject
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
      SessionManagerClass.getSharedInstance().request(BASE_URL + "/contacts/", method: .get, parameters : params)
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
                jsonResponse = try JSONSerialization.jsonObject(with: responseData!, options: []) as AnyObject
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
  
  /**
   Utility call to check account is configured correctly after createLoyaltyAccount is performed.
   Should be called after successful registerLoyaltyAccount request.
   
   - Parameter contactId: Contact Id.
   - Parameter handler: Completion handler.
   - Parameter result: Request result model.
   */
  open func checkLoyaltyAccount(
    contactId: String,
    handler: @escaping (_ result: Result<String>) -> Void) {
    
    guard isOnline() else {
      handler(.failure(ApiError.networkConnectionError()))
      return
    }
    
    let params = [
      "contact": contactId,
      "cardNumber": contactId,
      "key": self.apiKey,
      "function": "addNewCard"
    ]
    
    SessionManagerClass.getSharedInstance().request(BASE_URL + "/bsdLoyalty/maintainLoyaltyCards.php", method: .get, parameters: params)
      .validate(getDefaultErrorHandler())
      .responseString { (dataResponse) in
        
        guard dataResponse.result.isSuccess else {
          handler(.failure(ApiError.unknown()))
          return
        }
        
        guard let responseString = dataResponse.value else {
          handler(.failure(ApiError.unknown()))
          return
        }
        
        if responseString == "card added" {
          handler(.success(responseString))
        } else {
          handler(.failure(ApiError.unknown()))
        }
    }
  }
  
  
  //MARK: - Contact
  
  /**
   Create contact request.
   
   - Note: Current server API returns only *contactId* on create request. So in order to return contact model (if requested) - *getContact()* request is performed. There might be situations (bad network conditions, etc.) when contact is created but *getContact()* request failed, so only *contactId* will be available.
   
   - Parameter request: Contact request.
   - Parameter contactClass: Contact class.
   - Parameter fetchContact: Contact model will be fetched by *getContact()*. Default is *false*.
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
        
        print(data[1])
        
        if "Add" == data[1] {
          newContactId = data[0]
        }
        
        if "Update" == data[1] {
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
   
   - Parameter contactId: Contact ID.
   */
  open func deleteContact(
    contactId: String,
    handler: @escaping (_ result: Result<Any>) -> Void) {
    
    guard isOnline() else {
      handler(.failure(ApiError.networkConnectionError()))
      return
    }
    
    let params = [
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
          dataResponse: dataResponse,
          onFailError: { (reason) in
            return ApiError.deleteContactFailed(reason: reason)
        },
          serverErrorHandler: handler) ?? true else {
            return
        }
        
        handler(.success("success"))
    }
  }
  
  /**
   Update contact request.
   
   - Note: Current server API returns only *success* on update request. So in order to return contact model (if requested) - *getContact()* request is performed. There might be situations (bad network conditions, etc.) when contact is created but *getContact()* request failed, so only *success* will be available.
   
   - Parameter request: Contact request.
   - Parameter contactClass: Contact class.
   - Parameter fetchContact: Contact model will be fetched by *getContact()*. Default is *false*.
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
  
  /**
   Sends a contact’s Geo Location data to server.
   
   - Parameter contactId: Contact ID.
   - Parameter latitude: Latitude string.
   - Parameter longitude: Longitude string.
   - Parameter handler: Completion handler.
   - Parameter result: Request result model.
   */
  
  open func relocateContact(
    contactId: String,
    latitude: String,
    longitude: String,
    handler: @escaping (_ result: Result<Bool>) -> Void) {
    
    guard isOnline() else {
      handler(.failure(ApiError.networkConnectionError()))
      return
    }
    
    let params = [
      "contactId" : contactId,
      "key" : self.apiKey,
      "latitude" : latitude,
      "longitude" : longitude
    ]
    
    weak var weakSelf = self
    SessionManagerClass.getSharedInstance().request(BASE_URL + "/bsdContact/relocate.php", method: .post, parameters: params)
      .validate(getDefaultErrorHandler())
      .responseJSON { (response) in
        
        if weakSelf?.dataGenerator != nil {
          handler(.success(true))
          return
        }
        
        guard response.result.isSuccess else {
          handler(.failure(ApiError.network(error: response.result.error)))
          return
        }
        
        guard let result = response.result.value as? [String: Any] else {
          handler(.failure(ApiError.dataSerialization(reason: Localized(key: BELocKey.error_bad_request_title))))
          return
        }
        
        guard let success = result["Success"] as? String else {
          handler(.failure(ApiError.unknown()))
          return
        }
        
        handler(.success(success == "true"))
    }
  }
  
  /**
   Retrieves image data from Beanstalk.
   
   - Parameter contactId: Contact ID.
   - Parameter handler: Completion handler.
   - Parameter result: Request result model.
   */
  
  open func getContactGeoAssets(
    contactId: String,
    handler: @escaping (_ result: Result<ContactGeoAssetsResponse>) -> Void) {
    
    guard isOnline() else {
      handler(.failure(ApiError.networkConnectionError()))
      return
    }
    
    let params = [
      "contactId" : contactId,
      "key" : self.apiKey
    ]
    
    weak var weakSelf = self
    SessionManagerClass.getSharedInstance().request(BASE_URL + "/bsdContact/geoAssets.php", method: .get, parameters: params)
      .validate(getDefaultErrorHandler())
      .responseObject { (dataResponse : DataResponse<ContactGeoAssetsResponse>) in
        
        if weakSelf?.dataGenerator != nil {
          handler(.failure(ApiError.unknown()))
          return
        }
        
        guard dataResponse.result.isSuccess else {
          handler(.failure(ApiError.network(error: dataResponse.result.error)))
          return
        }
        
        guard let response = dataResponse.value else {
          handler(.failure(ApiError.dataSerialization(reason: Localized(key: BELocKey.error_bad_request_title))))
          return
        }
        
        handler(.success(response))
    }
  }
  
  /**
   Fetches contact by specific field. Completion handler returns result object with contact (if found), no contact (if no satisfied contacts) or error (if occur).
   
   - Parameter fetchField: Field by which fetch will be performed.
   - Parameter fieldValue: Fetch field value, i.e. query string.
   - Parameter caseSensitive: Indicates whether is field values should be compared in case-sensitive manner. Default is _false_.
   - Parameter prospectTypes: Prospect types list. Contact with specified prospect value will be evaluated only. If empty, prospect will be ignored. Default is *empty*.
   - Parameter contactClass: Contact model class.
   - Parameter handler: Completion handler.
   - Parameter result: Result with contact model, no contact model or error if occur.
   */
  
  open func fetchContactBy <ContactClass: Mappable> (
    fetchField: ContactFetchField,
    fieldValue: String,
    caseSensitive: Bool = false,
    prospectTypes: [ProspectType] = [],
    contactClass: ContactClass.Type,
    handler: @escaping (_ result: Result<ContactClass?>) -> Void
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
    
    SessionManagerClass.getSharedInstance().request(BASE_URL + "/contacts/", method: .get, parameters : params)
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
          jsonResponse = try JSONSerialization.jsonObject(with: responseData!, options: []) as AnyObject
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
          
          var isValuesEqual = false
          
          if caseSensitive {
            isValuesEqual = contactFieldValue == fieldValue
          } else {
            isValuesEqual = contactFieldValue.compare(
              fieldValue,
              options: String.CompareOptions.caseInsensitive,
              range: nil,
              locale: nil
              ) == ComparisonResult.orderedSame
          }
          
          if isValuesEqual {
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
  
  /**
   Check Facebook Account existing
   
   - Parameter facebookId: Facebook ID.
   - Parameter facebookToken: Facebook token.
   - Parameter handler: Completion handler.
   - Parameter result: Response with account ID and account token.
   */
  
  open func checkFacebookAccountExisted(facebookId: String, facebookToken: String, handler: @escaping (Result<CheckContactResponse>) -> Void) {
    guard isOnline() else {
      handler(.failure(ApiError.networkConnectionError()))
      return
    }
    
    let params = ["fb": facebookId,
                  "fbtoken": facebookToken,
                  "key": self.apiKey,
                  "function": "checkFacebook"
    ]
    
    SessionManagerClass.getSharedInstance().request(BASE_URL + "/bsdLoyalty/", method: .post, parameters: params)
      .validate(getDefaultErrorHandler())
      .responseString { response in
        guard response.result.isSuccess else {
          handler(.failure(ApiError.network(error: response.result.error)))
          return
        }
        
        guard response.result.value != nil else {
          handler(.failure(ApiError.registrationFailed(reason : nil)))
          return
        }
        
        guard let responseData = response.result.value?.data(using: String.Encoding.utf8) else {
          handler(.failure(ApiError.authenticationFailed(reason: response.result.value)))
          return
        }
        
        let jsonResponse = try? JSONSerialization.jsonObject(with: responseData, options: []) as AnyObject
        
        guard let data = jsonResponse as? [AnyObject], data.count == 2 else {
          handler(.failure(ApiError.authenticationFailed(reason: response.result.value)))
          return
        }
        
        let response = CheckContactResponse(contactId: String(describing: data[0]),
                                            contactToken: String(describing: data[1]))
        handler(.success(response))
    }
  }
  
  /**
   Check Google Account existing
   
   - Parameter googleId: Google ID.
   - Parameter googleToken: Gooogle token.
   - Parameter handler: Completion handler.
   - Parameter result: Response with account ID and account token.
   */
  open func checkGoogleAccountExisted(googleId: String, googleToken: String, handler: @escaping (Result<CheckContactResponse>) -> Void) {
    guard isOnline() else {
      handler(.failure(ApiError.networkConnectionError()))
      return
    }
    
    let params = ["GoogleId": googleId,
                  "GoogleToken": googleToken,
                  "key": self.apiKey,
                  "function": "checkGoogle"
    ]
    
    SessionManagerClass.getSharedInstance().request(BASE_URL + "/bsdLoyalty/", method: .post, parameters: params)
      .validate(getDefaultErrorHandler())
      .responseString { response in
        
        guard response.result.isSuccess else {
          handler(.failure(ApiError.network(error: response.result.error)))
          return
        }
        
        guard response.result.value != nil else {
          handler(.failure(ApiError.registrationFailed(reason : nil)))
          return
        }
        
        guard let responseData = response.result.value?.data(using: String.Encoding.utf8) else {
          handler(.failure(ApiError.authenticationFailed(reason: response.result.value)))
          return
        }
        
        let jsonResponse = try? JSONSerialization.jsonObject(with: responseData, options: []) as AnyObject
        
        guard let data = jsonResponse as? [AnyObject], data.count == 2 else {
          handler(.failure(ApiError.authenticationFailed(reason: response.result.value)))
          return
        }
        
        let response = CheckContactResponse(contactId: String(describing: data[0]),
                                            contactToken: String(describing: data[1]))
        handler(.success(response))
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
              jsonResponse = try JSONSerialization.jsonObject(with: responseData!, options: []) as AnyObject
            } catch { }
            guard let data = jsonResponse as? [AnyObject], data.count == 2 else {
              handler(.failure(ApiError.authenticationFailed(reason: response.result.value)))
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
      
      SessionManagerClass.getSharedInstance().request(BASE_URL + "/contacts/", method: .get, parameters: params)
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
  
  open func updatePassword(_ password : String, contactId : String, token: String, handler: @escaping (Result<Any>)->Void){
    
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
  
  open func getUserOffers <CouponClass: BECoupon> (_ contactId : String, couponClass: CouponClass.Type, handler: @escaping (Result<[BECouponProtocol]>) -> Void){
    
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
            var coupons: [BECouponProtocol]? = weakSelf?.dataGenerator!.getUserOffers().coupons
            if coupons == nil {
              coupons = []
            }
            handler(.success(coupons!))
          } else {
            if (response.result.isSuccess) {
              if let data = response.result.value {
                let coupons: [BECouponProtocol] = (data.coupons != nil) ? data.coupons! : []
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
  
  open func getGiftCards <GiftCardClass: BEGiftCard> (_ contactId: String, token : String, giftCardClass: GiftCardClass.Type, handler: @escaping (Result<[BEGiftCard]>) -> Void) {
    
    if (isOnline()) {
      let params = [
        "contactId" : contactId,
        "token" : token
      ]
      
      weak var weakSelf = self
      SessionManagerClass.getSharedInstance().request(BASE_URL + "/bsdPayment/list/?key=" + self.apiKey, method: .get, parameters: params)
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
  
  open func getGiftCardBalance(_ contactId: String, token : String, number : String, handler: @escaping (Result<String?>) -> Void){
    
    if (isOnline()) {
      let params = [
        "contactId" : contactId,
        "token" : token,
        "cardNumber" : number
      ]
      
      weak var weakSelf = self
      SessionManagerClass.getSharedInstance().request(BASE_URL + "/bsdPayment/inquiry/?key=" + self.apiKey, method: .get, parameters: params)
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
  
  open func startPayment(_ contactId: String, token: String, paymentId: String?, coupons: String, handler: @escaping (Result<String?>)->Void){
    
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
      SessionManagerClass.getSharedInstance().request(BASE_URL + "/bsdPayment/startPayment/", method: .get, parameters: params)
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
  
  open func getStoresAtLocation <StoreClass> (_ longitude: String?, latitude: String?, token : String?, version: String? = nil, storeClass: StoreClass.Type, handler: @escaping (Result<[BEStoreProtocol]?>) -> Void) where StoreClass: BEStoreProtocol {
    
    if (isOnline()) {
      
      var params = Dictionary<String, String>()
      if let longitude = longitude {
        params["long"] = longitude
      }
      
      if let latitude = latitude{
        params["lat"] = latitude
      }
      
      if let token = token {
        params["token"] = token
      }
      
      if let version = version {
        params["version"] = version
      }
      
      SessionManagerClass.getSharedInstance().request(BASE_URL + "/bsdStores/locate/?key=" + self.apiKey, method: .get, parameters: params)
        .validate(getDefaultErrorHandler())
        .responseObject {
          (response : DataResponse<StoresResponse<StoreClass>>) in
          
          if (response.result.isSuccess) {
            if let data = response.result.value {
              if (data.failed()) {
                handler(.failure(ApiError.dataSerialization(reason: Localized(key: BELocKey.error_bad_request_title))))
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
  
  public func pushNotificationEnroll(_ contactId: String, deviceToken: String, handler: @escaping (Result<Any?>)->Void) {
    
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
    SessionManagerClass.getSharedInstance().request(BASE_URL + "/pushNotificationEnroll/", method: .post, parameters: params)
      .validate(getDefaultErrorHandler())
      .responseObject { (response : DataResponse<PushNotificationResponse>) in
        
        if weakSelf?.dataGenerator != nil {
          handler(.success("success"))
          return
        }
        
        if (response.result.isSuccess) {
          if let result = response.result.value {
            if (result.failed()) {
              handler(.failure(ApiError.dataSerialization(reason: Localized(key: BELocKey.error_bad_request_title))))
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
  
  public func pushNotificationDelete(_ contactId: String, handler: @escaping (Result<Any>)->Void) {
    
    guard isOnline() else {
      handler(.failure(ApiError.networkConnectionError()))
      return
    }
    
    let params = [
      "contact_id" : contactId,
      "key" : self.apiKey
    ]
    
    weak var weakSelf = self
    SessionManagerClass.getSharedInstance().request(BASE_URL + "/pushNotificationDelete/", method: .get, parameters: params)
      .validate(getDefaultErrorHandler())
      .responseObject { (response : DataResponse<PushNotificationResponse>) in
        
        if weakSelf?.dataGenerator != nil {
          handler(.success("success"))
          return
        }
        
        if (response.result.isSuccess) {
          if let result = response.result.value {
            if (result.failed()) {
              handler(.failure(ApiError.dataSerialization(reason: Localized(key: BELocKey.error_bad_request_title))))
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
  
  public func pushNotificationGetMessages(_ contactId: String, maxResults: Int, handler: @escaping (Result<[BEPushNotificationMessage]>) -> Void) {
    
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
    SessionManagerClass.getSharedInstance().request(BASE_URL + "/pushNotification/getMessages/", method: .get, parameters: params)
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
  
  public func pushNotificationUpdateStatus(_ messageId: String, status: PushNotificationStatus, handler: @escaping (Result<Any>) -> Void) {
    
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
    SessionManagerClass.getSharedInstance().request(BASE_URL + "/pushNotification/updateStatus/", method: .get, parameters: params)
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
  
  public func pushNotificationGetMessageById(_ messageId: String, handler: @escaping (Result<BEPushNotificationMessage>) -> Void) {
    
    guard isOnline() else {
      handler(.failure(ApiError.networkConnectionError()))
      return
    }
    
    let params = [
      "msg_id" : messageId,
      "key" : self.apiKey
    ]
    
    weak var weakSelf = self
    SessionManagerClass.getSharedInstance().request(BASE_URL + "/pushNotification/getMessageById/", method: .get, parameters: params)
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
  
  public func trackTransaction(
    contactId: String,
    transactionData: String,
    handler: @escaping (_ result: Result<TrackTransactionResponse>) -> Void) {
    
    guard isOnline() else {
      handler(.failure(ApiError.networkConnectionError()))
      return
    }
    
    guard let username = self.apiUsername else {
      handler(.failure(ApiError.noApiUsernameProvided()))
      return
    }
    
    let params = [
      "contact" : contactId,
      "username" : username,
      "key" : self.apiKey,
      "details" : transactionData
      ] as [String : Any]
    
    weak var weakSelf = self
    SessionManagerClass.getSharedInstance().request(BASE_URL + "/bsdTransactions/add/", method: .post, parameters: params)
      .validate(getDefaultErrorHandler())
      .responseObject { (dataResponse : DataResponse<TrackTransactionResponse>) in
        
        if let mock = weakSelf?.dataGenerator {
          handler(.success(mock.getTransactionResponse()))
          return
        }
        
        guard weakSelf?.handle(
          dataResponse: dataResponse,
          onFailError: { (reason) in
            return ApiError.trackTransactionError(reason: reason)
        },
          serverErrorHandler: handler) ?? true else {
            return
        }
        
        handler(.success(dataResponse.result.value!))
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
   
   - Parameter contactId: Contact ID.
   - Parameter startDate: The beginning date for transaction events.
   - Parameter endDate: The end date for transaction events.
   - Parameter handler: Completion handler.
   - Parameter result: Request result model.
   */
  
  public func getTransactions(
    contactId: String,
    startDate: Date?,
    endDate: Date?,
    handler: @escaping (_ result: Result<[BETransaction]>) -> Void) {
    
    guard isOnline() else {
      handler(.failure(ApiError.networkConnectionError()))
      return
    }
    
    var params = [
      "contact_id" : contactId,
      "key" : self.apiKey
      ] as [String : Any]
    
    if let date = startDate {
      params["start_date"] = self.transactionDateFormatter.string(from: date)
    }
    if let date = endDate {
      params["end_date"] = self.transactionDateFormatter.string(from: date)
    }
    
    weak var weakSelf = self
    SessionManagerClass.getSharedInstance().request(BASE_URL + "/bsdTransactionEvents/", method: .get, parameters: params)
      .validate(getDefaultErrorHandler())
      .responseData { response in
        
        if let _ = weakSelf?.dataGenerator {
          handler(.success([]))
          return
        }
        
        guard response.result.isSuccess else {
          handler(.failure(ApiError.network(error: response.result.error)))
          return
        }
        
        guard let responseData = response.result.value else {
          handler(.failure(ApiError.dataSerialization(reason: "Empty server response")))
          return
        }
        
        var jsonResponse : AnyObject? = nil
        
        do {
          jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: []) as AnyObject
        } catch { }
        
        if let errorObject = jsonResponse as? [String: Any] {
          if let error = errorObject["ERROR"] as? String {
            handler(.failure(ApiError.dataSerialization(reason: error)))
          }
          else {
            handler(.failure(ApiError.unknown()))
          }
          return
        }
        
        guard let data = jsonResponse as? [[String : Any]] else {
          handler(.failure(ApiError.unknown()))
          return
        }
        
        var transactions: [BETransaction] = []
        for transactionData in data {
          let map = Map(mappingType: .fromJSON, JSON: transactionData)
          if var transaction = BETransaction(map: map) {
            transaction.mapping(map: map)
            transactions.append(transaction)
          }
        }
        
        handler(.success(transactions))
    }
  }
  
  
  //MARK: - Support
  
  /**
   Sends support request.
   
   - Parameter supportRequest: Support request model. All fields should be filled.
   - Parameter handler: Completion handler.
   - Parameter result: Request result model.
   */
  
  public func sendSupportRequest(
    supportRequest: SupportRequest,
    handler: @escaping (_ error: ApiError?) -> Void) {
    
    guard isOnline() else {
      handler(ApiError.networkConnectionError())
      return
    }
    
    var params = Mapper().toJSON(supportRequest)
    params["key"] = self.apiKey
    
    SessionManagerClass.getSharedInstance().request(BASE_URL + "/feedback/contactUs/index.php", method: .post, parameters: params)
      .validate(getDefaultErrorHandler())
      .responseData { response in
        
        guard response.result.isSuccess else {
          handler(ApiError.network(error: response.result.error))
          return
        }
        
        guard let responseData = response.result.value else {
          handler(ApiError.dataSerialization(reason: "Empty server response"))
          return
        }
        
        var jsonResponse : AnyObject? = nil
        
        do {
          jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: []) as AnyObject
        } catch { }
        
        guard let responseObject = jsonResponse as? [String: Any] else {
          handler(ApiError.dataSerialization(reason: "Incorrect server response"))
          return
        }
        
        guard let status = responseObject["success"] as? String, status == "true" else {
          if let error = responseObject["error"] as? String {
            handler(ApiError.supportRequestError(reason: error))
          }
          else {
            handler(ApiError.unknown())
          }
          
          return
        }
        
        handler(nil)
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
  
  fileprivate func handle <ResponseModel: Mappable, ResultValue: Any> (
    dataResponse: DataResponse<ResponseModel>,
    onFailError: (_ reason: Any?) -> ApiError,
    serverErrorHandler: (_ result: Result<ResultValue>) -> Void) -> Bool {
    
    guard dataResponse.result.isSuccess else {
      serverErrorHandler(.failure(ApiError.network(error: dataResponse.result.error)))
      return false
    }
    
    guard let response = dataResponse.result.value else {
      serverErrorHandler(.failure(ApiError.dataSerialization(reason: "Failed to parse response")))
      return false
    }
    
    guard let serverResponse = response as? ServerResponse else {
      return true
    }
    
    guard serverResponse.isSuccess() else {
      serverErrorHandler(.failure(onFailError(serverResponse.errorValue?.messageValue)))
      return false
    }
    
    return true
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
    switch self {
    case .phoneNumber:
      return "Cell_Number"
    case .email:
      return "contactEmail"
    case .fKey:
      return "FKey"
    }
  }
}

