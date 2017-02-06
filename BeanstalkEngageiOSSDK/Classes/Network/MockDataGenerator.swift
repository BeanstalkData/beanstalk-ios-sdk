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
  
  func getUserOffers () -> CouponResponse<BECoupon> {
    
    let  formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    let today = NSDate()
    
    let calendar = NSCalendar.currentCalendar()
    
    let items = [Int](count: 10, repeatedValue: 0)
    
    let coupons = items.map({ (item)-> BECoupon in
      let c = BECoupon(imageUrl: urls[item % urls.count])
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
  
  private var stores : [BEStore]
  
  init(){
    self.stores = Array()
    
    var store = BEStore(id: "5851a7249616259fa18034c4")
    store.customerId = "318"
    store.storeId = "506"
    store.country = "USA"
    store.address1 = "8521  N. Tryon St"
    store.city = "Charlotte"
    store.state = "NC"
    store.zip = 28262
    store.phone = "704-510-1194"
    store.longitude = "-80.7325287"
    store.latitude = "35.3301529"
    store.geoEnabled = true
    
    self.stores.append(store)
    
    store = BEStore(id: "5851a7449616259fa18034ff")
    store.customerId = "318"
    store.storeId = "768"
    store.country = "USA"
    store.address1 = "10329 Mallard Creek Road"
    store.city = "Charlotte"
    store.state = "NC"
    store.zip = 28262
    store.phone = "704-503-4648"
    store.longitude = "-80.7325287"
    store.latitude = "35.3301529"
    store.geoEnabled = true
    
    self.stores.append(store)
    
    store = BEStore(id: "5851a7319616259fa18034dc")
    store.customerId = "318"
    store.storeId = "609"
    store.country = "USA"
    store.address1 = "7701 Gateway Lane NW"
    store.city = "Concord"
    store.state = "NC"
    store.zip = 28027
    store.phone = "704-979-5347"
    store.longitude = "-80.6548882"
    store.latitude = "35.4002721"
    store.geoEnabled = true
    
    self.stores.append(store)
  }
  
  func failed() -> Bool{
    return false
  }
  
  func getStores() -> [BEStore]? {
    return stores
  }
  
}

private class DummyGCResponse : GiftCardsResponse{
  
  private let cards : [BEGiftCard]
  
  init(count : Int){
    let items  = [Int](count: 4, repeatedValue: 0)
    self.cards = items.map({ (item) -> BEGiftCard in
      let c = BEGiftCard(id : "\(arc4random())",
        number: "\(arc4random())\(arc4random())" ,
        balance: String(format: "$%.2f", Double(arc4random_uniform(500))))
      return c
    })
  }
  
  func failed() -> Bool{
    return false
  }
  
  func getCards() -> [BEGiftCard]?{
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
