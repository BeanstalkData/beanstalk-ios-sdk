//
//  DummyDataGenerator.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import Foundation

class MockDataGenerator {
    
    var urls = [
        "http://d1ivierdlu2fd9.cloudfront.net/260/30152.png",
        "http://d1ivierdlu2fd9.cloudfront.net/260/30153.png",
        "http://d1ivierdlu2fd9.cloudfront.net/260/30154.png",
        "http://d1ivierdlu2fd9.cloudfront.net/260/30155.png"];
    
    func getUserOffers () -> CouponResponse {

        let  formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let today = NSDate()
        
        let calendar = NSCalendar.currentCalendar()
        
        let items = [Int](count: 10, repeatedValue: 0)
        
        let coupons = items.map({ (item)->Coupon in
            let c = Coupon(imageUrl: urls[item % urls.count])
            c.text = "Description text \(item)"
            c.number = "\(item)\(item)\(item)\(item)\(item)\(item)\(item)\(item)\(item)\(item)"
            
            let date = calendar.dateByAddingUnit(
                .Day,
                value: 1,
                toDate: today,
                options: NSCalendarOptions(rawValue: 0))
            c.expiration = formatter.stringFromDate(date!)
            return c
        })
        return CouponResponse(coupons: coupons)
    }
    
    func getUserProgress() -> RewardsCountResponse {
        
        let items = [Int](count: 4, repeatedValue: 0)
        
        let coupons = items.map({ (item)->Category in
            let c = Category(count : 1)
            return c
        })
        return RewardsCountResponse(categories: coupons)
    }
    
    func getUserGiftCards() -> GiftCardsResponse {
        return DummyGCResponse(count : 4)
    }
    
    func getUserGiftCardBalance() -> GiftCardBalanceResponse{
        return DummyGCBResponse();
    }
    
    func getUserPayment() -> PaymentResponse {
        return PaymentResponse(token : "\(arc4random_uniform(10))")
    }
  
  func getStores() -> StoresResponseProtocol {
    return DummyStoresResponse()
  }
}

private class DummyStoresResponse: StoresResponseProtocol {
  
  private var stores : [Store]
  
  init(){
    self.stores = Array()
    
    var store = Store(id: "1298129837189273")
    store.customerId = "123"
    store.storeId = "1234"
    store.storeName = "MT VERNON & HWY 178"
    store.country = "USA"
    store.address1 = "2659 Mt. Vernon Ave."
    store.address2 = ""
    store.city = "Bakersfield"
    store.state = "CA"
    store.zip = "93306"
    store.phone = "661-555-1234"
    store.fax = "661-555-1324"
    store.concept = "Panda Express"
    store.venue = "Street DT"
    store.subVenue = "Free Standing"
    store.region = "CCA"
    store.regionName = "CENTRAL CALIFORNIA"
    store.longitude = "-118.93041"
    store.latitude = "35.390652"
    store.geoEnabled = "1"
    
    self.stores.append(store)
    
    store = Store(id: "1298129837189273")
    store.customerId = "123"
    store.storeId = "1234"
    store.storeName = "***REMOVED*** #960"
    store.country = "USA"
    store.address1 = "2659 Mt. Vernon Ave."
    store.address2 = ""
    store.city = "Bakersfield"
    store.state = "CA"
    store.zip = "93306"
    store.phone = "661-555-1234"
    store.fax = "661-555-1324"
    store.concept = "Panda Express"
    store.venue = "Street DT"
    store.subVenue = "Free Standing"
    store.region = "CCA"
    store.regionName = "CENTRAL CALIFORNIA"
    store.longitude = "-118.93041"
    store.latitude = "35.390652"
    store.geoEnabled = "1"
    
    self.stores.append(store)
    
    store = Store(id: "1298129837189273")
    store.customerId = "123"
    store.storeId = "1234"
    store.storeName = "***REMOVED*** #961"
    store.country = "USA"
    store.address1 = "2659 Mt. Vernon Ave."
    store.address2 = ""
    store.city = "Bakersfield"
    store.state = "CA"
    store.zip = "93306"
    store.phone = "661-555-1234"
    store.fax = "661-555-1324"
    store.concept = "Panda Express"
    store.venue = "Street DT"
    store.subVenue = "Free Standing"
    store.region = "CCA"
    store.regionName = "CENTRAL CALIFORNIA"
    store.longitude = "-118.93041"
    store.latitude = "35.390652"
    store.geoEnabled = "1"
    
    self.stores.append(store)
  }
  
  func failed() -> Bool{
    return false
  }
  
  func getStores() -> [Store]? {
    return stores
  }
  
}

private class DummyGCResponse : GiftCardsResponse{
    
    private let cards : [GiftCard]
    
    init(count : Int){
        let items  = [Int](count: 4, repeatedValue: 0)
        self.cards = items.map({ (item)->GiftCard in
            let c = GiftCard(id : "\(arc4random())",
                number: "\(arc4random())\(arc4random())" ,
                balance: String(format: "$%.2f", Double(arc4random_uniform(500))))
            return c
        })
    }
    
    func failed() -> Bool{
        return false
    }
    
    func getCards() -> [GiftCard]?{
        return cards;
    }
}

private class DummyGCBResponse : GiftCardBalanceResponse{
    
    private let balance : String
    init(){
        self.balance = String(format: "$%.2f", Double(arc4random_uniform(500)))
    }
    
    func getCardBalance() -> String {
        return balance;
    }
}
