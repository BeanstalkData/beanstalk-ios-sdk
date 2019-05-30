//
//  ConfigurstionProtocol.swift
//  BeanstalkEngageiOSSDK_Example
//
//  Created by Alexander Frolikov on 5/30/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

protocol IConfiguration {
  func getApiKey() -> String
  func getBaseUrl() -> String
}

enum Environment: String {
  case stg = "Stage"
   case prod = "Prod"
}
