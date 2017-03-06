//
//  RegistrationProtocol.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import Foundation

public protocol CoreProtocol {
  func showMessage(_ error: BEErrorType)
  func showMessage(_ title: String?, message : String?)
  func showProgress(_ message: String)
  func hideProgress()
}

public protocol RegistrationProtocol :CoreProtocol {
  func validate(_ request: ContactRequest) -> Bool
}

public protocol EditProfileProtocol :CoreProtocol {
  func validate(_ request: ContactRequest) -> Bool
}

public protocol UpdatePasswordProtocol :CoreProtocol {
  func validate(_ password: String?, confirmPassword: String?) -> Bool
}

public protocol AuthenticationProtocol :CoreProtocol {
  func validate(_ email: String?, password: String?) -> Bool
}
