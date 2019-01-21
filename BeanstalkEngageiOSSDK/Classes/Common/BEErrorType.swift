//
//  BEErrorType.swift
//  Alamofire
//
//  Created by Alexander Frolikov on 1/21/19.
//

import Foundation

/**
 Protocol for error abstraction.
 */
public protocol BEErrorType: Error {
  /**
   Error title to present for user.
   */
  func errorTitle() -> String?
  
  /**
   Error message to present for user.
   */
  func errorMessage() -> String?
}
