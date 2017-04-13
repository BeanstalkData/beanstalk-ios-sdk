//
//  UserProgressViewController.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import UIKit
import BeanstalkEngageiOSSDK


class UserProgressViewController: BaseViewController {
  @IBOutlet var progressValueLabel: UILabel!
  @IBOutlet var progressTextLabel: UILabel!
  
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    self.loadProgress()
  }
  
  
  //MARK: - Private
  
  func loadProgress() {
    
    self.loadingHandler.showProgress("Getting Rewards")
    self.coreService?.getUserProgress(handler: { (success, progressValue, error) in
      self.loadingHandler.hideProgress()
      if let value = progressValue {
        self.progressValueLabel.text = "\(Int(value))"
        self.progressTextLabel.text = nil
      }
      else {
        self.progressValueLabel.text = error?.errorTitle()
        self.progressTextLabel.text = error?.errorMessage()
      }
    })
  }
}
