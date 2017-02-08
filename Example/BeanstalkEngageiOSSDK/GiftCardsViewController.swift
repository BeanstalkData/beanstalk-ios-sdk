//
//  GiftCardsViewController.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import UIKit
import BeanstalkEngageiOSSDK


class GiftCardsViewController: BaseViewController, CoreProtocol, UITableViewDataSource, UITableViewDelegate {
    var giftCards: [BEGiftCard]?
    
    @IBOutlet var tableView: UITableView!
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.giftCards == nil {
            self.loadGiftCards()
        }
        else {
            self.updateGiftCards()
        }
    }
    
    
    //MARK: - Private
    
    func loadGiftCards() {
        self.coreService?.getGiftCards(self, handler: { (success, giftCards) in
            self.giftCards = giftCards
            
            self.updateGiftCards()
        })
    }
    
    func updateGiftCards() {
        self.tableView.reloadData()
    }
    
    
    //MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    //MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let rewardsCount = self.giftCards?.count {
            return rewardsCount
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "cell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        
        if let giftCard = self.giftCards?[indexPath.row] {
            if let numberLabel = cell.contentView.viewWithTag(1) as? UILabel {
                numberLabel.text = giftCard.getDisplayNumber()
            }
            if let balanceLabel = cell.contentView.viewWithTag(2) as? UILabel {
                balanceLabel.text = giftCard.getDisplayBalanse()
            }
        }
        
        return cell
    }
}
