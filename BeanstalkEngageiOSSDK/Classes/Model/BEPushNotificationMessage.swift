//
//  BEPushNotificationMessage.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/16/17.
//
//

import Foundation

import ObjectMapper

open class BEPushNotificationMessage {
  
  required public init?(map: Map) {
    self.mapping(map: map)
  }
  
  open func mapping(map: Map) {
    
  }
}
