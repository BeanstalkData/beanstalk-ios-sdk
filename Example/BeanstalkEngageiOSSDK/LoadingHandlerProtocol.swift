//
//  LoadingHandlerProtocol.swift
//  BeanstalkEngageiOSSDK
//
//  Created by Pavel Dvorovenko on 4/13/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import BeanstalkEngageiOSSDK

/**
 List of protocols required by some methods of CoreService.
 
 - Note: Will be deprecated in future.
 */
public protocol LoadingHandlerProtocol {
  func handleError(success: Bool, error: BEErrorType?)
  
  func showMessage(_ error: BEErrorType)
  func showMessage(_ title: String?, message : String?)
  func showProgress(_ message: String)
  func hideProgress()
}
