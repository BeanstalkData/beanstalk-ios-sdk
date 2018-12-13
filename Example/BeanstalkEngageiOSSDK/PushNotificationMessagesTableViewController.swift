//
//  PushNotificationMessagesTableViewController.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import UIKit
import BeanstalkEngageiOSSDK

class PushNotificationMessagesTableViewController: UIViewController {
  
  @IBOutlet weak var segmentControl: UISegmentedControl!
  @IBOutlet var tableView: UITableView!
  var coreService: ApiService?
  var contactId: String?
  
  var presenter: MessagesTableViewPresenter?
  
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
    
    presenter = MessagesTableViewPresenter(tableView: tableView,
                                           coreService: coreService,
                                           loadingHandler: loadingHandler)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    guard contactId != nil else { return }    
    presenter?.loadMessages()
  }
  
  @IBAction func segmentControlIndexCahngedAction(_ sender: Any) {
    guard let type = MessagesTableViewCellType(rawValue: segmentControl.selectedSegmentIndex) else {
      return
    }
    
    presenter?.setCellType(type)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "messageInfo" {
      guard let nextViewController = segue.destination as? MessageInfoViewController,
        let cell = sender as? UITableViewCell,
        let message = presenter?.getMessage(cell: cell) else {
          return
      }
      
      nextViewController.setMessage(message)
    }
  }
}

extension BEPushNotificationMessage: CustomDebugStringConvertible {
  public var debugDescription: String {
    let desc = self.map?.JSON.debugDescription
    
    return desc ?? ""
  }
}
