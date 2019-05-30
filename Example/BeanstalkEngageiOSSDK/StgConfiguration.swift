//
//  StgConfiguration.swift
//  BeanstalkEngageiOSSDK_Example
//
//  Created by Alexander Frolikov on 5/30/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

class StgConfiguration: IConfiguration {
  func getApiKey() -> String {
    return "LUPQ-LQ2J-95A2-XA8C-JWSE"
  }
  
  func getBaseUrl() -> String {
    return "stg-proc.beanstalkdata.com"
  }
}
