//
//  PushNotificationMessagesTableViewController.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import UIKit
import BeanstalkEngageiOSSDK


class PushNotificationMessagesTableViewController: UITableViewController {
  var coreService: ApiService?
  var contactId: String?
  var messages: [BEPushNotificationMessage]? {
    didSet {
      self.tableView.reloadData()
    }
  }
  
  let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    
    return formatter
  }()
  
  lazy var loadingHandler: LoadingHandlerProtocol = {
    let handler = LoadingHandler(viewController: self)
    
    return handler
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 60.0
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if let _ = self.contactId {
      self.loadingHandler.showProgress("Loading messages")
      
      weak var weakSelf = self
      self.coreService?.pushNotificationGetMessages(maxResults: 100, handler: { (success, messages, error) in
        weakSelf?.loadingHandler.handleError(success: success, error: error)
        
        if error == nil {
          weakSelf?.messages = messages
        }
      })
    }
  }
  
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let count = self.messages?.count {
      return count
    }
    
    return 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    
    let text = cell.contentView.viewWithTag(1) as? UITextView
    let statusLabel = cell.contentView.viewWithTag(4) as? UILabel
    
    if let message = self.messages?[indexPath.row] {
      text?.text = message.debugDescription
      statusLabel?.text = message.status
    }
    else {
      text?.text = nil
      statusLabel?.text = nil
    }
    
    text?.delegate = self
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let message = self.messages?[indexPath.row] else {
      return
    }
    
    guard let status = message.getStatus() else {
      return
    }
    
    var newStatus: PushNotificationStatus?
    
    switch status {
    case .read:
      newStatus = .unread
    case .unread:
      newStatus = .read
    case .deleted:
      newStatus = .unread
    }
    
    guard let new = newStatus else {
      return
    }
    
    guard let messageId = message.messageId else {
      return
    }
    
    weak var weakSelf = self
    
    self.loadingHandler.showProgress("Updating")
    self.coreService?.pushNotificationUpdateStatus(messageId, status: new, handler: { (success, msg) in
      weakSelf?.loadingHandler.hideProgress()
      
      if success {
        message.status = new.rawValue
      }
      
      weakSelf?.tableView.deselectRow(at: indexPath, animated: true)
      
      weakSelf?.tableView.reloadRows(at: [indexPath], with: .fade)
    })
  }
  
  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    return [
      UITableViewRowAction(style: .destructive, title: "Mark Deleted", handler: { (action, indexPath) in
        guard let message = self.messages?[indexPath.row] else {
          return
        }
        
        guard let messageId = message.messageId else {
          return
        }
        
        weak var weakSelf = self
        
        self.loadingHandler.showProgress("Updating")
        self.coreService?.pushNotificationUpdateStatus(messageId, status: .deleted, handler: { (success, msg) in
          weakSelf?.loadingHandler.hideProgress()
          
          if success {
            message.status = PushNotificationStatus.deleted.rawValue
          }
          
          weakSelf?.tableView.reloadRows(at: [indexPath], with: .automatic)
        })
      })
    ]
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
}

extension PushNotificationMessagesTableViewController: UITextViewDelegate {
  @available(iOS 10.0, *)
  func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    return true
  }
}


extension BEPushNotificationMessage: CustomDebugStringConvertible {
  public var debugDescription: String {
    let desc = self.map?.JSON.debugDescription
    
    return desc ?? ""
  }
}
