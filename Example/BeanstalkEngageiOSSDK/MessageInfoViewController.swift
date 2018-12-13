//
//  MessageInfoViewController.swift
//  BeanstalkEngageiOSSDK_Example
//
//  Created by Alexander Frolikov on 12/13/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import BeanstalkEngageiOSSDK
import Alamofire
import AlamofireImage

class MessageInfoViewController: UIViewController {
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var ctaLinkButton: UIButton!
  
  private var message: BEPushNotificationMessage?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    updateUI()
  }
  
  func setMessage(_ message: BEPushNotificationMessage) {
    self.message = message
  }
  
  //MARK: - Private
  
  private func updateUI() {
    guard let message = message else { return }
    
    titleLabel.text = message.title
    subtitleLabel.text = message.subtitle
    messageLabel.text = message.messageBody
    ctaLinkButton.titleLabel?.text = message.messageUrl    
    
    guard let url = message.msgImage else {
      return
    }
    
    Alamofire.request(url)
      .responseImage(completionHandler: {[weak self] res in
        self?.imageView?.image = res.result.value
      })
  }
  
  
  @IBAction func ctaLinkAction(_ sender: Any) {
    guard let messageUrl = message?.messageUrl,
      let url = URL(string: messageUrl) else {
        return
    }
    
    if #available(iOS 10.0, *) {
      UIApplication.shared.open(url, options: [:]) { success in
        print(success)
      }
    }
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  
}
