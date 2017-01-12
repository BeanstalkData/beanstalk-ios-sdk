//
//  ApiError.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import Foundation

public enum ApiError: ErrorType {
  case Network(error:NSError)
  case DataSerialization(reason: String)

  case NetworkConnection()
  case ContactExisted(update: Bool)
  case Unknown()
}
