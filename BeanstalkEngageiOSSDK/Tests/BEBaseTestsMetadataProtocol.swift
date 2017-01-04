//
//  BEBaseTestsMetadataProtocol.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 1/3/17.
//
//

import Foundation

public protocol BEBaseTestsMetadataProtocol: class {
  func getBeanstalkApiKey() -> String
  
  func getRegisteredUser1Email() -> String
  func getRegisteredUser1Password() -> String
}
