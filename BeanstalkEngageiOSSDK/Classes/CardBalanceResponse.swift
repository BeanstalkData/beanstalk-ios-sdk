//
//  CardBalanceResponse.swift
//  BeanstalkEngageiOSSDK
//
//  2016 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public protocol GiftCardBalanceResponse{
    func getCardBalance() -> String
}
public class GCBResponse : Mappable, GiftCardBalanceResponse {
    private var status : Bool?
    
    private var response : GCBDataResponse?
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        status <- map["status"]
        response <- map["success"]
    }
    
    
    public func getCardBalance() -> String{
        let amount = response?.message?.response?.cardBalance?.balanceAmount?.amount
        if amount == nil {
            return GiftCard.kDefaultBalance
        }else {
            return String(format : "$%.2f", amount!)
        }
    }
}

public class GCBDataResponse : Mappable{
    
    var code : Int?
    var message : GCBDataMessage?
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        code <- map["code"]
        message <- map["message"]
    }
}

public class GCBDataMessage : Mappable {
    var response : GCBMResponse?
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        response <- map["response"]
    }
}

public class GCBMResponse : Mappable{
    var message : String?
    var cardBalance : GiftCardBalance?
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        message <- map["message"]
        cardBalance <- map["balanceInquiryReturn"]
    }
}

public class GiftCardBalance : Mappable {

    var balanceAmount: BalanceAmount?
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        balanceAmount <- map["balanceAmount"]
    }
}

public class BalanceAmount : Mappable {
    
    var amount: Double?
    
    required public init?(_ map: Map) {
    
    }
    
    public func mapping(map: Map) {
        amount <- map["amount"]
    }
}
