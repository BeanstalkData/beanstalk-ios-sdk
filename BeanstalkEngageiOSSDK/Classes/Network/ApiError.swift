//
//  ApiError.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import Foundation

public enum ApiError: ErrorType {
  
  case Unknown()
  
  case DataSerialization(reason: String)
  case MissingParameterError()
  
  case Network(error: NSError?)
  case NetworkConnectionError()
  
  case AuthenticatFailed(reason: Any?)
  case RegistrationFailed(reason: Any?)
  case UserEmailExists(reason: Any?)
  case UserPhoneExists(reason: Any?)
  
  case ProfileError(reason: Any?)
  case UpdateProfileError(reason: Any?)
  case UpdatePasswordError(reason: Any?)
  case ResetPasswordError(reason: Any?)
  
  case GiftCardsError(reason: Any?)
  case PaymentError(reason: Any?)
  
  case FindStoresError(reason: Any?)
  
  //MARK: error title / message
  
  public func errorTitle() -> String? {
    var errorTitle: String?
    
    switch self {
    case .Unknown:
      errorTitle = "Bad request"
    case .DataSerialization(let reason):
      errorTitle = "Bad request"
    case .MissingParameterError:
      errorTitle = "Invalid request"
    case .Network(let error):
      errorTitle = "Bad request"
    case .NetworkConnectionError:
      errorTitle = "Connection Failed"
    
    case .AuthenticatFailed(let reason):
      errorTitle = "Login Error"
    case .RegistrationFailed(let reason):
      errorTitle = "Registration Error"
    case .UserEmailExists(let reason):
      errorTitle = "Registration Error"
    case .UserPhoneExists(let reason):
      errorTitle = "Registration Error"
      
    case .ProfileError(let reason):
      errorTitle = "Profile Error"
    case .UpdateProfileError(let reason):
      errorTitle = "Update Profile Error"
    case .UpdatePasswordError(let reason):
      errorTitle = "Password Update"
    case .ResetPasswordError(let reason):
      errorTitle = "Password reset"
      
    case .GiftCardsError(let reason):
      errorTitle = "Cards Error"
    case .PaymentError(let reason):
      errorTitle = "Payment Error"
      
    case .FindStoresError(let reason):
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
    case .Unknown:
      errorMessage = "Sorry, an error occurred while processing your request"
    case .DataSerialization(let reason):
      errorMessage = reason
    case .MissingParameterError:
      errorMessage = "Please verify parameter(s)"
    case .Network(let error):
      errorMessage = (error != nil ? error!.localizedDescription : "Sorry, an error occurred while processing your request")
    case .NetworkConnectionError:
      errorMessage = "Connection unavailable"
    
    case .AuthenticatFailed(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "Username or password incorrect")
    case .RegistrationFailed(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "Unable to sign up user, please try again later")
      break
    case .UserEmailExists(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "This email is already registered in our database. Please sign-in into your account. Use the \"forgot password\" button in case you need to reset it.")
    case .UserPhoneExists(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "This phone is already registered in our database. Please sign-in into your account. Use the \"forgot password\" button in case you need to reset it.")
      
    case .ProfileError(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "Unable to retrieve profile")
    case .UpdateProfileError(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "Update Failed!")
    case .UpdatePasswordError(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "Unable to update password")
    case .ResetPasswordError(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "Unable to reset password")
      
    case .GiftCardsError(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "Error Retrieving Cards Information")
    case .PaymentError(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "Error generating barcode. Please try again later.")
     
    case .FindStoresError(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: "Error Retrieving Stores Information")
      
    default:
      errorMessage = "Sorry, an error occurred while processing your request"
      break
    }
    
    return errorMessage
  }
  
  private func getErrorMessageFromReason(reason: Any?, defaultMessage: String) -> String? {
    var errorMessage: String? = defaultMessage
    
    if let reasonError = reason as? ApiError {
      switch reasonError {
      case .Unknown:
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
