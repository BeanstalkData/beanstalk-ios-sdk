//
//  AvailableRewardsViewController.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import UIKit
import BeanstalkEngageiOSSDK


class AvailableRewardsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
  var rewards: [BECoupon]?
  
  @IBOutlet var tableView: UITableView!
  
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if self.rewards == nil {
      self.loadRewards()
    }
    else {
      self.updateRewards()
    }
  }
  
  
  //MARK: - Private
  
  func loadRewards() {
    self.loadingHandler.showProgress("Retrieving Rewards")
    self.coreService?.getAvailableRewards(handler: { (success, coupons, error) in
      self.loadingHandler.handleError(success: success, error: error)
      self.rewards = coupons
      
      self.updateRewards()
    })
  }
  
  func updateRewards() {
    self.tableView.reloadData()
  }
  
  
  //MARK: - UITableViewDelegate
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
  
  
  //MARK: - UITableViewDataSource
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let rewardsCount = self.rewards?.count {
      return rewardsCount
    }
    
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let identifier = "cell"
    
    let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    
    if let coupon = self.rewards?[indexPath.row] {
      if let titleLabel = cell.contentView.viewWithTag(1) as? UILabel {
        titleLabel.text = coupon.text
      }
    }
    
    return cell
  }
}
