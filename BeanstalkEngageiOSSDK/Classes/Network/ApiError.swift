//
//  ApiError.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import Foundation

public protocol BEErrorType: Error {
  func errorTitle() -> String?
  func errorMessage() -> String?
}

public enum ApiError: BEErrorType {
  
  case unknown()
  
  case dataSerialization(reason: String)
  case missingParameterError()
  
  case network(error: Error?)
  case networkConnectionError()
  
  case authenticatFailed(reason: Any?)
  case registrationFailed(reason: Any?)
  case userEmailExists(reason: Any?)
  case userPhoneExists(reason: Any?)
  
  case profileError(reason: Any?)
  case updateProfileError(reason: Any?)
  case updatePasswordError(reason: Any?)
  case resetPasswordError(reason: Any?)
  
  case giftCardsError(reason: Any?)
  case paymentError(reason: Any?)
  
  case findStoresError(reason: Any?)
  
  case unacceptableStatusCodeError(reason: String?, statusCode: Int)
  
  //MARK: error title / message
  
  public func errorTitle() -> String? {
    var errorTitle: String?
    
    switch self {
    case .unknown:
      errorTitle = "Bad request"
    case .dataSerialization(let reason):
      errorTitle = "Bad request"
    case ApiError.missingParameterError:
      errorTitle = "Invalid request"
    case .network(let error):
      errorTitle = "Bad request"
    case .networkConnectionError:
      errorTitle = "Connection Failed"
    
    case .authenticatFailed(let reason):
      errorTitle = "Login Failed"
    case ApiError.registrationFailed(let reason):
      errorTitle = "Registration Error"
    case .userEmailExists(let reason):
      errorTitle = "Registration Error"
    case .userPhoneExists(let reason):
      errorTitle = "Registration Error"
      
    case .profileError(let reason):
      errorTitle = "Profile Error"
    case .updateProfileError(let reason):
      errorTitle = "Update Profile Error"
    case .updatePasswordError(let reason):
      errorTitle = "Password Update"
    case .resetPasswordError(let reason):
      errorTitle = "Password reset"
      
    case .giftCardsError(let reason):
      errorTitle = "Cards Error"
    case .paymentError(let reason):
      errorTitle = "Payment Error"
      
    case .findStoresError(let reason):
      errorTitle = "Find Stores Error"
      
    default:
      errorTitle = "Bad request"
      break;
    }
    
    return errorTitle
  }
  
  public func errorMessage() -> String? {
    var errorMessage: String?
    
    switch self {
    case .unknown:
      errorMessage = "Sorry, an error occurred while processing your request"
    case .dataSerialization(let reason):
      errorMessage = reason
    case ApiError.missingParameterError:
      errorMessage = "Please verify parameter(s)"
    case .network(let error):
      errorMessage = (error != nil ? error!.localizedDescription : "Sorry, an error occurred while processing your request")
    case .networkConnectionError:
      errorMessage = "Connection unavailable"
    
    case .authenticatFailed(let reason):
      errorMessage = "Please check your credentials and try again"//getErrorMessageFromReason(reason, defaultMessage: "Username or password incorrect")
    case ApiError.registrationFailed(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "Unable to sign up user, please try again later")
      break
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
      
    case .unacceptableStatusCodeError(let reason, let statusCode):
      errorMessage = reason
      
    default:
      errorMessage = "Sorry, an error occurred while processing your request"
      break
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
