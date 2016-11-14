//
//  ProfileViewController.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import UIKit
import BeanstalkEngageiOSSDK


class ProfileViewController: BaseViewController, CoreProtocol {
    var contact: Contact?
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.contact == nil {
            self.loadProfile()
        }
        else {
            self.updateProfile()
        }
    }
    
    
    //MARK: - Private
    
    func loadProfile() {
        self.coreService?.getContact(self, handler: { (contact) in
            if contact != nil {
                self.contact = contact
                
                self.updateProfile()
            }
        })
    }
    
    func updateProfile() {
        if let firstName = self.contact?.firstName {
            if let lastName = self.contact?.lastName {
                self.nameLabel.text = "\(firstName) \(lastName)"
            }
        }
        
        self.emailLabel.text = self.contact?.email
    }
}
