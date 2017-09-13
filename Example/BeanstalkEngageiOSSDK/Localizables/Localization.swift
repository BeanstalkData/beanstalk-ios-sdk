//
//  Localization.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import BeanstalkEngageiOSSDK

func Localized(key: BELocKeyProtocol, capitalize: Bool = false) -> String {
  let localized = BELocalizationImpl.sharedInstance.localizeReplace(key: key, replace: [:], capitalize: capitalize, bundle: Bundle(for: LocalizationImpl.self))
  
  return localized
}

func Localized(key: BELocKeyProtocol, replace: [String: String], capitalize: Bool = false) -> String {
  let localized = BELocalizationImpl.sharedInstance.localizeReplace(key: key, replace: replace, capitalize: capitalize, bundle: Bundle(for: LocalizationImpl.self))
  
  return localized
}

class LocalizationImpl {
}
