//
//  TestsMetadata.swift
//  BeanstalkEngageiOSSDK
//
//  Created by Pavel Dvorovenko on 1/3/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import BeanstalkEngageiOSSDK

class TestsMetadata: BEBaseTestsMetadataProtocol {
  internal func getBeanstalkApiKey() -> String {
    return "1234-4321-ABCD-DCBA"
  }
  
  internal func getRegisteredUser1Email() -> String {
    return "TestUser1@test.com"
  }
  
  internal func getRegisteredUser1Password() -> String {
    return "TestUser1"
  }
}
