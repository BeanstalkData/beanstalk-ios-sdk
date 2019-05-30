//
//  EnvironmetConfigurator.swift
//  BeanstalkEngageiOSSDK_Example
//
//  Created by Alexander Frolikov on 5/30/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

class EnvironmetConfigurator {
  let storageEnvKey = "storageEnv"
  let defaultEnv = Environment.stg
  
  static let shared: EnvironmetConfigurator = EnvironmetConfigurator()
  
  func getEnviromentList() -> [Environment] {
    return [.stg, .prod]
  }
  
  func getConfiguration(env: Environment) -> IConfiguration {
    switch env {
    case .stg:
      return StgConfiguration()
    case .prod:
      return ProdConfiguration()
    }
  }
  
  func getCurrentEnv() -> Environment {
    let storage = UserDefaults.standard
    guard  let savedKey = storage.string(forKey: storageEnvKey) else {
      return defaultEnv
    }
    
    return Environment(rawValue: savedKey) ?? defaultEnv
  }
  
  func setEnvironment(env: Environment) {
    let storage = UserDefaults.standard
    storage.setValue(env.rawValue, forKey: storageEnvKey)
    storage.synchronize()
  }
}
