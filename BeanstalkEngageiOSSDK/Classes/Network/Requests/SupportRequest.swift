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
  
  var supportAddress: String?
  var firstName: String?
  var lastName: String?
  var email: String?
  var phoneNumber: String?
  var comments: String?
  
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
