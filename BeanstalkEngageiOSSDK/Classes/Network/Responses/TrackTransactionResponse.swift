//
//  TrackTransactionResponse.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

/**
 Response model for track transaction request.
 */
open class TrackTransactionResponse : ServerResponse {
  var successValue: [String: Any]?
  var transaction: BETransaction?
  
  
  public override func mapping(map: Map) {
    super.mapping(map: map)
    
    successValue <- map["success"]
    
    guard let message = self.successValue?["message"] as? [String: Any] else {
      return
    }
    
    let map = Map(mappingType: .fromJSON, JSON: message)
    self.transaction = BETransaction(map: map)
    self.transaction?.mapping(map: map)
  }
}
