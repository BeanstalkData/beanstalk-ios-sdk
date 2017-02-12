//
//  BaseViewController.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import UIKit

import Alamofire
import BeanstalkEngageiOSSDK


class BaseViewController: UIViewController {
    var coreService: ApiService?
    
    var completionBlock: ((success: Bool) -> Void)?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserverForName(
            UIKeyboardWillShowNotification,
            object: nil,
            queue: nil) { (notification) in
                self.keyboardWillChange(notification)
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(
            UIKeyboardWillHideNotification,
            object: nil,
            queue: nil) { (notification) in
                self.keyboardWillHide(notification)
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(
            UIKeyboardWillChangeFrameNotification,
            object: nil,
            queue: nil) { (notification) in
                self.keyboardWillChange(notification)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    //MARK: - Keyboard
    
    internal func keyboardWillChange(notification: NSNotification) {
        
    }
    
    internal func keyboardWillHide(notification: NSNotification) {
        
    }
}
