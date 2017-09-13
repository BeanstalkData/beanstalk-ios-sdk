//
//  BELocalization.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation

func Localized(key: BELocKeyProtocol, capitalize: Bool = false) -> String {
  let localized = BELocalizationImpl.sharedInstance.localizeReplace(key: key, replace: [:], capitalize: capitalize)
  
  return localized
}

func Localized(key: BELocKeyProtocol, replace: [String: String], capitalize: Bool = false) -> String {
  let localized = BELocalizationImpl.sharedInstance.localizeReplace(key: key, replace: replace, capitalize: capitalize)
  
  return localized
}

class BELocalizationImpl {
  static let sharedInstance = BELocalizationImpl()
  
  fileprivate func localizeReplace(key: BELocKeyProtocol, replace: [String: String] = [:], capitalize: Bool = false) -> String {
    //  Uncomment for localization debug
    //  return key.rawValue
    
    var string = NSLocalizedString(key.getRawValue(), bundle: Bundle(for: BELocalizationImpl.self), comment: "")
    
    for (replaceKey, replaceValue) in replace {
      string = string.replacingOccurrences(of: "$(\(replaceKey))", with: replaceValue)
    }
    
    if string.lengthOfBytes(using: .utf8) > 0 {
      if capitalize {
        string = string.uppercased(with: Locale.current)
      }
      
      return string
    }
    else {
      return key.getRawValue()
    }
  }
}
