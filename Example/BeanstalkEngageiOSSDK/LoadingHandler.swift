//
//  LoadingHandler.swift
//  BeanstalkEngageiOSSDK
//
//  Created by Pavel Dvorovenko on 4/13/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import BeanstalkEngageiOSSDK
import PKHUD

class LoadingHandler: LoadingHandlerProtocol {
  weak var viewController: UIViewController?
  
  init(viewController: UIViewController?) {
    self.viewController = viewController
  }
  
  //MARK: - LoadingHandlerProtocol
  
  func handleError(success: Bool, error: BEErrorType?) {
    self.hideProgress()
    if !success {
      if error != nil {
        self.showMessage(error!)
      } else {
        self.showMessage(ApiError.unknown())
      }
    }
  }
  
  func showMessage(_ error: BEErrorType) {
    let title = error.errorTitle()
    let message = error.errorMessage()
    self.showMessage(title, message: message)
  }
  
  func showMessage(_ title: String?, message : String?) {
    let alertController = UIAlertController(title: title, message:
      message, preferredStyle: UIAlertController.Style.alert)
    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
    
    self.viewController?.present(alertController, animated: true, completion: nil)
  }
  
  func showProgress(_ message: String) {
    PKHUD.sharedHUD.show()
    PKHUD.sharedHUD.contentView = PKHUDTextView(text: message)
  }
  
  func hideProgress() {    
    PKHUD.sharedHUD.hide()
  }
}
