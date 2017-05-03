//
//  ContactGeoDataViewController.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import UIKit


class ContactGeoDataViewController: BaseViewController {
  @IBOutlet var latitudeTextField: UITextField!
  @IBOutlet var longitudeTextField: UITextField!
  @IBOutlet var sendButton: UIButton!
  
  
  //MARK: - Actions
  
  @IBAction func sendGeoData() {
    self.view.endEditing(true)
    
    guard let _ = self.coreService else {
      self.loadingHandler.showMessage("No Core Service set", message: nil)
      
      return
    }
    
    guard let latitude = self.latitudeTextField.text, latitude.lengthOfBytes(using: .utf8) > 0 else {
      self.loadingHandler.showMessage("Enter latitude", message: nil)
      
      return
    }
    
    guard let longitude = self.longitudeTextField.text, longitude.lengthOfBytes(using: .utf8) > 0 else {
      self.loadingHandler.showMessage("Enter longitude", message: nil)
      
      return
    }
    
    weak var weakSelf = self
    self.loadingHandler.showProgress("Sending...")
    self.coreService?.relocateContact(
      latitude: latitude,
      longitude: longitude,
      handler: { (success, error) in
        
        weakSelf?.loadingHandler.hideProgress()
        weakSelf?.loadingHandler.handleError(success: success, error: error)
        
        if error == nil {
          weakSelf?.loadingHandler.showMessage("Success", message: "Geo data sent")
        }
    })
  }
}
