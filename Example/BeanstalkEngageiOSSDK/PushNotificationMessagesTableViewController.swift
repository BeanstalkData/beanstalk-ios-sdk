//
//  PushNotificationMessagesTableViewController.swift
//  BeanstalkEngageiOSSDK
//
//  Created by Dmytro Nadtochyy on 3/17/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import BeanstalkEngageiOSSDK


class PushNotificationMessagesTableViewController: UITableViewController, CoreProtocol {
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
  
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if let contactId = self.contactId {
      self.showProgress("Loading messages")
      
      weak var weakSelf = self
      self.coreService?.pushNotificationGetMessages(contactId, maxResults: 100, handler: { (messages, error) in
        weakSelf?.hideProgress()
        
        if let err = error {
          self.showMessage(err)
        }
        else {
          self.messages = messages
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
    
    let titleLabel = cell.contentView.viewWithTag(1) as? UILabel
    let subtitleLabel = cell.contentView.viewWithTag(2) as? UILabel
    let updatedLabel = cell.contentView.viewWithTag(3) as? UILabel
    let statusLabel = cell.contentView.viewWithTag(4) as? UILabel
    
    if let message = self.messages?[indexPath.row] {
      titleLabel?.text = message.title
      subtitleLabel?.text = message.subtitle
      if let date = message.updatedDate() {
        updatedLabel?.text = self.dateFormatter.string(from: date)
      }
      else {
        updatedLabel?.text = nil
      }
      statusLabel?.text = message.status
    }
    else {
      titleLabel?.text = nil
      subtitleLabel?.text = nil
      updatedLabel?.text = nil
      statusLabel?.text = nil
    }
    
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
    
    self.showProgress("Updating")
    self.coreService?.pushNotificationUpdateStatus(messageId, status: new, handler: { (success, msg) in
      weakSelf?.hideProgress()
      
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
        
        self.showProgress("Updating")
        self.coreService?.pushNotificationUpdateStatus(messageId, status: .deleted, handler: { (success, msg) in
          weakSelf?.hideProgress()
          
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
