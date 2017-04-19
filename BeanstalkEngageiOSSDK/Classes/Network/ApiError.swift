//
//  ApiError.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
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

/**
 Implementation of BEErrorType. Represents various errors that may occur during API requests.
 */
public enum ApiError: BEErrorType {
  
  /// Unknown error
  case unknown()
  
  /// Data serialization error
  case dataSerialization(reason: String)
  /// Missing parameter error
  case missingParameterError()
  
  /// Network error
  case network(error: Error?)
  /// Network connection error. Server is not reachable now.
  case networkConnectionError()
  
  /// Create contact failed with reason
  case createContactFailed(reason: Any)
  /// Delete contact failed with reason
  case deleteContactFailed(reason: Any?)
  /// Update contact failed with reason
  case updateContactFailed(reason: Any)
  /// Fetch contact failed with reason
  case fetchContactFailed(reason: Any)
  /// No contactId is stored in session
  case noContactIdInSession()
  
  /// No API username provided
  case noApiUsernameProvided()
  
  /// Authentication failed with reason
  case authenticationFailed(reason: Any?)
  /// Registration failed with reason
  case registrationFailed(reason: Any?)
  /// User with same email exists registration failed with reason
  case userEmailExists(reason: Any?)
  /// User with same phone exists registration failed with reason
  case userPhoneExists(reason: Any?)
  
  /// Get contact request failed with reason
  case profileError(reason: Any?)
  /// Update profile failed with reason
  case updateProfileError(reason: Any?)
  /// Update password failed with reason
  case updatePasswordError(reason: Any?)
  /// Reset password failed with reason
  case resetPasswordError(reason: Any?)
  
  /// Gift cards request failed with reason
  case giftCardsError(reason: Any?)
  /// Start payment failed with reason
  case paymentError(reason: Any?)
  
  /// Find stores failed with reason
  case findStoresError(reason: Any?)
  
  /// Track transaction failed with reason
  case trackTransactionError(reason: Any?)
  
  /// Unacceptable status code error
  case unacceptableStatusCodeError(reason: String?, statusCode: Int)
  
  /**
   Error title to present for user.
   */
  public func errorTitle() -> String? {
    var errorTitle: String?
    
    switch self {
    case .unknown:
      errorTitle = "Bad request"
      
    case .dataSerialization(_):
      errorTitle = "Bad request"
    case .missingParameterError:
      errorTitle = "Invalid request"
      
    case .network(_):
      errorTitle = "Bad request"
    case .networkConnectionError:
      errorTitle = "Connection Failed"
    
    case .noApiUsernameProvided():
      errorTitle = "No API username provided"
      
    case .createContactFailed(_):
      errorTitle = "Create Contact Failed"
    case .deleteContactFailed(_):
      errorTitle = "Delete Contact Failed"
    case .updateContactFailed(_):
      errorTitle = "Update Contact Failed"
    case .fetchContactFailed(_):
      errorTitle = "Fetch Contact Failed"
    case .noContactIdInSession():
      errorTitle = "No contact ID is stored in session"
      
    case .authenticationFailed(_):
      errorTitle = "Login Failed"
    case .registrationFailed(_):
      errorTitle = "Registration Error"
    case .userEmailExists(_):
      errorTitle = "Registration Error"
    case .userPhoneExists(_):
      errorTitle = "Registration Error"
      
    case .profileError(_):
      errorTitle = "Profile Error"
    case .updateProfileError(_):
      errorTitle = "Update Profile Error"
    case .updatePasswordError(_):
      errorTitle = "Password Update"
    case .resetPasswordError(_):
      errorTitle = "Password reset"
      
    case .giftCardsError(_):
      errorTitle = "Cards Error"
    case .paymentError(_):
      errorTitle = "Payment Error"
      
    case .findStoresError(_):
      errorTitle = "Find Stores Error"
      
    case .trackTransactionError(_):
      errorTitle = "Track Transaction Error"
      
    case .unacceptableStatusCodeError(_, _):
      errorTitle = "Bad request"
    }
    
    return errorTitle
  }
  
  /**
   Error message to present for user.
   */
  public func errorMessage() -> String? {
    var errorMessage: String?
    
    switch self {
    case .unknown:
      errorMessage = "Sorry, an error occurred while processing your request"
    case .dataSerialization(let reason):
      errorMessage = reason
    case .missingParameterError:
      errorMessage = "Please verify parameter(s)"
    case .network(let error):
      errorMessage = (error != nil ? error!.localizedDescription : "Sorry, an error occurred while processing your request")
    case .networkConnectionError:
      errorMessage = "Connection unavailable"
    
    case .noApiUsernameProvided():
      errorMessage = "In order to perform this action API username must be provided"
      
    case .createContactFailed(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "Unknown error")
    case .deleteContactFailed(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "Failed to delete contact")
    case .updateContactFailed(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "Unknown error")
    case .fetchContactFailed(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "Failed to fetch contact")
    case .noContactIdInSession():
      errorMessage = "Contact ID should be provided by session"
      
    case .authenticationFailed(_):
      errorMessage = "Please check your credentials and try again"//getErrorMessageFromReason(reason, defaultMessage: "Username or password incorrect")
    case .registrationFailed(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "Unable to sign up user, please try again later")
    case .userEmailExists(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "This email is already registered in our database. Please sign-in into your account. Use the \"forgot password\" button in case you need to reset it.")
    case .userPhoneExists(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "This phone is already registered in our database. Please sign-in into your account. Use the \"forgot password\" button in case you need to reset it.")
      
    case .profileError(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "Unable to retrieve profile")
    case .updateProfileError(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "Update Failed!")
    case .updatePasswordError(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "Unable to update password")
    case .resetPasswordError(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "Unable to reset password")
      
    case .giftCardsError(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "Error Retrieving Cards Information")
    case .paymentError(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "Error generating barcode. Please try again later.")
     
    case .findStoresError(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "Error Retrieving Stores Information")
      
    case .trackTransactionError(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "Failed to Track Transaction")
      
    case .unacceptableStatusCodeError(let reason, _):
      errorMessage = reason
    }
    
    return errorMessage
  }
  
  public func getErrorMessageFromReason(_ reason: Any?, defaultMessage: String) -> String? {
    var errorMessage: String? = defaultMessage
    
    if let reasonError = reason as? ApiError {
      switch reasonError {
      case .unknown:
        break
      default:
        errorMessage = reasonError.errorMessage()
      }
    } else if let reasonString = reason as? String {
      errorMessage = reasonString
    }
    
    return errorMessage
  }
}
