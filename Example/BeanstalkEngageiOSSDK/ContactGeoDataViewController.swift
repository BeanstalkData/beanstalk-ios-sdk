//
//  ContactGeoDataViewController.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import UIKit
import BeanstalkEngageiOSSDK


class ContactGeoDataViewController: BaseViewController {
  @IBOutlet var latitudeTextField: UITextField!
  @IBOutlet var longitudeTextField: UITextField!
  @IBOutlet var sendButton: UIButton!
  @IBOutlet var getButton: UIButton!
  
  
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
  
  @IBAction func getGeoData() {
    guard let _ = self.coreService else {
      self.loadingHandler.showMessage("No Core Service set", message: nil)
      
      return
    }
    
    weak var weakSelf = self
    self.loadingHandler.showProgress("Loading...")
    self.coreService?.getContactGeoAssets(handler: { (response, error) in
      weakSelf?.loadingHandler.hideProgress()
      weakSelf?.loadingHandler.handleError(success: response != nil, error: error)
      
      guard let response = response, error == nil else {
        return
      }
      
      weakSelf?.presentGeoAssets(response: response)
    })
  }
  
  @IBAction func startLocationTracking() {
    self.coreService?.locationTracker?.startLocationTracking()
    
    self.coreService?.locationTracker?.onDidChangePermissions = { (granted) in
      
    }
    self.coreService?.locationTracker?.onDidFail = { (error) in
      NSLog("error: \(error)\n\n")
    }
  }
  
  @IBAction func stopLocationTracking() {
    self.coreService?.locationTracker?.stopLocationTracking()
    
    self.coreService?.subscribeForLocationTracking(relocateContactHandler: { _ in })
  }
  
  
  //MARK: - Private
  
  func presentGeoAssets(response: ContactGeoAssetsResponse) {
    var assets = [(String, String)]()
    
    if let defaultUrl = response.defaultImageUrl {
      if defaultUrl.lengthOfBytes(using: .utf8) > 0 {
        assets.append(("Default", defaultUrl))
      }
    }
    if let currentUrl = response.currentImageUrl {
      if currentUrl.lengthOfBytes(using: .utf8) > 0 {
        assets.append(("Current", currentUrl))
      }
    }
    
    guard assets.count > 0 else {
      self.loadingHandler.showMessage("", message: "No geo data available for this contact")
      
      return
    }
    
    let actionSheet = UIAlertController(
      title: "Select Asset",
      message: nil,
      preferredStyle: .actionSheet
    )
    
    weak var weakSelf = self
    for asset in assets {
      actionSheet.addAction(UIAlertAction(
        title: asset.0,
        style: .default,
        handler: { (action) in
          weakSelf?.openGeoAsset(url: asset.1, title: asset.0)
      }))
    }
    
    actionSheet.addAction(UIAlertAction(
      title: "Dismiss",
      style: .cancel,
      handler: nil
    ))
    
    self.present(actionSheet, animated: true)
  }
  
  func openGeoAsset(url: String, title: String) {
    guard let URL = URL(string: url) else {
      return
    }
    
    let webViewController = UIViewController()
    webViewController.title = title
    
    let webView = UIWebView()
    
    webViewController.view.addSubview(webView)
    
    webView.frame = webViewController.view.bounds
    webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    self.navigationController?.pushViewController(webViewController, animated: true)
    
    let request = URLRequest(url: URL)
    webView.loadRequest(request)
  }
}
