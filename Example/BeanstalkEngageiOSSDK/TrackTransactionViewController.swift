//
//  TrackTransactionViewController.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import UIKit

class TrackTransactionViewController: BaseViewController, UITextViewDelegate {
  @IBOutlet var textView: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setupSendButton()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    self.textView.becomeFirstResponder()
  }
  
  //MARK: - Actions
  
  @objc func dismissKeyboard() {
    self.textView.resignFirstResponder()
  }
  
  @objc func sendTransaction() {
    guard let text = self.textView.text, text.lengthOfBytes(using: .utf8) > 0 else {
      self.loadingHandler.showMessage("Input Transaction String", message: nil)
      return
    }
    
    weak var weakSelf = self
    self.loadingHandler.showProgress("Sending")
    self.coreService?.trackTransaction(transactionData: text, handler: { (transaction, error) in
      weakSelf?.loadingHandler.hideProgress()
      
      if let err = error {
        weakSelf?.loadingHandler.showMessage(err.errorTitle(), message: err.errorMessage())
      } else {
        weakSelf?.loadingHandler.showMessage(
          "Transaction Tracked",
          message: transaction == nil ? "" : "Transaction Id:\n\(transaction!.transactionId)")
      }
    })
  }
  
  
  //MARK: - Private
  
  private func setupDismissButton() {
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Dismiss",
      style: .done,
      target: self,
      action: #selector(self.dismissKeyboard)
    )
  }
  
  private func setupSendButton() {
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Send",
      style: .plain,
      target: self,
      action: #selector(self.sendTransaction)
    )
  }
  
  //MARK: - UITextViewDelegate
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    self.setupDismissButton()
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    self.setupSendButton()
  }
}
