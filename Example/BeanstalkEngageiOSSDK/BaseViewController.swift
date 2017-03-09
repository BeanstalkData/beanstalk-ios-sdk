//
//  BaseViewController.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import UIKit

import Alamofire
import BeanstalkEngageiOSSDK


class BaseViewController: UIViewController {
  var coreService: ApiService?
  
  var completionBlock: ((_ success: Bool) -> Void)?
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    NotificationCenter.default.addObserver(
      forName: NSNotification.Name.UIKeyboardWillShow,
      object: nil,
      queue: nil) { (notification) in
        self.keyboardWillChange(notification: notification)
    }
    
    NotificationCenter.default.addObserver(
      forName: NSNotification.Name.UIKeyboardWillHide,
      object: nil,
      queue: nil) { (notification) in
        self.keyboardWillHide(notification: notification)
    }
    
    NotificationCenter.default.addObserver(
      forName: NSNotification.Name.UIKeyboardWillShow,
      object: nil,
      queue: nil) { (notification) in
        self.keyboardWillChange(notification: notification)
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    NotificationCenter.default.removeObserver(self)
  }
  
  
  //MARK: - Keyboard
  
  internal func keyboardWillChange(notification: Notification) {
    
  }
  
  internal func keyboardWillHide(notification: Notification) {
    
  }
}
