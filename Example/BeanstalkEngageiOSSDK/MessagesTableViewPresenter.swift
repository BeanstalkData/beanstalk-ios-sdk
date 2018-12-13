//
//  MessagesTableViewHelper.swift
//  BeanstalkEngageiOSSDK_Example
//
//  Created by Alexander Frolikov on 12/13/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import BeanstalkEngageiOSSDK
import Alamofire
import AlamofireImage

enum MessagesTableViewCellType: Int {
  case json = 0
  case table = 1
}

class MessagesTableViewPresenter: NSObject, UITableViewDelegate, UITableViewDataSource {
  var coreService: ApiService?
  let tableView: UITableView
  private let loadingHandler: LoadingHandlerProtocol
  private var messages:[BEPushNotificationMessage] = []
  private var cellType: MessagesTableViewCellType = MessagesTableViewCellType.json
  
  init(tableView: UITableView, coreService: ApiService?, loadingHandler: LoadingHandlerProtocol) {
    self.tableView = tableView
    self.coreService = coreService
    self.loadingHandler = loadingHandler
    super.init()
    
    tableView.delegate = self
    tableView.dataSource = self
  }

  //MARK: - Actions
  
  func setMessages(_ items:[BEPushNotificationMessage]?) {
    guard let messages = items else { return }
    self.messages = messages
    
    tableView.reloadData()
  }
  
  func loadMessages() {
    self.loadingHandler.showProgress("Loading messages")
    
    self.coreService?.pushNotificationGetMessages(maxResults: 100, handler: {[weak self] (success, messages, error) in
      self?.loadingHandler.handleError(success: success, error: error)
      
      self?.messages = messages ?? []
      self?.tableView.reloadData()
    })
  }
  
  func setCellType(_ type: MessagesTableViewCellType) {
    cellType = type
    
    tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    tableView.reloadData()
  }
  
  func getMessage(cell: UITableViewCell) -> BEPushNotificationMessage? {
    guard let idx = tableView.indexPath(for: cell) else {
      return nil
    }
    
    return messages[idx.row]
  }
  
  // MARK: - UITableViewDelegate, UITableViewDataSource
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return getCell(indexPath: indexPath)
  }
  
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    return cellEditActions(indexPath: indexPath)
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard cellType == .table else { return }
  }
  
  //MARK: - Private

  private func cellEditActions(indexPath: IndexPath) -> [UITableViewRowAction] {
    return [
      UITableViewRowAction(style: .destructive, title: "Mark Deleted", handler: { (action, indexPath) in
        let message = self.messages[indexPath.row]
        guard let messageId = message.messageId else { return }
        
        self.loadingHandler.showProgress("Updating")
        self.coreService?.pushNotificationUpdateStatus(messageId, status: .deleted, handler: {[weak self] (success, msg) in
          self?.loadingHandler.hideProgress()
          
          if success {
            message.status = PushNotificationStatus.deleted.rawValue
          }
          
          self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        })
      })
    ]
  }
  
  private func getCell(indexPath: IndexPath) -> UITableViewCell {
    return cellType == .json ? getJsonCell(indexPath: indexPath) : getTableCell(indexPath: indexPath)
  }
  
  private func getJsonCell(indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "jsonCell", for: indexPath)
    
    let text = cell.contentView.viewWithTag(1) as? UITextView
    let statusLabel = cell.contentView.viewWithTag(4) as? ClickableLabel
    
    let message = messages[indexPath.row]
    
    statusLabel?.isUserInteractionEnabled = true
    
    statusLabel?.onClick = {
      guard let messageId = message.messageId ,
        let status = message.getStatus() else {
          return
      }
      
      let newStatus: PushNotificationStatus = status == .unread ? .read : .unread
      
      self.loadingHandler.showProgress("Updating")
      self.coreService?.pushNotificationUpdateStatus(messageId, status: newStatus, handler: {[weak self] (success, msg) in
        self?.loadingHandler.hideProgress()
        
        if success {
          message.status = newStatus.rawValue
        }
        
        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
      })
    }
    
    
    text?.text = message.debugDescription
    statusLabel?.text = message.status
    
    text?.delegate = self
    
    return cell
  }
  
  private func getTableCell(indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
    cell.reloadInputViews()
    
    let message = messages[indexPath.row]
    
    let titleLabel = cell.contentView.viewWithTag(1) as? UILabel
    titleLabel?.text = message.title
    
    let subtitleLable = cell.contentView.viewWithTag(2) as? UILabel
    subtitleLable?.text = message.subtitle
    
    let messageLabel = cell.contentView.viewWithTag(3) as? UILabel
    messageLabel?.text = message.messageBody

    guard let url = message.msgImage else {
      return cell
    }
    
    let imageView = cell.contentView.viewWithTag(5) as? UIImageView
    
    Alamofire.request(url).responseImage(completionHandler: { res in
      imageView?.image = res.result.value
    })
    
    
    if message.getStatus() == PushNotificationStatus.deleted {
      for view in cell.subviews {
        view.alpha = 0.5
      }
      cell.backgroundColor = UIColor.lightGray
    }
    
    return cell
  }
}

extension MessagesTableViewPresenter: UITextViewDelegate {
  @available(iOS 10.0, *)
  func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    return true
  }
}

class ClickableLabel: UILabel {
  var onClick: () -> Void = {}
  override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    onClick()
  }
}
