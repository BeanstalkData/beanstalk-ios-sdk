//
//  ProdConfiguration.swift
//  BeanstalkEngageiOSSDK_Example
//
//  Created by Alexander Frolikov on 5/30/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

class  ProdConfiguration: IConfiguration {
  func getApiKey() -> String {
    return "F76O-5TGX-3ZDT-WLPE-UA1W"
  }
  
  func getBaseUrl() -> String {
    return "proc.beanstalkdata.com"
  }
}
