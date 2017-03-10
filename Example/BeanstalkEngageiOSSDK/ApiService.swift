//
//  ApiService.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import BeanstalkEngageiOSSDK

class ApiService: CoreService {
  
  required init(apiKey: String, session: BESession) {
    super.init(apiKey: apiKey, session: session)
  }
  
  func registerMyLoyaltyAccount (_ controller: RegistrationProtocol?, request: ContactRequest, handler: @escaping (Bool) -> Void) {
    registerLoyaltyAccount(controller, request: request, contactClass: ContactModel.self, handler: handler)
  }
  
  func registerMe (_ controller : RegistrationProtocol?, request : ContactRequest, handler : @escaping (Bool) -> Void) {
    register(controller, request : request, contactClass: ContactModel.self, handler : handler)
  }
  
  func autoSignInMe(_ controller: AuthenticationProtocol?, handler : @escaping ((_ success: Bool) -> Void)) {
    autoSignIn(controller, contactClass: ContactModel.self, handler : handler)
  }
  
  func authenticateMe(_ controller: AuthenticationProtocol?, email: String?, password: String?, handler : @escaping (_ success: Bool) -> Void ) {
    authenticate(controller, email: email, password: password, contactClass: ContactModel.self, handler : handler)
  }
  
  func getMyContact(_ controller : CoreProtocol?, handler : @escaping (Bool, BEContact?) -> Void) {
    getContact(controller, contactClass: ContactModel.self, handler : handler)
  }
}
