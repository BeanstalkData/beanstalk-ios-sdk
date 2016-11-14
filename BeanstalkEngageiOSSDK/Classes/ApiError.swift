//
//  ApiError.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import Foundation

public enum ApiError: ErrorType {
    case Network(error:NSError)
    case NetworkConnection()
    case DataSerialization(reason:String)
    case JsonSerialization(error:NSError)
    case ContactExisted(update: Bool)
    case Unknown()
}
