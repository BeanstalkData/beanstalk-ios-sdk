//
//  ServerErrorResponse.swift
//  Pods
//
//  Created by Dmytro Nadtochyy on 3/30/17.
//
//

import Foundation
import ObjectMapper


open class ServerErrorResponse: Mappable {
  var codeValue: Int?
  var messageValue: String?
  
  
  required public init?(map: Map) {
    
  }
  
  public func mapping(map: Map) {
    codeValue <- map["code"]
    messageValue <- map["message"]
  }
}
