//
//  ApiService.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import BeanstalkEngageiOSSDK

class ApiService: CoreService {
  
  required init(apiKey: String, session: BESessionProtocol, apiUsername: String? = nil) {
    super.init(apiKey: apiKey, session: session, apiUsername: apiUsername)
  }
  
  func registerMyLoyaltyAccount (request: ContactRequest, handler: @escaping (Bool, BEErrorType?) -> Void) {
    registerLoyaltyAccount(request: request, contactClass: ContactModel.self, handler: handler)
  }
  
  func registerMe (request : ContactRequest, handler: @escaping (Bool, BEErrorType?) -> Void) {
    register(request : request, contactClass: ContactModel.self, handler: handler)
  }
  
  func autoSignInMe(handler: @escaping ((_ success: Bool, BEErrorType?) -> Void)) {
    autoSignIn(contactClass: ContactModel.self, handler: handler)
  }
  
  func authenticateMe(email: String?, password: String?, handler: @escaping (_ success: Bool, _ error: BEErrorType?) -> Void ) {
    authenticate(email: email, password: password, contactClass: ContactModel.self, handler: handler)
  }
  
  func getMyContact(handler: @escaping (Bool, BEContact?, BEErrorType?) -> Void) {
    getContact(contactClass: ContactModel.self, handler: handler)
  }
}
