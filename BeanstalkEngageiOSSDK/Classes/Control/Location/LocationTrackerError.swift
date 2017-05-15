//
//  LocationTrackerError.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation

/**
 Implementation of BEErrorType. Represents various errors that may occur during location tracking.
 */
public enum LocationTrackerError: BEErrorType {
  
  /// Location permissions denied or restricted
  case locationPermissionsDenied()
  
  /// CLLocationManager failed with error
  case locationManagerDidFail(error: Error)
  
  
  public func errorTitle() -> String? {
    var text: String?
    
    switch self {
    default:
      text = "Location Tracking Error"
    }
    
    return text
  }
  
  public func errorMessage() -> String? {
    var text: String?
    
    switch self {
    case .locationPermissionsDenied():
      text = "Location permission denied"
    case .locationManagerDidFail(let error):
      text = error.localizedDescription
//    default:
//      text = "Location tracking error occur"
    }
    
    return text
  }
}
