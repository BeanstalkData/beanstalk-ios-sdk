//
//  UserProgressViewController.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import UIKit
import BeanstalkEngageiOSSDK


class UserProgressViewController: BaseViewController, CoreProtocol {
    @IBOutlet var progressValueLabel: UILabel!
    @IBOutlet var progressTextLabel: UILabel!
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadProgress()
    }
    
    
    //MARK: - Private
    
    func loadProgress() {
        self.coreService?.getUserProgress(self, handler: { (success, progressValue, progressText) in
            self.progressValueLabel.text = "\(progressValue)"
            self.progressTextLabel.text = progressText
        })
    }
}
