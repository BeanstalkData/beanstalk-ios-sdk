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
  
  
  public override func mapping(map: Map) {
    super.mapping(map: map)
    
    successValue <- map["success"]
  }
  
  
  //MARK: - Public
  
  /**
   Returns transaction id if transaction was successful.
   */
  public func getTransactionId() -> String? {
    guard let message = self.successValue?["message"] as? [String: Any] else {
      return nil
    }
    
    let id = message["id"] as? String
    
    return id
  }
}
