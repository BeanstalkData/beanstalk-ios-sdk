//
//  RegistrationModel.swift
//  Bojangles
//
//  Created by Dmytro Nadtochyy on 11/28/16.
//  Copyright © 2016 Beanstalk Data. All rights reserved.
//

import UIKit

struct RegistrationModel {
  var email: String?
  var password: String?
  var passwordConfirmation: String?

  var firstName: String?
  var lastName: String?
  var mobileNumber: String?
  var birthDate: Date?
  var ageConfirmed: Bool = false
  var termsConfirmed: Bool = false
  var gender: Gender = .Unknown

  var image: UIImage?
  var imageLocalURL: URL?

  var emailOptIn: Bool = true
  var pushOptIn: Bool = false

  // MARK: -

  enum Gender {
    case Unknown
    case Male
    case Female

    func stringValue() -> String {
      var value = ""

      switch self {
      case .Unknown:
        value = "Unknown"
      case .Male:
        value = "Male"
      case .Female:
        value = "Female"
      }

      return value
    }
  }
}
