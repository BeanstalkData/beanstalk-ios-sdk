//
//  CoreExtensions.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import UIKit

import libPhoneNumber_iOS
import PKHUD


// MARK:  Public String Extensions

extension String {
  
  public func formatPhoneNumberToNational() -> String! {
    var formattedPhone = self
    
    let phoneUtil = NBPhoneNumberUtil()
    do {
      let phoneNumber = try phoneUtil.parse(formattedPhone, defaultRegion: "US")
      formattedPhone = try phoneUtil.format(phoneNumber, numberFormat: .NATIONAL)
    } catch _ as NSError {
    }
    
    return formattedPhone
  }
  
  public func formatPhoneNumberToNationalSignificant() -> String! {
    var formattedPhone = self
    
    let phoneUtil = NBPhoneNumberUtil()
    do {
      let phoneNumber = try phoneUtil.parse(formattedPhone, defaultRegion: "US")
      formattedPhone = try phoneUtil.getNationalSignificantNumber(phoneNumber)
    } catch _ as NSError {
    }
    
    return formattedPhone
  }
  
  public func isValidPhone() -> Bool{
    let phoneUtil = NBPhoneNumberUtil()
    do {
      let phoneNumber = try phoneUtil.parse(self, defaultRegion: "US")
      return phoneUtil.isValidNumberForRegion(phoneNumber, regionCode: "US")
    } catch _ as NSError {
    }
    
    return false
  }
  
  public func isValidZipCode() -> Bool{
    let regex = try! NSRegularExpression(pattern: "[0-9]{5}", options: [.CaseInsensitive])
    let range = NSRange(location: 0, length: self.characters.count)
    let matches = regex.matchesInString(self, options : NSMatchingOptions(), range: range)
    return matches.count == 1
  }
  
  public func isValidEmail() -> Bool{
    let regex = try! NSRegularExpression(pattern: "[^@]+@[A-Za-z0-9.-]+\\.[A-Za-z]+", options: [])
    let range = NSRange(location: 0, length: self.characters.count)
    let matches = regex.matchesInString(self, options : NSMatchingOptions(), range: range)
    return matches.count == 1
  }
}



// MARK:  Public UIViewController Extensions

extension UIViewController {
  
  public func showMessage(error: ApiError) {
    var title = error.errorTitle()
    var message = error.errorMessage()
    self.showMessage(title, message: message)
  }
  
  public func showMessage(title: String?, message : String?){
    let alertController = UIAlertController(title: title, message:
      message, preferredStyle: UIAlertControllerStyle.Alert)
    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
    
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
  public func showProgress(message : String){
    debugPrint("showProgress()")
    PKHUD.sharedHUD.show()
    PKHUD.sharedHUD.contentView = PKHUDTextView(text: message)
  }
  
  public func hideProgress(){
    debugPrint("hideProgress()")
    PKHUD.sharedHUD.hide()
  }
}
