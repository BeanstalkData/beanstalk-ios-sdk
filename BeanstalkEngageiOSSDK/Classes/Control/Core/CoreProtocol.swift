//
//  RegistrationProtocol.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import Foundation

public protocol CoreProtocol {
  func showMessage(error: ApiError)
  func showMessage(title: String?, message : String?)
  func showProgress(message: String)
  func hideProgress()
}

public protocol RegistrationProtocol :CoreProtocol {
  func validate(request: CreateContactRequest) -> Bool
}

public protocol EditProfileProtocol :CoreProtocol {
  func validate(request: UpdateContactRequest) -> Bool
}

public protocol UpdatePasswordProtocol :CoreProtocol {
  func validate(password: String?, confirmPassword: String?) -> Bool
}

public protocol AuthenticationProtocol :CoreProtocol {
  func validate(email: String?, password: String?) -> Bool
}
