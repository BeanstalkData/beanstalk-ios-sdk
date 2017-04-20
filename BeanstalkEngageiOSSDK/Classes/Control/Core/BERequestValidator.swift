//
//  BERequestValidator.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 4/12/17.
//
//

import Foundation

/**
 Default implementation of BERequestValidatorProtocol.
 */
open class BERequestValidator: BERequestValidatorProtocol {
  
  public init() {
    
  }
  
  /**
   Validate the Create contact request.
   
   - Note: Following validation rules applied to the ContactRequest fields
     - firstName should not be ampty;
     - lastName should not be empty;
     - email may contain following characters: appercase and lowercase Latin letters A to Z and a to z, digits 0 to 9, +, -, @, .;
     - password should not be empty;
   
   - Parameter createRequest: Create contact request
   - Parameter errorHandler: Called if the createRequest is not correct
   */
  
  open func validate(createRequest: ContactRequest, errorHandler: @escaping (_ error: BEErrorType?) -> Void) -> Bool {
    
    if createRequest.origin == nil {
      guard (createRequest.getFirstName() != nil &&  !(createRequest.getFirstName()?.isEmpty)!) else {
        errorHandler(ApiError.missingParameterError(reason: "Enter First Name"))
        return false
      }
      guard (createRequest.getLastName() != nil && !(createRequest.getLastName()?.isEmpty)!) else {
        errorHandler(ApiError.missingParameterError(reason: "Enter Last Name"))
        return false
      }
//      guard (createRequest.getPhone() != nil && (createRequest.getPhone()?.isValidPhone())!) else {
//        errorHandler(ApiError.missingParameterError(reason: "Please enter a valid phone number"))
//        return false
//      }
//      guard (createRequest.getZipCode() != nil && (createRequest.getZipCode()?.isValidZipCode())!) else {
//        errorHandler(ApiError.missingParameterError(reason: "Enter 5 Digit Zipcode"))
//        return false
//      }
      guard (createRequest.getEmail() != nil && (createRequest.getEmail()?.isValidEmail())!) else {
        errorHandler(ApiError.missingParameterError(reason: "Enter Valid Email"))
        return false
      }
      guard (createRequest.getPassword() != nil && !(createRequest.getPassword()?.isEmpty)!) else {
        errorHandler(ApiError.missingParameterError(reason: "Enter Password"))
        return false
      }
    }
    
    return true
  }
  
  /**
   Validate the Update contact request.
   
   - Note: Following validation rules applied to the ContactRequest fields
   - contactId should not be ampty;
   - firstName should not be ampty;
   - lastName should not be empty;
   - phone should be valid for the US region;
   - ZIP code is a number consisted of five digits from 0 to 9 (e.g.,"94105")
   - email may contain following characters: appercase and lowercase Latin letters A to Z and a to z, digits 0 to 9, +, -, @, .;
   - password should not be empty;
   
   - Parameter createRequest: Create contact request
   - Parameter errorHandler: Called if the createRequest is not correct
   
   */
  open func validate(updateRequest: ContactRequest, errorHandler: @escaping  (_ error: BEErrorType?) -> Void) -> Bool {
    
    if updateRequest.origin == nil {
      guard (updateRequest.getContactId() != nil) else {
        errorHandler(ApiError.missingParameterError(reason: "Invalid origin contact."))
        return false
      }
      
      guard validate(createRequest: updateRequest, errorHandler: errorHandler) else {
        return false
      }
    }
    
    return true
  }
  
  /**
   Validate the Update password request parameters.
   
   - Parameter password: Password string should not be empty
   - Parameter confirmPassword: Password string should not be empty and should be equal to the password parameter
   - Parameter errorHandler: Called if the parameters are not correct
   */
  open func validate(password: String?, confirmPassword: String?, errorHandler: @escaping  (_ error: BEErrorType?) -> Void) -> Bool {
    
    guard !(password?.isEmpty)! else {
      errorHandler(ApiError.missingParameterError(reason: "Enter Password"))
      return false
    }
    
    guard password == confirmPassword else {
      errorHandler(ApiError.missingParameterError(reason: "Passwords do not match"))
      return false
    }
    
    return true
  }
  
  /**
   Validate the Email request parameters.
   
   - Parameter email: email may contain following characters: appercase and lowercase Latin letters A to Z and a to z, digits 0 to 9, +, -, @, .;
   - Parameter errorHandler: Called if the parameter is not correct
   */
  open func validate(email: String?, errorHandler: @escaping  (_ error: BEErrorType?) -> Void) -> Bool {
    
    guard (email?.isValidEmail())! else {
      errorHandler(ApiError.missingParameterError(reason: "Enter Valid Email"))
      return false
    }
    
    return true
  }
  
  /**
   Validate the Autentication request parameters.
   
   - Parameter email: email may contain following characters: appercase and lowercase Latin letters A to Z and a to z, digits 0 to 9, +, -, @, .;
   - Parameter password: password string should not be empty
   - Parameter errorHandler: Called if the parameters are not correct
   */
  open func validate(email: String?, password: String?, errorHandler: @escaping  (_ error: BEErrorType?) -> Void) -> Bool {
    
    guard (email?.isValidEmail())! else {
      errorHandler(ApiError.missingParameterError(reason: "Enter Valid Email"))
      return false
    }
    
    guard !(password?.isEmpty)! else {
      errorHandler(ApiError.missingParameterError(reason: "Enter Password"))
      return false
    }
    
    return true
  }
}
