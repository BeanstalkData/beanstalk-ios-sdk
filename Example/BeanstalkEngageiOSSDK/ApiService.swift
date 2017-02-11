//
//  ApiService.swift
//  BeanstalkEngageiOSSDK
//
//  Created by Pavel Dvorovenko on 2/11/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import BeanstalkEngageiOSSDK

class ApiService: CoreService {
  
  required init(apiKey: String, session: BESession) {
    super.init(apiKey: apiKey, session: session)
  }
  
  func registerLoyaltyAccount (controller: RegistrationProtocol?, request: CreateContactRequest, handler: (Bool) -> Void) {
    registerLoyaltyAccount(controller, request: request, contactClass: ContactModel.self, handler: handler)
  }
  
  func register (controller : RegistrationProtocol?, request : CreateContactRequest, handler : (Bool) -> Void) {
    register(controller, request : request, contactClass: ContactModel.self, handler : handler)
  }
  
  func autoSignIn(controller: AuthenticationProtocol?, handler : ((success: Bool) -> Void)) {
    autoSignIn(controller, contactClass: ContactModel.self, handler : handler)
  }
  
  func authenticate(controller: AuthenticationProtocol?, email: String?, password: String?, handler : (success: Bool, additionalInfo : Bool) -> Void ) {
    authenticate(controller, email: email, password: password, contactClass: ContactModel.self, handler : handler)
  }
  
  func getContact(controller : CoreProtocol?, handler : (BEContact?) -> Void) {
    getContact(controller, contactClass: ContactModel.self, handler : handler)
  }
}
