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

public class ApiCommunication {
  let BASE_URL    = "https://proc.beanstalkdata.com"
  private let apiKey: String
  
  internal let reachabilityManager: Alamofire.NetworkReachabilityManager
  
  internal var dataGenerator: MockDataGenerator?
  
  public required init(apiKey: String) {
    self.apiKey = apiKey
    self.reachabilityManager = Alamofire.NetworkReachabilityManager(host: BASE_URL)!
  }
  
  func checkContactsByEmailExisted(email: String, handler: (ApiError?) -> Void) {
    let params = ["type": "email",
                  "key": self.apiKey,
                  "q": email
    ]
    Alamofire.request(.GET, BASE_URL + "/contacts", parameters : params)
      .responseString {
        response in
        if response.result.isSuccess {
          if response.result.value == Optional("null") {
            handler(nil)
          } else{
            let responseData = response.result.value?.dataUsingEncoding(NSUTF8StringEncoding)
            var jsonResponse : AnyObject? = nil
            
            do {
              jsonResponse = try NSJSONSerialization.JSONObjectWithData(responseData!, options: NSJSONReadingOptions(rawValue: 0))
            } catch { }
            
            guard let data = jsonResponse as? [AnyObject] where data.count >= 1 else {
              handler(nil)
              return
            }
            if let contact = data[0] as? [String : AnyObject]{
              if let prospect = contact["Prospect"] as? String {
                if "eclub".caseInsensitiveCompare(prospect) == NSComparisonResult.OrderedSame{
                  handler(.ContactExisted(update: true))
                  return
                }
              }
            }
            
            handler(.ContactExisted(update: false))
          }
        }
        else{
          handler(.NetworkConnection())
        }
    }
  }
  
  func checkContactsByPhoneExisted(phone: String, handler: (ApiError?) -> Void) {
    let params = ["type": "cell_number",
                  "key": self.apiKey,
                  "q": phone
    ]
    Alamofire.request(.GET, BASE_URL + "/contacts", parameters : params)
      .responseString {
        response in
        if response.result.isSuccess {
          if response.result.value == Optional("null") {
            handler(nil)
          }else{
            let responseData = response.result.value?.dataUsingEncoding(NSUTF8StringEncoding)
            var jsonResponse : AnyObject? = nil
            
            do {
              jsonResponse = try NSJSONSerialization.JSONObjectWithData(responseData!, options: NSJSONReadingOptions(rawValue: 0))
            } catch { }
            
            guard let data = jsonResponse as? [AnyObject] where data.count >= 1 else {
              handler(nil)
              return
            }
            if let contact = data[0] as? [String : AnyObject]{
              if let prospect = contact["Prospect"] as? String {
                if "eclub".caseInsensitiveCompare(prospect) == NSComparisonResult.OrderedSame{
                  handler(.ContactExisted(update: true))
                  return
                }
              }
            }
            
            handler(.ContactExisted(update: false))
          }
        }
        else{
          handler(.NetworkConnection())
        }
    }
  }
  
  func checkContactIsNovadine(email: String, handler: (Bool,ApiError?) -> Void) {
    let params = ["type": "email",
                  "key": self.apiKey,
                  "q": email
    ]
    Alamofire.request(.GET, BASE_URL + "/contacts", parameters : params)
      .responseString {
        response in
        if (response.result.isSuccess) {
          if (response.result.value != nil) {
            if response.result.value == Optional("null"){
              handler(false, .Unknown())
            }else {
              handler(false, .ContactExisted(update: false))
            }
          }else{
            handler(false, .DataSerialization(reason : "No data available!"))
          }
        }
        else{
          handler(false, .NetworkConnection())
        }
    }
  }
  
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
  
  func createLoyaltyAccount (request : CreateContactRequest, handler: (LoyaltyUser?, ApiError?) -> Void) {
    let params = [
      "FirstName": request.firstName!,
      "LastName": request.lastName!,
      "ZipCode" : request.zipCode!,
      "Email" : request.email!,
      "Password": request.password!,
      "CellNumber" : request.phone!,
      "Birthday" : request.birthdate!,
      "custom_PreferredReward" : request.preferredReward!,
      "Gender" : request.male ? "Male" : "Female",
      "Email_Optin": request.emailOptIn ? "true" :"false",
      "Txt_Optin": request.txtOptIn ? "true" :"false",
      "PushNotification_Optin": request.pushNotificationOptin ? "true" :"false",
      "InboxMessage_Optin": request.inboxMessageOptin ? "true" :"false",
      "custom_Novadine_User" : request.novadine ? "1" :"0",
      "Source" : "iosapp",
      "Prospect" : "loyalty"
    ]
    
    Alamofire.request(.POST, BASE_URL + "/addPaymentLoyaltyAccount/?key=" + self.apiKey, parameters: params)
      .validate(getDefaultErrorHandler())
      .responseObject(completionHandler: { (response : Response<LoyaltyUser, NSError>) in
        if (response.result.isSuccess) {
          if response.result.value != nil {
            handler(response.result.value!, nil)
          }else{
            handler(nil, .DataSerialization(reason : "Bad request!"))
          }
        }
        else{
          if (response.response?.statusCode == 200) {
            handler(nil, .DataSerialization(reason : "Bad request!"))
          } else {
            handler(nil, .NetworkConnection())
          }
        }
      })
  }
  
  func createContact(request : CreateContactRequest, handler: (String?, ApiError?) -> Void) {
    let params = [
      "FirstName": request.firstName!,
      "LastName": request.lastName!,
      "ZipCode" : request.zipCode!,
      "Email" : request.email!,
      "Cell_Number" : request.phone!,
      "Birthday" : request.birthdate!,
      "custom_PreferredReward" : request.preferredReward!,
      "Gender" : request.male ? "Male" : "Female",
      "Email_Optin": request.emailOptIn ? "true" :"false",
      "Txt_Optin": request.txtOptIn ? "true" :"false",
      "PushNotification_Optin": request.pushNotificationOptin ? "true" :"false",
      "InboxMessage_Optin": request.inboxMessageOptin ? "true" :"false",
      "custom_Novadine_User" : request.novadine ? "1" :"0",
      "Source" : "iosapp",
      "Prospect" : "loyalty"
    ]
    Alamofire.request(.POST, BASE_URL + "/addContact/?key=" + self.apiKey, parameters: params)
      .responseJSON {
        response in
        if (response.result.isSuccess) {
          if response.result.value != nil {
            guard let data = response.result.value as? [String] where
              data.count == 2 else{
                handler(nil, .DataSerialization(reason : "Failed deserialization!"))
                return
            }
            if "Add" == data[1]{
              handler(data[0], nil)
            }else if "Update" == data[1]{
              handler(data[0], nil)
            }
          }else{
            handler(nil, .DataSerialization(reason : "Bad request!"))
          }
        }
        else{
          if (response.response?.statusCode == 200) {
            handler(nil, .DataSerialization(reason : "Bad request!"))
          } else {
            handler(nil, .NetworkConnection())
          }
        }
    }
  }
  
  func createUser(email: String, password: String, contactId: String, handler: (ApiError?) -> Void) {
    let params = ["email": email,
                  "password": password,
                  "key": self.apiKey,
                  "contact": contactId
    ]
    Alamofire.request(.POST, BASE_URL + "/addUser/", parameters: params)
      .responseString {
        response in
        if (response.result.isSuccess) {
          if (response.result.value != nil) {
            if response.result.value == Optional("Success"){
              handler(nil)
            }else {
              handler(.DataSerialization(reason : "No data available!"))
            }
          }else{
            handler(.DataSerialization(reason : "No data available!"))
          }
        }
        else{
          handler(.NetworkConnection())
        }
    }
    
  }
  
  func authenticateUser(email: String, password: String, handler: (contactId : Optional<String> , token : Optional<String> , error : ApiError?) -> Void) {
    
    if (self.reachabilityManager.isReachable) {
      let params = ["email": email,
                    "password": password,
                    "key": self.apiKey,
                    "time": "-1"
      ]
      Alamofire.request(.POST, BASE_URL + "/authenticateUser/", parameters: params)
        .validate(getErrorHandler("Login failed. Please try again."))
        .responseString { response in
          print(response)
          if (response.result.isSuccess) {
            let responseData = response.result.value?.dataUsingEncoding(NSUTF8StringEncoding)
            var jsonResponse : AnyObject? = nil
            
            do {
              jsonResponse = try NSJSONSerialization.JSONObjectWithData(responseData!, options: NSJSONReadingOptions(rawValue: 0))
            } catch { }
            guard let data = jsonResponse as? [AnyObject] where data.count == 2 else {
              handler(contactId : nil, token : nil, error: .DataSerialization(reason : "Login failed. Please try again."))
              return
            }
            let contactId = String(data[0] as! Int)
            handler(contactId : contactId, token : data[1] as? String, error: nil)
          } else{
            handler(contactId: nil, token: nil, error : .Network(error: response.result.error!))
          }
      }
    } else {
       handler(contactId: nil, token: nil, error : .NetworkConnection())
    }
  }
  
  func resetPassword(email: String, handler: (String?, ApiError?) -> Void) {
    let params = ["user": email]
    Alamofire.request(.POST, BASE_URL + "/bsdLoyalty/ResetPassword.php?key=" + self.apiKey, parameters: params)
      .responseString {
        response in
        if (response.result.isSuccess) {
          handler(response.result.value, nil)
        }
        else{
          handler(nil, .NetworkConnection())
        }
    }
  }
  
  func logoutUser(contactId: String, token : String, handler: (ApiError?) -> Void) {
    let params = ["contact": contactId,
                  "token" : token]
    Alamofire.request(.POST, BASE_URL + "/logoutUser", parameters: params)
      .responseString {
        response in
        if (response.result.isSuccess) {
          if response.result.value == Optional("error") ||
            response.result.value == Optional("logged out"){
            handler(nil)
          }else {
            handler(.Unknown())
          }
        }
        else{
          handler(.NetworkConnection())
        }
    }
  }
  
  public func checkZIPForAvailable(ZIP: String, handler: ((Bool, ApiError?) -> Void)) {
    // https://proc.beanstalkdata.com/bsdStores/locate/?key=HPER-RFJB-JKEO-NHNR-ETGT&lat=29.4301674&long=-98.4595557
    
    self.getLocationForZIP(ZIP) { (lat, lon, error) in
      if error != nil {
        handler(false, error)
      }
      else {
        let params = [
          "key": self.apiKey,
          "lat": lat,
          "long": lon,
          ]
        Alamofire.request(.GET, self.BASE_URL + "/bsdStores/locate/", parameters: params)
          .responseJSON {
            (response : Response<AnyObject, NSError>) in
            if (response.result.isSuccess) {
              if let responseDict = response.result.value as? [String : AnyObject] {
                if let stores = responseDict["stores"] as? [AnyObject] {
                  handler(stores.count > 0, nil)
                }
                else {
                  handler(false, .NetworkConnection())
                }
              }
              else {
                handler(false, .NetworkConnection())
              }
            }
            else{
              handler(false, .NetworkConnection())
            }
        }
      }
    }
  }
  
  func getContact(contactId: String, handler: (Contact?, ApiError?) -> Void) {
    let params = [
      "key": self.apiKey,
      "q": contactId
    ]
    Alamofire.request(.GET, BASE_URL + "/contacts", parameters: params)
      .responseArray {
        (response : Response<[Contact], NSError>) in
        if (response.result.isSuccess) {
          if let data = response.result.value  where data.count == 1 {
            handler(data[0], nil)
          }else {
            handler(nil, .Unknown())
          }
        }
        else{
          handler(nil, .NetworkConnection())
        }
    }
  }
  
  func updateContact(original: Contact, request : UpdateContactRequest, handler: (ApiError?) -> Void)  {
    var params = [
      "ContactID" : "\(original.contactId!)"]
    if request.firstName!.caseInsensitiveCompare(original.firstName!) != NSComparisonResult.OrderedSame {
      params["FirstName"] = request.firstName!
    }
    
    if request.lastName!.caseInsensitiveCompare(original.lastName!) != NSComparisonResult.OrderedSame {
      params["LastName"] = request.lastName!
    }
    
    if request.zipCode != original.zipCode {
      params["ZipCode"] = request.zipCode!
    }
    
    if request.email!.caseInsensitiveCompare(original.email!) != NSComparisonResult.OrderedSame {
      params["Email"] = request.email!
    }
    
    if request.phone != original.phone {
      params["Cell_Number"] = request.phone!
    }
    
    if request.birthdate != original.birthday {
      params["Birthday"] = request.birthdate!
    }
    
    if request.preferredReward != original.preferredReward{
      params["custom_PreferredReward"] = request.preferredReward!
    }
    
    if request.emailOptIn != (original.emailOptin == 1) {
      params["Email_Optin"] = request.emailOptIn ? "true" :"false"
    }
    
    if request.pushNotificationOptin != (original.pushNotificationOptin == 1) {
      params["PushNotification_Optin"] = request.pushNotificationOptin ? "true" :"false"
    }
    
    if request.inboxMessageOptin != (original.inboxMessageOptin == 1) {
      params["InboxMessage_Optin"] = request.inboxMessageOptin ? "true" :"false"
    }
    
    if request.male != (original.gender == "Male") {
      params["Gender"] = request.male ? "Male" : "Female"
    }
    
    if params.count <= 1{
      handler(nil)
      return
    }
    
    Alamofire.request(.POST, BASE_URL + "/addContact/?key=" + self.apiKey, parameters: params)
      .responseJSON {
        response in
        if (response.result.isSuccess) {
          if response.result.value != nil {
            guard let data = response.result.value as? [String] where
              data.count == 1 else{
                handler(.DataSerialization(reason : "Failed deserialization!"))
                return
            }
            handler(nil)
          }else{
            handler(.DataSerialization(reason : "Bad request!"))
          }
        }
        else{
          handler(.NetworkConnection())
        }
    }
  }
  
  func updatePassword(password : String, contactId : String, token: String, handler : (ApiError?)->Void){
    let params = ["token": token,
                  "password": password,
                  "key": self.apiKey,
                  "contact": contactId
    ]
    Alamofire.request(.POST, BASE_URL + "/bsdLoyalty/?function=updatePassword", parameters: params)
      .responseString {
        response in
        if (response.result.isSuccess) {
          if (response.result.value != nil) {
            if response.result.value == Optional("success"){
              handler(nil)
            }else {
              handler(.DataSerialization(reason : "No data available!"))
            }
          }else{
            handler(.DataSerialization(reason : "No data available!"))
          }
        }
        else{
          handler(.NetworkConnection())
        }
    }
  }
  
  func getUserOffers(contactId : String, handler : (CouponResponse?, ApiError?)->Void){
    let params = [
      "key": self.apiKey,
      "Card": contactId
    ]
    Alamofire.request(.GET, BASE_URL + "/bsdLoyalty/getOffersM.php", parameters: params)
      .responseObject {
        (response : Response<CouponResponse, NSError>) in
        if self.dataGenerator != nil {
          handler(self.dataGenerator!.getUserOffers(), nil)
          return
        }
        if (response.result.isSuccess) {
          if let data = response.result.value {
            handler(data, nil)
          }else {
            handler(nil, .Unknown())
          }
        }else if response.response?.statusCode == 200 {
          handler(nil, nil)
        }
        else{
          handler(nil, .NetworkConnection())
        }
    }
  }
  
  func getProgress(contactId : String, handler : (RewardsCountResponse?, ApiError?)->Void){
    let params = [
      "contact": contactId
    ]
    Alamofire.request(.POST, BASE_URL + "/bsdLoyalty/getProgress.php?key=" + self.apiKey, parameters: params)
      .responseObject {
        (response : Response<RewardsCountResponse, NSError>) in
        if self.dataGenerator != nil {
          handler(self.dataGenerator!.getUserProgress(), nil)
          return
        }
        if (response.result.isSuccess) {
          if let data = response.result.value {
            handler(data, nil)
          }else {
            handler(nil, .Unknown())
          }
        }else if response.response?.statusCode == 200 {
          handler(nil, nil)
        }
        else{
          handler(nil, .NetworkConnection())
        }
    }
    
  }
  
  func getGiftCards(contactId: String, token : String, handler : (GiftCardsResponse?, ApiError?) -> Void) {
    let params = [
      "contactId" : contactId,
      "token" : token
    ]
    Alamofire.request(.GET, BASE_URL + "/bsdPayment/list?key=" + self.apiKey, parameters: params)
      .responseObject {
        (response : Response<GCResponse, NSError>) in
        if self.dataGenerator != nil {
          handler(self.dataGenerator!.getUserGiftCards(), nil)
          return
        }
        if (response.result.isSuccess) {
          if let data = response.result.value {
            handler(data, nil)
          }else {
            handler(nil, .Unknown())
          }
        }else if response.response?.statusCode == 200 {
          handler(nil, nil)
        }
        else{
          handler(nil, .NetworkConnection())
        }
    }
  }
  
  func getGiftCardBalance(contactId: String, token : String, number : String, handler : (GiftCardBalanceResponse?, ApiError?) -> Void){
    let params = [
      "contactId" : contactId,
      "token" : token,
      "cardNumber" : number
    ]
    Alamofire.request(.GET, BASE_URL + "/bsdPayment/inquiry?key=" + self.apiKey, parameters: params)
      .responseObject {
        (response : Response<GCBResponse, NSError>) in
        if self.dataGenerator != nil {
          handler(self.dataGenerator!.getUserGiftCardBalance(), nil)
          return
        }
        if (response.result.isSuccess) {
          if let data = response.result.value {
            handler(data, nil)
          }else {
            handler(nil, .Unknown())
          }
        }else if response.response?.statusCode == 200 {
          handler(nil, nil)
        }
        else{
          handler(nil, .NetworkConnection())
        }
    }
  }
  
  func startPayment(contactId: String, token: String, paymentId: String?, coupons: String, handler : (PaymentResponse?, ApiError?)->Void){
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
    Alamofire.request(.GET, BASE_URL + "/bsdPayment/startPayment", parameters: params)
      .responseObject {
        (response : Response<PaymentResponse, NSError>) in
        if self.dataGenerator != nil {
          handler(self.dataGenerator!.getUserPayment(), nil)
          return
        }
        if (response.result.isSuccess) {
          if let data = response.result.value {
            handler(data, nil)
          }else {
            handler(nil, .Unknown())
          }
        }else if response.response?.statusCode == 200 {
          handler(nil, nil)
        }
        else{
          handler(nil, .NetworkConnection())
        }
    }
  }
  
  //MARK: - Locations
  
  func getStoresAtLocation(longitude: String, latitude: String, token : String?, handler : (StoresResponseProtocol?, ApiError?) -> Void) {
    var params = [
      "long" : longitude,
      "lat" : latitude
    ]
    
    if (token != nil) {
      params["token"] = token
    }
    
    Alamofire.request(.GET, BASE_URL + "/bsdStores/locate?key=" + self.apiKey, parameters: params)
      .responseObject {
        (response : Response<StoresResponse, NSError>) in
        
        if (response.result.isSuccess) {
          if let data = response.result.value {
            handler(data, nil)
          }else {
            handler(nil, .Unknown())
          }
        }else if response.response?.statusCode == 200 {
          handler(nil, nil)
        }
        else{
          handler(nil, .NetworkConnection())
        }
    }
  }
  
  
  //MARK: - Push Notifications
  
  func pushNotificationEnroll(contactId: String, deviceToken: String, handler : (PushNotificationResponse?, ApiError?)->Void) {
    let params = [
      "contact_id" : contactId,
      "deviceToken" : deviceToken,
      "key" : self.apiKey,
      "platform" : "iOS"
    ]
    
    Alamofire.request(.GET, BASE_URL + "/pushNotificationEnroll", parameters: params)
      .responseObject { (response : Response<PushNotificationResponse, NSError>) in
        if self.dataGenerator != nil {
          handler(nil, nil)
          return
        }
        
        if (response.result.isSuccess) {
          if let result = response.result.value {
            handler(result, nil)
          }
          else {
            handler(nil, .Unknown())
          }
        }
        else if response.response?.statusCode == 200 {
          handler(nil, nil)
        }
        else {
          handler(nil, .NetworkConnection())
        }
    }
  }
  
  func pushNotificationDelete(contactId: String, handler : (PushNotificationResponse?, ApiError?)->Void) {
    let params = [
      "contact_id" : contactId,
      "key" : self.apiKey
    ]
    
    Alamofire.request(.GET, BASE_URL + "/pushNotificationDelete", parameters: params)
      .responseObject { (response : Response<PushNotificationResponse, NSError>) in
        if self.dataGenerator != nil {
          handler(nil, nil)
          return
        }
        
        if (response.result.isSuccess) {
          if let result = response.result.value {
            handler(result, nil)
          }
          else {
            handler(nil, .Unknown())
          }
        }
        else if response.response?.statusCode == 200 {
          handler(nil, nil)
        }
        else {
          handler(nil, .NetworkConnection())
        }
    }
  }
  
  func pushNotificationGetMessages(contactId: String, maxResults: Int, handler : (PushNotificationMessagesResponse?, ApiError?)->Void) {
    let params = [
      "contact_id" : contactId,
      "key" : self.apiKey,
      "max_results": NSNumber(integer: maxResults)
    ]
    
    Alamofire.request(.GET, BASE_URL + "/pushNotification/getMessages", parameters: params)
      .responseObject {
        (response : Response<PushNotificationMessagesResponse, NSError>) in
        if self.dataGenerator != nil {
          handler(nil, nil)
          return
        }
        if (response.result.isSuccess) {
          if let result = response.result.value {
            handler(result, nil)
          }else {
            handler(nil, .Unknown())
          }
        }else if response.response?.statusCode == 200 {
          handler(nil, nil)
        }
        else{
          handler(nil, .NetworkConnection())
        }
    }
  }
  
  func pushNotificationMessageUpdateStatus(messageId: String, action: PushNotificationStatus, handler : (PushNotificationResponse?, ApiError?)->Void) {
    let params = [
      "message_id" : messageId,
      "key" : self.apiKey,
      "action": action.rawValue
    ]
    
    Alamofire.request(.GET, BASE_URL + "/pushNotification/updateStatus", parameters: params)
      .responseObject {
        (response : Response<PushNotificationResponse, NSError>) in
        if self.dataGenerator != nil {
          handler(nil, nil)
          return
        }
        if (response.result.isSuccess) {
          if let result = response.result.value {
            handler(result, nil)
          }else {
            handler(nil, .Unknown())
          }
        }else if response.response?.statusCode == 200 {
          handler(nil, nil)
        }
        else{
          handler(nil, .NetworkConnection())
        }
    }
  }
  
  func pushNotificationGetMessage(messageId: String, handler : (PushNotificationMessagesResponse?, ApiError?)->Void) {
    let params = [
      "msg_id" : messageId,
      "key" : self.apiKey
    ]
    
    Alamofire.request(.GET, BASE_URL + "/pushNotification/getMessageById", parameters: params)
      .responseObject {
        (response : Response<PushNotificationMessagesResponse, NSError>) in
        if self.dataGenerator != nil {
          handler(nil, nil)
          return
        }
        if (response.result.isSuccess) {
          if let result = response.result.value {
            handler(result, nil)
          }else {
            handler(nil, .Unknown())
          }
        }else if response.response?.statusCode == 200 {
          handler(nil, nil)
        }
        else{
          handler(nil, .NetworkConnection())
        }
    }
  }
  
  
  //MARK: - Tracking
  
  func trackTransaction(contactId: String, userName: String, transactionData: AnyObject, handler: (ApiError?)->Void) {
    let params = [
      "contactId" : contactId,
      "userName" : userName,
      "key" : self.apiKey,
      "details" : transactionData
    ]
    
    Alamofire.request(.GET, BASE_URL + "/bsdTransactions/add/", parameters: params)
      .responseObject {
        (response : Response<TrackTransactionResponse, NSError>) in
        if self.dataGenerator != nil {
          handler(nil)
          return
        }
        if (response.result.isSuccess) {
          if let _ = response.result.value {
            handler(nil)
          }else {
            handler(.Unknown())
          }
        }else if response.response?.statusCode == 200 {
          handler(nil)
        }
        else{
          handler(.NetworkConnection())
        }
    }
  }
  
  
  //MARK: - Private
  
  func getLocationForZIP(ZIP: String, hanler: ((lat: String, lon: String, error: ApiError?) -> Void)) {
    let urlString = "https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyDVcad18_PO7vxQhnyfj4LzJDMl5RoliSM&address=\(ZIP)"
    
    Alamofire.request(.GET, urlString)
      .responseJSON {
        (response : Response <AnyObject, NSError>) in
        var isSucces = false
        var lat = ""
        var lon = ""
        var error: ApiError? = .NetworkConnection()
        
        if response.result.isSuccess {
          if let responseDict = response.result.value as? [String : AnyObject] {
            if let resultsArray = responseDict["results"] as? Array<[String : AnyObject]> {
              if let firstEntry = resultsArray.first {
                if let geometry = firstEntry["geometry"] as? [String : AnyObject] {
                  if let location = geometry["location"] as? [String : AnyObject] {
                    if let latitude = location["lat"] as? NSNumber {
                      if let longitude = location["lng"] as? NSNumber {
                        isSucces = true
                        lat = latitude.stringValue
                        lon = longitude.stringValue
                        error = nil
                      }
                    }
                  }
                }
              }
            }
          }
        }
        else {
          if let err = response.result.error {
            error = .Network(error: err)
          }
        }
        
        if isSucces {
          hanler(lat: lat, lon: lon, error: nil)
        }
        else {
          hanler(lat: lat, lon: lon, error: error)
        }
    }
  }
}

public class LoyaltyUser : Mappable {
  public var contactId: String?
  public var sessionToken: String?
  public var giftCardNumber : String?
  public var giftCardPin : String?
  public var giftCardRegistrationStatus : Bool?
  public var giftCardTrack2 : String?
  
  required public init?(_ map: Map) {
    
  }
  
  public func mapping(map: Map) {
    contactId <- map["contactId"]
    sessionToken <- map["sessionToken"]
    giftCardNumber <- map["giftCardNumber"]
    giftCardPin <- map["giftCardPin"]
    giftCardRegistrationStatus <- map["giftCardRegistrationStatus"]
    giftCardTrack2 <- map["giftCardTrack2"]
  }
}

public class Contact : Mappable {
  public var contactId: Int?
  public var firstName: String?
  public var lastName : String?
  public var zipCode : String?
  public var email : String?
  public var prospect : String?
  public var gender: String?
  public var birthday : String?
  public var fKey : String?
  public var phone : String?
  public var textOptin = 0
  public var emailOptin = 0
  public var pushNotificationOptin = 0
  public var inboxMessageOptin = 0
  public var preferredReward : String?
  public var nodavine = false
  
  required public init?(_ map: Map) {
    
  }
  
  public func mapping(map: Map) {
    contactId <- map["contactId"]
    firstName <- map["contactFirstName"]
    lastName <- map["contactLastName"]
    zipCode <- map["contactZipCode"]
    email <- map["contactEmail"]
    prospect <- map["Prospect"]
    gender <- map["gender"]
    birthday <- map["contactBirthday"]
    fKey <- map["FKey"]
    phone <- map["Cell_Number"]
    textOptin <- map["Txt_Optin"]
    emailOptin <- map["Email_Optin"]
    pushNotificationOptin <- map["PushNotification_Optin"]
    inboxMessageOptin <- map["InboxMessage_Optin"]
    preferredReward <- map["PreferredReward"]
    nodavine <- map["Novadine_User"]
  }
}

public final class CreateContactRequest{
  public var contactId: Int?
  public var firstName : String?
  public var lastName : String?
  public var phone: String?
  public var email: String?
  public var emailConfirm: String?
  public var password : String?
  public var passwordConfirm : String?
  public var zipCode : String?
  public var birthdate: String?
  public var male = false
  public var emailOptIn = false
  public var txtOptIn = false
  public var pushNotificationOptin = false
  public var inboxMessageOptin = false
  public var preferredReward : String?
  public var novadine = false
  
  public init() {
    
  }
}

public final class UpdateContactRequest{
  public var firstName : String?
  public var lastName : String?
  public var phone: String?
  public var email: String?
  public var zipCode : String?
  public var birthdate: String?
  public var male = false
  public var emailOptIn = false
  public var txtOptIn = false
  public var pushNotificationOptin = false
  public var inboxMessageOptin = false
  public var preferredReward : String?
  
  public init() {
    
  }
}

