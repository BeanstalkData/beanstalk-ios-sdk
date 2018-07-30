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
  
  case `default`
  
  /// Data serialization error
  case dataSerialization(reason: String)
  /// Missing parameter error
  case missingParameterError(reason: String)
  
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
  
  /// Support request failed
  case supportRequestError(reason: Any?)
  
  /// Unacceptable status code error
  case unacceptableStatusCodeError(reason: String?, statusCode: Int)
  
  /**
   Error title to present for user.
   */
  public func errorTitle() -> String? {
    switch self {
    case .unknown:
      return Localized(key: BELocKey.error_bad_request_title)
    
    case .default:
      return Localized(key: BELocKey.we_are_sorry)
      
    case .dataSerialization(_):
      return Localized(key: BELocKey.error_bad_request_title)
    case .missingParameterError(_):
      return Localized(key: BELocKey.error_invalid_request_title)
      
    case .network(_):
      return Localized(key: BELocKey.error_bad_request_title)
    case .networkConnectionError:
      return Localized(key: BELocKey.error_connection_failed_title)
    
    case .noApiUsernameProvided():
      return Localized(key: BELocKey.error_no_API_username_provided_title)
      
    case .createContactFailed(_):
      return Localized(key: BELocKey.error_create_contact_failed_title)
    case .deleteContactFailed(_):
      return Localized(key: BELocKey.error_delete_contact_failed_title)
    case .updateContactFailed(_):
      return Localized(key: BELocKey.error_update_contact_failed_title)
    case .fetchContactFailed(_):
      return Localized(key: BELocKey.error_fetch_contact_failed_title)
    case .noContactIdInSession():
      return Localized(key: BELocKey.error_no_contact_ID_is_stored_in_session_title)
      
    case .authenticationFailed(_):
      return Localized(key: BELocKey.login_failed)
    case .registrationFailed(_):
      return Localized(key: BELocKey.error_registration_title)
    case .userEmailExists(_):
      return Localized(key: BELocKey.error_registration_title)
    case .userPhoneExists(_):
      return Localized(key: BELocKey.error_registration_title)
      
    case .profileError(_):
      return Localized(key: BELocKey.error_profile_title)
    case .updateProfileError(_):
      return Localized(key: BELocKey.error_update_profile_title)
    case .updatePasswordError(_):
      return Localized(key: BELocKey.error_password_update_title)
    case .resetPasswordError(_):
      return Localized(key: BELocKey.error_password_reset_title)
      
    case .giftCardsError(_):
      return Localized(key: BELocKey.error_cards_error_title)
    case .paymentError(_):
      return Localized(key: BELocKey.error_payment_title)
      
    case .findStoresError(_):
      return Localized(key: BELocKey.error_find_stores_title)
      
    case .trackTransactionError(_):
      return Localized(key: BELocKey.error_track_transaction_title)
      
    case .supportRequestError(_):
      return Localized(key: BELocKey.error_support_request_title)
      
    case .unacceptableStatusCodeError(_, _):
      return Localized(key: BELocKey.error_bad_request_title)
    }
  }
  
  /**
   Error message to present for user.
   */
  public func errorMessage() -> String? {
    switch self {
    case .unknown:
      return Localized(key: BELocKey.error_sorry_an_error_occurred_while_processing_your_request)
      
    case .default:
      return Localized(key: BELocKey.transaction_problem)
      
    case .dataSerialization(let reason):
      return reason
    case .missingParameterError(let reason):
      return Localized(key: BELocKey.error_please_verify_parameters) + ((reason.lengthOfBytes(using: String.Encoding.utf8) > 0) ? ": " + reason : "")
    case .network(let error):
      return (error != nil ? error!.localizedDescription : Localized(key: BELocKey.error_sorry_an_error_occurred_while_processing_your_request))
    case .networkConnectionError:
      return Localized(key: BELocKey.error_connection_unavailable)
    
    case .noApiUsernameProvided():
      return Localized(key: BELocKey.error_api_username_must_be_provided)
      
    case .createContactFailed(let reason):
      return getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_unknown))
    case .deleteContactFailed(let reason):
      return getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_failed_to_delete_contact))
    case .updateContactFailed(let reason):
      return getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_unknown))
    case .fetchContactFailed(let reason):
      return getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_failed_to_fetch_contact))
    case .noContactIdInSession():
      return Localized(key: BELocKey.error_contact_ID_should_be_provided_by_session)
      
    case .authenticationFailed(_):
      return  Localized(key: BELocKey.login_failed_text)//getErrorMessageFromReason(reason, defaultMessage: "Username or password incorrect")
    case .registrationFailed(let reason):
      return getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_unable_to_sign_up_user))
    case .userEmailExists(let reason):
      return getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_this_email_is_already_registered))
    case .userPhoneExists(let reason):
      return getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_this_phone_is_already_registered))
      
    case .profileError(let reason):
      return getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_unable_to_retrieve_profile))
    case .updateProfileError(let reason):
      return getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_update_failed))
    case .updatePasswordError(let reason):
      return getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_unable_to_update_password))
    case .resetPasswordError(let reason):
      return getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_unable_to_reset_password))
      
    case .giftCardsError(let reason):
      return getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_retrieving_cards_information))
    case .paymentError(let reason):
      return getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_generating_barcode))
     
    case .findStoresError(let reason):
      return getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_retrieving_stores_information))
      
    case .trackTransactionError(let reason):
      return getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.failed_to_track_transaction))
      
    case .supportRequestError(let reason):
      return getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.failed_to_send_support_request))
      
    case .unacceptableStatusCodeError(let reason, _):
      return reason
    }
  }
  
  public func getErrorMessageFromReason(_ reason: Any?, defaultMessage: String) -> String? {
    var errorMessage: String? = defaultMessage
    
    if let reasonError = reason as? ApiError {
      switch reasonError {
      case .unknown:
        break
      default:
        return reasonError.errorMessage()
      }
    } else if let reasonString = reason as? String {
      return reasonString
    }
    
    return errorMessage
  }
}
