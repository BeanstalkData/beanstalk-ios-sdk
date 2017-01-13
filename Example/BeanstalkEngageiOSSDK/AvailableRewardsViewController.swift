//
//  AvailableRewardsViewController.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import UIKit
import BeanstalkEngageiOSSDK


class AvailableRewardsViewController: BaseViewController, CoreProtocol, UITableViewDataSource, UITableViewDelegate {
    var rewards: [BECoupon]?
    
    @IBOutlet var tableView: UITableView!
    
    
    override func viewDidAppear(animated: Bool) {
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
        self.coreService?.getAvailableRewards(self, handler: { (coupons) in
            self.rewards = coupons
            
            self.updateRewards()
        })
    }
    
    func updateRewards() {
        self.tableView.reloadData()
    }
    
    
    //MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    //MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let rewardsCount = self.rewards?.count {
            return rewardsCount
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "cell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        
        if let coupon = self.rewards?[indexPath.row] {
            if let titleLabel = cell.contentView.viewWithTag(1) as? UILabel {
                titleLabel.text = coupon.text
            }
        }
        
        return cell
    }
}
