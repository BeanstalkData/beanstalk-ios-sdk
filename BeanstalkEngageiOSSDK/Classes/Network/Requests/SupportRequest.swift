//
//  SupportRequest.swift
//  Pods
//
//  Created by Dmytro Nadtochyy on 12/7/17.
//
//

import Foundation
import ObjectMapper

/**
 Request model for support request.
 */
open class SupportRequest: Mappable {
  
  open var supportAddress: String?
  open var firstName: String?
  open var lastName: String?
  open var email: String?
  open var phoneNumber: String?
  open var comments: String?
  
  required public init?(map: Map) {
  }
  
  open func mapping(map: Map) {
    
    supportAddress <- map["to_email"]
    firstName <- map["first_name"]
    lastName <- map["last_name"]
    email <- map["from_email"]
    phoneNumber <- map["phone_number"]
    comments <- map["comments"]
  }
}
