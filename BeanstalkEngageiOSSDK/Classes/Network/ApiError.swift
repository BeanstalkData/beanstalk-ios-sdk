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
    var errorTitle: String?
    
    switch self {
    case .unknown:
      errorTitle = Localized(key: BELocKey.error_bad_request_title)
      
    case .dataSerialization(_):
      errorTitle = Localized(key: BELocKey.error_bad_request_title)
    case .missingParameterError(_):
      errorTitle = Localized(key: BELocKey.error_invalid_request_title)
      
    case .network(_):
      errorTitle = Localized(key: BELocKey.error_bad_request_title)
    case .networkConnectionError:
      errorTitle = Localized(key: BELocKey.error_connection_failed_title)
    
    case .noApiUsernameProvided():
      errorTitle = Localized(key: BELocKey.error_no_API_username_provided_title)
      
    case .createContactFailed(_):
      errorTitle = Localized(key: BELocKey.error_create_contact_failed_title)
    case .deleteContactFailed(_):
      errorTitle = Localized(key: BELocKey.error_delete_contact_failed_title)
    case .updateContactFailed(_):
      errorTitle = Localized(key: BELocKey.error_update_contact_failed_title)
    case .fetchContactFailed(_):
      errorTitle = Localized(key: BELocKey.error_fetch_contact_failed_title)
    case .noContactIdInSession():
      errorTitle = Localized(key: BELocKey.error_no_contact_ID_is_stored_in_session_title)
      
    case .authenticationFailed(_):
      errorTitle = Localized(key: BELocKey.login_failed)
    case .registrationFailed(_):
      errorTitle = Localized(key: BELocKey.error_registration_title)
    case .userEmailExists(_):
      errorTitle = Localized(key: BELocKey.error_registration_title)
    case .userPhoneExists(_):
      errorTitle = Localized(key: BELocKey.error_registration_title)
      
    case .profileError(_):
      errorTitle = Localized(key: BELocKey.error_profile_title)
    case .updateProfileError(_):
      errorTitle = Localized(key: BELocKey.error_update_profile_title)
    case .updatePasswordError(_):
      errorTitle = Localized(key: BELocKey.error_password_update_title)
    case .resetPasswordError(_):
      errorTitle = Localized(key: BELocKey.error_password_reset_title)
      
    case .giftCardsError(_):
      errorTitle = Localized(key: BELocKey.error_cards_error_title)
    case .paymentError(_):
      errorTitle = Localized(key: BELocKey.error_payment_title)
      
    case .findStoresError(_):
      errorTitle = Localized(key: BELocKey.error_find_stores_title)
      
    case .trackTransactionError(_):
      errorTitle = Localized(key: BELocKey.error_track_transaction_title)
      
    case .supportRequestError(_):
      errorTitle = Localized(key: BELocKey.error_support_request_title)
      
    case .unacceptableStatusCodeError(_, _):
      errorTitle = Localized(key: BELocKey.error_bad_request_title)
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
      errorMessage = Localized(key: BELocKey.error_sorry_an_error_occurred_while_processing_your_request)
    case .dataSerialization(let reason):
      errorMessage = reason
    case .missingParameterError(let reason):
      errorMessage = Localized(key: BELocKey.error_please_verify_parameters) + ((reason.lengthOfBytes(using: String.Encoding.utf8) > 0) ? ": " + reason : "")
    case .network(let error):
      errorMessage = (error != nil ? error!.localizedDescription : Localized(key: BELocKey.error_sorry_an_error_occurred_while_processing_your_request))
    case .networkConnectionError:
      errorMessage = Localized(key: BELocKey.error_connection_unavailable)
    
    case .noApiUsernameProvided():
      errorMessage = Localized(key: BELocKey.error_api_username_must_be_provided)
      
    case .createContactFailed(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_unknown))
    case .deleteContactFailed(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_failed_to_delete_contact))
    case .updateContactFailed(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_unknown))
    case .fetchContactFailed(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_failed_to_fetch_contact))
    case .noContactIdInSession():
      errorMessage = Localized(key: BELocKey.error_contact_ID_should_be_provided_by_session)
      
    case .authenticationFailed(_):
      errorMessage =  Localized(key: BELocKey.login_failed_text)//getErrorMessageFromReason(reason, defaultMessage: "Username or password incorrect")
    case .registrationFailed(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_unable_to_sign_up_user))
    case .userEmailExists(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_this_email_is_already_registered))
    case .userPhoneExists(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_this_phone_is_already_registered))
      
    case .profileError(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_unable_to_retrieve_profile))
    case .updateProfileError(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_update_failed))
    case .updatePasswordError(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_unable_to_update_password))
    case .resetPasswordError(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_unable_to_reset_password))
      
    case .giftCardsError(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_retrieving_cards_information))
    case .paymentError(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_generating_barcode))
     
    case .findStoresError(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.error_retrieving_stores_information))
      
    case .trackTransactionError(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.failed_to_track_transaction))
      
    case .supportRequestError(let reason):
      errorMessage = getErrorMessageFromReason(reason, defaultMessage: Localized(key: BELocKey.failed_to_send_support_request))
      
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
