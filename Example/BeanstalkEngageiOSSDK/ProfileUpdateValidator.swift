//
//  ProfileUpdateValidator.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import UIKit
import BeanstalkEngageiOSSDK


class ProfileUpdateValidator: EditProfileProtocol {
  weak var vc: UIViewController?
  
  var skipHide = false
  
  
  //MARK: - EditProfileProtocol
  
  func showMessage(_ error: BEErrorType) {
    self.vc?.showMessage(error)
  }
  
  func showMessage(_ title: String?, message : String?) {
    self.vc?.showMessage(title, message: message)
  }
  
  func showProgress(_ message: String) {
    self.vc?.showProgress(message)
  }
  
  func hideProgress() {
    if self.skipHide {
      return
    }
    
    self.vc?.hideProgress()
  }
  
  
  //MARK: - EditProfileProtocol
  
  func validate(_ request: ContactRequest) -> Bool {
    return true
  }
}
