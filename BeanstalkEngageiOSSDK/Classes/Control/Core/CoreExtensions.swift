//
//  CoreExtensions.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import UIKit

import libPhoneNumber_iOS
import PKHUD

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
      return phoneUtil.isValidNumber(forRegion: phoneNumber, regionCode: "US")
    } catch _ as NSError {
    }
    
    return false
  }
  
  public func isValidZipCode() -> Bool{
    let regex = try! NSRegularExpression(pattern: "[0-9]{5}", options: [.caseInsensitive])
    let range = NSRange(location: 0, length: self.characters.count)
    let matches = regex.matches(in: self, options : NSRegularExpression.MatchingOptions(), range: range)
    return matches.count == 1
  }
  
  public func isValidEmail() -> Bool{
    let regex = try! NSRegularExpression(pattern: "[^@]+@[A-Za-z0-9.-]+\\.[A-Za-z]+", options: [])
    let range = NSRange(location: 0, length: self.characters.count)
    let matches = regex.matches(in: self, options : NSRegularExpression.MatchingOptions(), range: range)
    return matches.count == 1
  }
}

