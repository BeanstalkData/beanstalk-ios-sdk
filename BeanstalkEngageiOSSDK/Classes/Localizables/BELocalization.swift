//
//  BELocalization.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation

func Localized(key: BELocKeyProtocol, capitalize: Bool = false) -> String {
  let localized = BELocalizationImpl.sharedInstance.localizeReplace(key: key, replace: [:], capitalize: capitalize, bundle: Bundle(for: BELocalizationImpl.self))
  
  return localized
}

func Localized(key: BELocKeyProtocol, replace: [String: String], capitalize: Bool = false) -> String {
  let localized = BELocalizationImpl.sharedInstance.localizeReplace(key: key, replace: replace, capitalize: capitalize, bundle: Bundle(for: BELocalizationImpl.self))
  
  return localized
}

public class BELocalizationImpl {
  public static let sharedInstance = BELocalizationImpl()
  
  static let notFoundValue = "$$(_not_found_value_)"
  
  public func localizeReplace(key: BELocKeyProtocol, replace: [String: String] = [:], capitalize: Bool = false, bundle: Bundle) -> String {
    //  Uncomment for localization debug
    //  return key.rawValue
    
    var string = NSLocalizedString(key.getRawValue(), bundle: bundle, value: BELocalizationImpl.notFoundValue, comment: "")
    
    string = string.replacingOccurrences(of: BELocalizationImpl.notFoundValue, with: "")
    
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
