//
//  BERequestValidatorProtocol.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 4/12/17.
//
//

import Foundation

/**
 Validator is a request validation protocol desighned to be used in the CoreService
 */
public protocol BERequestValidatorProtocol {
  /**
   Validate the Create contact request.

   - Parameter createRequest: Create contact request
   - Parameter errorHandler: Called if the createRequest is not correct
   */
  func validate(createRequest: ContactRequest, errorHandler: @escaping  (_ error: BEErrorType?) -> Void) -> Bool
  
  /**
   Validate the Update contact request.
   
   - Parameter createRequest: Create contact request
   - Parameter errorHandler: Called if the createRequest is not correct
   */
  func validate(updateRequest: ContactRequest, errorHandler: @escaping  (_ error: BEErrorType?) -> Void) -> Bool
  
  /**
   Validate the Update password request parameters.
   
   - Parameter password:
   - Parameter confirmPassword:
   - Parameter errorHandler: Called if the createRequest is not correct
   */
  func validate(password: String?, confirmPassword: String?, errorHandler: @escaping  (_ error: BEErrorType?) -> Void) -> Bool
  
  /**
   Validate the Email request parameters.
   
   - Parameter email:
   - Parameter errorHandler: Called if the parameter is not correct
   */
  func validate(email: String?, errorHandler: @escaping  (_ error: BEErrorType?) -> Void) -> Bool
  
  /**
   Validate the Autentication request parameters.
   
   - Parameter email:
   - Parameter password:
   - Parameter errorHandler: Called if the parameters are not correct
   */
  func validate(email: String?, password: String?, errorHandler: @escaping  (_ error: BEErrorType?) -> Void) -> Bool
}
