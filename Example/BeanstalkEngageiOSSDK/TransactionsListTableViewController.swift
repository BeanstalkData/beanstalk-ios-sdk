//
//  TransactionsListTableViewController.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import UIKit
import BeanstalkEngageiOSSDK

class TransactionsListTableViewController: UITableViewController {
  var coreService: ApiService?
  var transactions = [BETransaction]() {
    didSet {
      self.tableView.reloadData()
    }
  }
  
  lazy var loadingHandler: LoadingHandlerProtocol = {
    let handler = LoadingHandler(viewController: self)
    
    return handler
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.estimatedRowHeight = 100.0
  }
  
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    guard let coreService = self.coreService else {
      return
    }
    
    self.loadingHandler.showProgress("Loading")
    weak var weakSelf = self
    coreService.getTransactions(
      startDate: nil,
      endDate: nil) { (transactions, error) in
        
        weakSelf?.loadingHandler.hideProgress()
        
        if let err = error {
          weakSelf?.loadingHandler.showMessage(err)
        } else {
          if let transactions = transactions {
            weakSelf?.transactions = transactions
          }
        }
    }
  }
  
  
  //MARK: -
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.transactions.count
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    
    let transaction = self.transactions[indexPath.row]
    
    (cell.viewWithTag(1) as? UILabel)?.text = transaction.getDateCreated()?.description
    let details = transaction.details as AnyObject
    (cell.viewWithTag(2) as? UILabel)?.text = details.description
    
    return cell
  }
}
