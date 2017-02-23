//
//  ApiCommunication.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import Timberjack

public class ApiCommunication <SessionManagerClass: HTTPAlamofireManager> {
  let BASE_URL    = "https://proc.beanstalkdata.com"
  private let apiKey: String
  
  internal let reachabilityManager: Alamofire.NetworkReachabilityManager
  
  internal var dataGenerator: MockDataGenerator?
  
  public required init(apiKey: String) {
    self.apiKey = apiKey
    
    self.reachabilityManager = Alamofire.NetworkReachabilityManager(host: BASE_URL)!
  }
  
  public func isOnline() -> Bool {
    return self.reachabilityManager.isReachable
  }
  
  func checkContactsByEmailExisted(email: String, prospectTypes: [ProspectType], handler: (Result<Bool, ApiError>) -> Void) {
    if (isOnline()) {
      let params = ["type": "email",
                    "key": self.apiKey,
                    "q": email
      ]
      SessionManagerClass.getSharedInstance().request(.GET, BASE_URL + "/contacts", parameters : params)
        .validate(getDefaultErrorHandler())
        .responseString {
          response in
          if response.result.isSuccess {
            if response.result.value == Optional("null") {
              handler(.Success(false))
            } else{
              let responseData = response.result.value?.dataUsingEncoding(NSUTF8StringEncoding)
              var jsonResponse : AnyObject? = nil
              
              do {
                jsonResponse = try NSJSONSerialization.JSONObjectWithData(responseData!, options: NSJSONReadingOptions(rawValue: 0))
              } catch { }
              
              guard let data = jsonResponse as? [AnyObject] where data.count >= 1 else {
                handler(.Success(false))
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
                    handler(.Success(true))
                    return
                  }
                }
              }
              
              handler(.Failure(.Unknown()))
            }
          } else {
            handler(.Failure(.Network(error: response.result.error)))
          }
      }
    } else {
      handler(.Failure(.NetworkConnectionError()))
    }
  }
  
  func checkContactsByPhoneExisted(phone: String, prospectTypes: [ProspectType], handler: (Result<Bool, ApiError>) -> Void) {
    if (isOnline()) {
      let params = ["type": "cell_number",
                    "key": self.apiKey,
                    "q": phone
      ]
      SessionManagerClass.getSharedInstance().request(.GET, BASE_URL + "/contacts", parameters : params)
        .validate(getDefaultErrorHandler())
        .responseString {
          response in
          if response.result.isSuccess {
            if response.result.value == Optional("null") {
              handler(.Success(false))
            }else{
              let responseData = response.result.value?.dataUsingEncoding(NSUTF8StringEncoding)
              var jsonResponse : AnyObject? = nil
              
              do {
                jsonResponse = try NSJSONSerialization.JSONObjectWithData(responseData!, options: NSJSONReadingOptions(rawValue: 0))
              } catch { }
              
              guard let data = jsonResponse as? [AnyObject] where data.count >= 1 else {
                handler(.Success(false))
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
                    handler(.Success(true))
                    return
                  }
                }
              }
              
              handler(.Failure(.Unknown()))
            }
          } else {
            handler(.Failure(.Network(error: response.result.error)))
          }
      }
    } else {
      handler(.Failure(.NetworkConnectionError()))
    }
  }
  
  //TODO: fix this method
  func checkContactIsNovadine(email: String, handler: (Result<Bool, ApiError>) -> Void) {
    if (isOnline()) {
      let params = ["type": "email",
                    "key": self.apiKey,
                    "q": email
      ]
      SessionManagerClass.getSharedInstance().request(.GET, BASE_URL + "/contacts", parameters : params)
        .validate(getDefaultErrorHandler())
        .responseString {
          response in
          if (response.result.isSuccess) {
            if (response.result.value != nil) {
              if response.result.value == Optional("null"){
                handler(.Failure(.Unknown()))
              }else {
                handler(.Success(false))
              }
            }else{
              handler(.Failure(.DataSerialization(reason : "Bad request!")))
            }
          } else{
            handler(.Failure(.Network(error: response.result.error)))
          }
      }
    } else {
      handler(.Failure(.NetworkConnectionError()))
    }
  }

  
  func createLoyaltyAccount (request : ContactRequest, handler: (Result<BELoyaltyUser?, ApiError>) -> Void) {
    if (isOnline()) {
      
      let params = Mapper().toJSON(request)
      
      SessionManagerClass.getSharedInstance().request(.POST, BASE_URL + "/addPaymentLoyaltyAccount/?key=" + self.apiKey, parameters: params)
        .validate(getDefaultErrorHandler())
        .responseObject(completionHandler: { (response : Response<BELoyaltyUser, NSError>) in
          if (response.result.isSuccess) {
            if response.result.value != nil {
              handler(.Success(response.result.value))
            } else {
              handler(.Failure(.RegistrationFailed(reason : nil)))
            }
          } else {
            if (response.response?.statusCode == 200) {
              handler(.Failure(.RegistrationFailed(reason : nil)))
            } else {
              handler(.Failure(.Network(error: response.result.error)))
            }
          }
        })
    } else {
      handler(.Failure(.NetworkConnectionError()))
    }
  }
  
  func createContact(request : ContactRequest, handler: (Result<String, ApiError>) -> Void) {
    if (isOnline()) {
      
      var params = Mapper().toJSON(request)
      params["Cell_Number"] = params["CellNumber"]
      
      SessionManagerClass.getSharedInstance().request(.POST, BASE_URL + "/addContact/?key=" + self.apiKey, parameters: params)
        .validate(getDefaultErrorHandler())
        .responseJSON {
          response in
          if (response.result.isSuccess) {
            if response.result.value != nil {
              guard let data = response.result.value as? [String] where
                data.count == 2 else{
                  handler(.Failure(.RegistrationFailed(reason : nil)))
                  return
              }
              if "Add" == data[1]{
                handler(.Success(data[0]))
              } else if "Update" == data[1]{
                handler(.Success(data[0]))
              }
            } else {
              handler(.Failure(.RegistrationFailed(reason : nil)))
            }
          } else {
            if (response.response?.statusCode == 200) {
              handler(.Failure(.RegistrationFailed(reason : nil)))
            } else {
              handler(.Failure(.Network(error: response.result.error)))
            }
          }
      }
    } else {
      handler(.Failure(.NetworkConnectionError()))
    }
  }
  
  func createUser(email: String, password: String, contactId: String, handler: (Result<AnyObject?, ApiError>) -> Void) {
   
    if (isOnline()) {
      let params = ["email": email,
                    "password": password,
                    "key": self.apiKey,
                    "contact": contactId
      ]
      SessionManagerClass.getSharedInstance().request(.POST, BASE_URL + "/addUser/", parameters: params)
        .validate(getDefaultErrorHandler())
        .responseString {
          response in
          if (response.result.isSuccess) {
            if (response.result.value != nil) {
              if response.result.value == Optional("Success"){
                handler(.Success(nil))
              }else {
                handler(.Failure(.RegistrationFailed(reason : nil)))
              }
            }else{
              handler(.Failure(.RegistrationFailed(reason : nil)))
            }
          } else{
            handler(.Failure(.Network(error: response.result.error)))
          }
      }
    } else {
      handler(.Failure(.NetworkConnectionError()))
    }
  }
  
  func authenticateUser(email: String, password: String, handler: (Result<AuthenticateResponse, ApiError>) -> Void) {
    
    if (isOnline()) {
      let params = ["email": email,
                    "password": password,
                    "key": self.apiKey,
                    "time": "-1"
      ]
      SessionManagerClass.getSharedInstance().request(.POST, BASE_URL + "/authenticateUser/", parameters: params)
        .validate(getErrorHandler("Login failed. Please try again."))
        .responseString { response in
          if (response.result.isSuccess) {
            let responseData = response.result.value?.dataUsingEncoding(NSUTF8StringEncoding)
            var jsonResponse : AnyObject? = nil
            
            do {
              jsonResponse = try NSJSONSerialization.JSONObjectWithData(responseData!, options: NSJSONReadingOptions(rawValue: 0))
            } catch { }
            guard let data = jsonResponse as? [AnyObject] where data.count == 2 else {
              handler(.Failure(.AuthenticatFailed(reason: response.result.value)))
              return
            }
            let authResponse = AuthenticateResponse()
            authResponse.contactId = String(data[0] as! Int)
            authResponse.token = data[1] as? String
            handler(.Success(authResponse))
          } else{
            handler(.Failure(.Network(error: response.result.error)))
          }
      }
    } else {
       handler(.Failure(.NetworkConnectionError()))
    }
  }
  
  func checkUserSession(contactId: String, token : String, handler: (Result<AnyObject?, ApiError>) -> Void) {
    
    if (isOnline()) {
      let params = ["contact": contactId,
                    "token" : token]
      SessionManagerClass.getSharedInstance().request(.POST, BASE_URL + "/checkSession/",
        parameters: params)
        .validate(getDefaultErrorHandler())
        .responseString {
          response in
          if (response.result.isSuccess) {
            if response.result.value == Optional("valid"){
              handler(.Success(nil))
            }else {
              handler(.Failure(.Unknown()))
            }
          } else {
            handler(.Failure(.Network(error: response.result.error)))
          }
      }
    } else {
      handler(.Failure(.NetworkConnectionError()))
    }
  }
  
  func resetPassword(email: String, handler: (Result<String?, ApiError>) -> Void) {
    
    if (isOnline()) {
      let params = ["user": email]
      SessionManagerClass.getSharedInstance().request(.POST, BASE_URL + "/bsdLoyalty/ResetPassword.php?key=" + self.apiKey, parameters: params)
        .validate(getDefaultErrorHandler())
        .responseString {
          response in
          if (response.result.isSuccess) {
            if response.result.value?.characters.count > 0 {
              handler(.Failure(.ResetPasswordError(reason: response.result.value)))
            } else {
              handler(.Success(response.result.value))
            }
          } else {
            handler(.Failure(.Network(error: response.result.error)))
          }
      }
    } else {
      handler(.Failure(.NetworkConnectionError()))
    }
  }
  
  func logoutUser(contactId: String, token : String, handler: (Result<AnyObject?, ApiError>) -> Void) {
    if (isOnline()) {
      let params = ["contact": contactId,
                    "token" : token]
      SessionManagerClass.getSharedInstance().request(.POST, BASE_URL + "/logoutUser/", parameters: params)
        .validate(getDefaultErrorHandler())
        .responseString {
          response in
          if (response.result.isSuccess) {
            if response.result.value == Optional("error") ||
              response.result.value == Optional("logged out"){
              handler(.Success(nil))
            }else {
              handler(.Failure(.Unknown()))
            }
          } else {
            handler(.Failure(.Network(error: response.result.error)))
          }
      }
    } else {
      handler(.Failure(.NetworkConnectionError()))
    }
  }
  
  func getContact <ContactClass: Mappable> (contactId: String, contactClass: ContactClass.Type, handler: (Result<ContactClass?, ApiError>) -> Void) {
    if (isOnline()) {
      let params = [
        "key": self.apiKey,
        "q": contactId
      ]
      
      let map = Map(mappingType: .FromJSON, JSONDictionary: ["24": "23"])
      var tmp: ContactClass? = ContactClass(map)
      print(tmp.debugDescription)
      
      SessionManagerClass.getSharedInstance().request(.GET, BASE_URL + "/contacts", parameters: params)
        .validate(getDefaultErrorHandler())
        .responseArray {
          (response : Response<[ContactClass], NSError>) in
          if (response.result.isSuccess) {
            if let data = response.result.value  where data.count == 1 {
              handler(.Success(data[0]))
            }else {
              handler(.Failure(.Unknown()))
            }
          } else {
            handler(.Failure(.Network(error: response.result.error)))
          }
      }
    } else {
      handler(.Failure(.NetworkConnectionError()))
    }
  }
  
  func updateContact(original: BEContact, request : ContactRequest, handler: (Result<AnyObject?, ApiError>) -> Void)  {
    
    if (isOnline()) {
      
      let params = Mapper().toJSON(request)
      
      if params.count <= 1{
        handler(.Failure(.MissingParameterError()))
      } else {
        SessionManagerClass.getSharedInstance().request(.POST, BASE_URL + "/addContact/?key=" + self.apiKey, parameters: params)
          .validate(getDefaultErrorHandler())
          .responseJSON {
            response in
            if (response.result.isSuccess) {
              if response.result.value != nil {
                guard let data = response.result.value as? [String] where
                  data.count == 1 else{
                    handler(.Failure(.DataSerialization(reason : "Failed deserialization!")))
                    return
                }
                handler(.Success(nil))
              }else{
                handler(.Failure(.DataSerialization(reason : "Bad request!")))
              }
            }
            else{
              handler(.Failure(.Network(error: response.result.error)))
            }
        }
      }
    } else {
      handler(.Failure(.NetworkConnectionError()))
    }
  }
  
  func updatePassword(password : String, contactId : String, token: String, handler : (Result<AnyObject?, ApiError>)->Void){
   
    if (isOnline()) {
      let params = ["token": token,
                    "password": password,
                    "key": self.apiKey,
                    "contact": contactId
      ]
      SessionManagerClass.getSharedInstance().request(.POST, BASE_URL + "/bsdLoyalty/?function=updatePassword", parameters: params)
        .validate(getDefaultErrorHandler())
        .responseString {
          response in
          if (response.result.isSuccess) {
            if (response.result.value != nil) {
              if response.result.value == Optional("success"){
                handler(.Success(nil))
              } else {
                handler(.Failure(.DataSerialization(reason : "No data available!")))
              }
            } else{
              handler(.Failure(.DataSerialization(reason : "No data available!")))
            }
          } else {
            handler(.Failure(.Network(error: response.result.error)))
          }
      }
    } else {
      handler(.Failure(.NetworkConnectionError()))
    }
  }
  
  func getUserOffers <CouponClass: BECoupon> (contactId : String, couponClass: CouponClass.Type, handler : (Result<[BECoupon], ApiError>)->Void){
    
    if (isOnline()) {
      let params = [
        "key": self.apiKey,
        "Card": contactId
      ]
      SessionManagerClass.getSharedInstance().request(.GET, BASE_URL + "/bsdLoyalty/getOffersM.php", parameters: params)
        .validate(getDefaultErrorHandler())
        .responseObject {
          (response : Response<CouponResponse<CouponClass>, NSError>) in
          if self.dataGenerator != nil {
            let coupons: [BECoupon] = (self.dataGenerator!.getUserOffers().coupons != nil) ? self.dataGenerator!.getUserOffers().coupons! : []
            handler(.Success(coupons))
          } else {
            if (response.result.isSuccess) {
              if let data = response.result.value {
                let coupons: [BECoupon] = (data.coupons != nil) ? data.coupons! : []
                handler(.Success(coupons))
              }else {
                handler(.Failure(.Unknown()))
              }
            } else if response.response?.statusCode == 200 {
              handler(.Success([]))
            } else {
              handler(.Failure(.Network(error: response.result.error)))
            }
          }
      }
    } else {
      handler(.Failure(.NetworkConnectionError()))
    }
  }
  
  func getProgress(contactId : String, handler : (Result<Double?, ApiError>)->Void){
    
    if (isOnline()) {
      let params = [
        "contact": contactId
      ]
      SessionManagerClass.getSharedInstance().request(.POST, BASE_URL + "/bsdLoyalty/getProgress.php?key=" + self.apiKey, parameters: params)
        .validate(getDefaultErrorHandler())
        .responseObject {
          (response : Response<RewardsCountResponse, NSError>) in
          if self.dataGenerator != nil {
            handler(.Success(self.dataGenerator!.getUserProgress().getCount()))
          } else {
            if (response.result.isSuccess) {
              if let data = response.result.value {
                handler(.Success(data.getCount()))
              } else {
                handler(.Failure(.Unknown()))
              }
            } else if response.response?.statusCode == 200 {
              handler(.Failure(.Unknown()))
            } else {
              handler(.Failure(.Network(error: response.result.error)))
            }
          }
      }
    } else {
      handler(.Failure(.NetworkConnectionError()))
    }
  }
  
  func getGiftCards <GiftCardClass: BEGiftCard> (contactId: String, token : String, giftCardClass: GiftCardClass.Type, handler : (Result<[BEGiftCard], ApiError>) -> Void) {
    
    if (isOnline()) {
      let params = [
        "contactId" : contactId,
        "token" : token
      ]
      SessionManagerClass.getSharedInstance().request(.GET, BASE_URL + "/bsdPayment/list?key=" + self.apiKey, parameters: params)
        .validate(getDefaultErrorHandler())
        .responseObject {
          (response : Response<GCResponse<GiftCardClass>, NSError>) in
          if self.dataGenerator != nil {
            handler(.Success(self.dataGenerator!.getUserGiftCards().getCards()!))
          } else {
            if (response.result.isSuccess) {
              if let data = response.result.value {
                handler(.Success(data.getCards() != nil ? data.getCards()! : []))
              } else {
                handler(.Failure(.Unknown()))
              }
            } else if response.response?.statusCode == 200 {
              handler(.Failure(.Unknown()))
            } else {
              handler(.Failure(.Network(error: response.result.error)))
            }
          }
      }
    } else {
      handler(.Failure(.NetworkConnectionError()))
    }
  }
  
  func getGiftCardBalance(contactId: String, token : String, number : String, handler : (Result<String?, ApiError>) -> Void){
    
    if (isOnline()) {
      let params = [
        "contactId" : contactId,
        "token" : token,
        "cardNumber" : number
      ]
      SessionManagerClass.getSharedInstance().request(.GET, BASE_URL + "/bsdPayment/inquiry?key=" + self.apiKey, parameters: params)
        .validate(getDefaultErrorHandler())
        .responseObject {
          (response : Response<GCBResponse, NSError>) in
          if self.dataGenerator != nil {
            handler(.Success(self.dataGenerator!.getUserGiftCardBalance().getCardBalance()))
          } else {
            if (response.result.isSuccess) {
              if let data = response.result.value {
                handler(.Success(data.getCardBalance()))
              } else {
                handler(.Failure(.Unknown()))
              }
            }else if response.response?.statusCode == 200 {
              handler(.Failure(.Unknown()))
            }
            else{
              handler(.Failure(.Network(error: response.result.error)))
            }
          }
      }
    } else{
      handler(.Failure(.NetworkConnectionError()))
    }
  }
  
  func startPayment(contactId: String, token: String, paymentId: String?, coupons: String, handler : (Result<String?, ApiError>)->Void){
    
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
      SessionManagerClass.getSharedInstance().request(.GET, BASE_URL + "/bsdPayment/startPayment", parameters: params)
        .validate(getDefaultErrorHandler())
        .responseObject {
          (response : Response<PaymentResponse, NSError>) in
          if self.dataGenerator != nil {
            handler(.Success(self.dataGenerator!.getUserPayment().token))
          } else {
            if (response.result.isSuccess) {
              if let data = response.result.value {
                handler(.Success(data.token))
              } else {
                handler(.Failure(.Unknown()))
              }
            } else if response.response?.statusCode == 200 {
              handler(.Success(nil))
            }
            else{
              handler(.Failure(.Network(error: response.result.error)))
            }
          }
      }
    } else{
      handler(.Failure(.NetworkConnectionError()))
    }
  }
  
  //MARK: - Locations
  
  func getStoresAtLocation <StoreClass: BEStore> (longitude: String?, latitude: String?, token : String?, storeClass: StoreClass.Type, handler : (Result<[BEStore]?, ApiError>) -> Void) {
    
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
      
      SessionManagerClass.getSharedInstance().request(.GET, BASE_URL + "/bsdStores/locate?key=" + self.apiKey, parameters: params)
        .validate(getDefaultErrorHandler())
        .responseObject {
          (response : Response<StoresResponse<StoreClass>, NSError>) in
          
          if (response.result.isSuccess) {
            if let data = response.result.value {
              if (data.failed()) {
                handler(.Failure(.DataSerialization(reason: "Bad request!")))
              } else {
                handler(.Success(data.getStores()))
              }
            } else {
              handler(.Failure(.Unknown()))
            }
          } else if response.response?.statusCode == 200 {
            handler(.Success(nil))
          } else{
            handler(.Failure(.Network(error: response.result.error)))
          }
      }
    } else {
      handler(.Failure(.NetworkConnectionError()))
    }
  }
  
  
  //MARK: - Push Notifications
  
  // TODO: fix it
  
  func pushNotificationEnroll(contactId: String, deviceToken: String, handler : (Result<AnyObject?, ApiError>)->Void) {
    
    if (isOnline()) {
      let params = [
        "contact_id" : contactId,
        "deviceToken" : deviceToken,
        "key" : self.apiKey,
        "platform" : "iOS"
      ]
      
      SessionManagerClass.getSharedInstance().request(.GET, BASE_URL + "/pushNotificationEnroll", parameters: params)
        .validate(getDefaultErrorHandler())
        .responseObject { (response : Response<PushNotificationResponse, NSError>) in
          if self.dataGenerator != nil {
            handler(.Success(nil))
            return
          }
          
          if (response.result.isSuccess) {
            if let result = response.result.value {
              if (result.failed()) {
                handler(.Failure(.DataSerialization(reason: "Bad request!")))
              } else {
                handler(.Success(deviceToken))
              }
            }
            else {
              handler(.Failure(.Unknown()))
            }
          }
          else if response.response?.statusCode == 200 {
            handler(.Success(nil))
          }
          else {
            handler(.Failure(.Network(error: response.result.error)))
          }
      }
    } else {
      handler(.Failure(.NetworkConnectionError()))
    }
  }
  
  // TODO: fix it
  func pushNotificationDelete(contactId: String, handler : (Result<AnyObject?, ApiError>)->Void) {
    
    if (isOnline()) {
      let params = [
        "contact_id" : contactId,
        "key" : self.apiKey
      ]
      
      SessionManagerClass.getSharedInstance().request(.GET, BASE_URL + "/pushNotificationDelete", parameters: params)
        .validate(getDefaultErrorHandler())
        .responseObject { (response : Response<PushNotificationResponse, NSError>) in
          if self.dataGenerator != nil {
            handler(.Success(nil))
            return
          }
          
          if (response.result.isSuccess) {
            if let result = response.result.value {
              if (result.failed()) {
                handler(.Failure(.DataSerialization(reason: "Bad request!")))
              } else {
                handler(.Success("success"))
              }
            }
            else {
              handler(.Failure(.Unknown()))
            }
          }
          else if response.response?.statusCode == 200 {
            handler(.Success(nil))
          }
          else {
            handler(.Failure(.Network(error: response.result.error)))
          }
      }
    } else {
      handler(.Failure(.NetworkConnectionError()))
    }
  }
  
  func getPushNotificationMessages(contactId: String, maxResults: Int, handler : (Result<[BEPushNotificationMessage]?, ApiError>)->Void) {
    
    if (isOnline()) {
      let params = [
        "contact_id" : contactId,
        "key" : self.apiKey,
        "max_results": NSNumber(integer: maxResults)
      ]
      
      SessionManagerClass.getSharedInstance().request(.GET, BASE_URL + "/pushNotification/getMessages", parameters: params)
        .validate(getDefaultErrorHandler())
        .responseObject {
          (response : Response<PushNotificationMessagesResponse, NSError>) in
          if self.dataGenerator != nil {
            handler(.Success(nil))
          } else {
            if (response.result.isSuccess) {
              if let result = response.result.value {
                handler(.Success(result.getMessages()))
              }else {
                handler(.Failure(.Unknown()))
              }
            }else if response.response?.statusCode == 200 {
              handler(.Success(nil))
            }
            else{
              handler(.Failure(.Network(error: response.result.error)))
            }
          }
      }
    } else {
      handler(.Failure(.NetworkConnectionError()))
    }
  }
  
  func getPushNotificationMessage(messageId: String, action: PushNotificationStatus, handler : (Result<[BEPushNotificationMessage]?, ApiError>)->Void) {
    
    if (isOnline()) {
      let params = [
        "message_id" : messageId,
        "key" : self.apiKey,
        "action": action.rawValue
      ]
      
      SessionManagerClass.getSharedInstance().request(.GET, BASE_URL + "/pushNotification/updateStatus", parameters: params)
        .validate(getDefaultErrorHandler())
        .responseObject {
          (response : Response<PushNotificationResponse, NSError>) in
          if self.dataGenerator != nil {
            handler(.Success(nil))
            return
          } else {
            if (response.result.isSuccess) {
              if let result = response.result.value {
                handler(.Success(result.getMessages()))
              }else {
                handler(.Failure(.Unknown()))
              }
            }else if response.response?.statusCode == 200 {
              handler(.Success(nil))
            }
            else{
              handler(.Failure(.Network(error: response.result.error)))
            }
          }
      }
    }  else {
      handler(.Failure(.NetworkConnectionError()))
    }
  }
  
  func getPushNotificationMessage(messageId: String, handler : (Result<BEPushNotificationMessage?, ApiError>)->Void) {
    
    if (isOnline()) {
      let params = [
        "msg_id" : messageId,
        "key" : self.apiKey
      ]
      
      SessionManagerClass.getSharedInstance().request(.GET, BASE_URL + "/pushNotification/getMessageById", parameters: params)
        .validate(getDefaultErrorHandler())
        .responseObject {
          (response : Response<PushNotificationMessagesResponse, NSError>) in
          if self.dataGenerator != nil {
            handler(.Success(nil))
          } else {
            if (response.result.isSuccess) {
              if let result = response.result.value {
                handler(.Success(result.getMessages()?.first))
              }else {
                handler(.Failure(.Unknown()))
              }
            }else if response.response?.statusCode == 200 {
              handler(.Success(nil))
            }
            else{
              handler(.Failure(.Network(error: response.result.error)))
            }
          }
      }
    } else {
      handler(.Failure(.NetworkConnectionError()))
    }
  }
  
  
  //MARK: - Tracking
  
  func trackTransaction(contactId: String, userName: String, transactionData: AnyObject, handler: (Result<AnyObject?, ApiError>)->Void) {
    
    if (isOnline()) {
      let params = [
        "contactId" : contactId,
        "userName" : userName,
        "key" : self.apiKey,
        "details" : transactionData
      ]
      
      SessionManagerClass.getSharedInstance().request(.GET, BASE_URL + "/bsdTransactions/add/", parameters: params)
        .validate(getDefaultErrorHandler())
        .responseObject {
          (response : Response<TrackTransactionResponse, NSError>) in
          if self.dataGenerator != nil {
            handler(.Success(nil))
          } else {
            if (response.result.isSuccess) {
              if let _ = response.result.value {
                handler(.Success(nil))
              } else {
                handler(.Failure(.Unknown()))
              }
            } else if response.response?.statusCode == 200 {
              handler(.Success(nil))
            } else{
              handler(.Failure(.Network(error: response.result.error)))
            }
          }
      }
    } else {
      handler(.Failure(.NetworkConnectionError()))
    }
  }
  
  
  //MARK: - Private
  
  private func getErrorHandler(defaultMessage: String) -> Request.Validation {
    let validation : Request.Validation = { (urlRequest, ulrResponse) -> Request.ValidationResult in
      
      let acceptableStatusCodes: Range<Int> = 200..<300
      if acceptableStatusCodes.contains(ulrResponse.statusCode) {
        
        return .Success
      } else {
        
        var failureReason = defaultMessage
        
        if (ulrResponse.statusCode == 400) {
          //TODO: Handle custom error
          failureReason = "Response status code was unacceptable: \(ulrResponse.statusCode)"
        } else if (ulrResponse.statusCode == 404) {
          
        }
        
        let error = NSError(
          domain: Error.Domain,
          code: Error.Code.StatusCodeValidationFailed.rawValue,
          userInfo: [
            NSLocalizedFailureReasonErrorKey: failureReason,
            Error.UserInfoKeys.StatusCode: ulrResponse.statusCode
          ]
        )
        
        return .Failure(error)
      }
    }
    
    return validation
  }
  
  private func getDefaultErrorHandler() -> Request.Validation {
    return getErrorHandler("Got error while processing your request.");
  }
}

public class HTTPAlamofireManager: Alamofire.Manager {
  public class func getSharedInstance() -> Alamofire.Manager {
    return Alamofire.Manager.sharedInstance
  }
  
  public class func defaultSessionConfiguration() -> NSURLSessionConfiguration {
    return NSURLSessionConfiguration.defaultSessionConfiguration()
  }
}

public class HTTPTimberjackManager: HTTPAlamofireManager {
  static internal let shared: Alamofire.Manager = {
    let configuration = HTTPTimberjackManager.defaultSessionConfiguration()
    let manager = HTTPTimberjackManager(configuration: configuration)
    return manager
  }()
  
  public override class func getSharedInstance() -> Alamofire.Manager {
    return shared
  }
  
  public override class func defaultSessionConfiguration() -> NSURLSessionConfiguration {
    return Timberjack.defaultSessionConfiguration()
  }
}

public enum ProspectType: String {
  case Loyalty = "loyalty"
  case eClub = "eclub"
}

func ==(left: ProspectType, right: String) -> Bool {
  let strValue = left.rawValue
  
  return strValue.caseInsensitiveCompare(right) == NSComparisonResult.OrderedSame
}
