//
//  SocialNetworksClient.swift
//
//  Copyright © 2018 Beanstalk Data. All rights reserved.
//

struct GoogleUserInfo {
  let user: GIDGoogleUser
  let gender: RegistrationModel.Gender
}


class SocialNetworksClient: NSObject, GIDSignInDelegate {
  static let sharedInstance = SocialNetworksClient()

  private override init() {
    super.init()
    GIDSignIn.sharedInstance().delegate = self
    GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.me")
  }

  private var googleLoginCompletion: ((_ user: GoogleUserInfo?, _ error: Error?) -> Void)?

  func loginWithGoogle(completion: ((_ user: GoogleUserInfo?, _ error: Error?) -> Void)?) {
    GIDSignIn.sharedInstance().signIn()
    googleLoginCompletion = completion
  }

  // GIDSignInDelegate
  public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser, withError error: Error!) {
    if let error = error {
      self.googleLoginCompletion?(nil, error)
      return
    }

    let token = user.authentication.accessToken
    let gplusapi = "https://www.googleapis.com/oauth2/v3/userinfo?access_token=\(token!)"
    let url = URL(string: gplusapi)
    let session = URLSession.shared

    session.dataTask(with: url!) {(data, _, error) -> Void in
      do {
        let userData = try JSONSerialization.jsonObject(with: data!, options:[]) as? [String:AnyObject]
        let genderString = userData!["gender"] as? String

        let userInfo = GoogleUserInfo(user: user, gender: self.genderFromString(genderString))

        DispatchQueue.main.async {
          self.googleLoginCompletion?(userInfo, error)
        }

      } catch {
        NSLog("Account Information could not be loaded")

        let userInfo = GoogleUserInfo(user: user, gender: RegistrationModel.Gender.Unknown)

        DispatchQueue.main.async {
          self.googleLoginCompletion?(userInfo, error)
        }
      }
    }.resume()
  }

  public func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {

  }
  
  // MARK: - Private
  
  private func genderFromString(_ string: String?) -> RegistrationModel.Gender {
    guard let genderString = string?.lowercased() else {
      return RegistrationModel.Gender.Unknown
    }
    
    if genderString == "male" {
      return RegistrationModel.Gender.Male
    }
    
    if genderString == "female" {
      return RegistrationModel.Gender.Female
    }
    
    return RegistrationModel.Gender.Unknown
  }
}
