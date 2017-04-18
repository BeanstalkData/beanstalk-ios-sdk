//
//  BETransaction.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import ObjectMapper


public struct BETransaction: Mappable {
  public var transactionId: String = ""
  public var status: String?
  public var details: Any?
  private var dateCreatedValue: BETransactionDate?
  private var dateModifiedValue: BETransactionDate?
  
  
  public init?(map: Map) {
    var valid = false
    
    var idStr: String?
    idStr <- map["id"]
    if let id = idStr, id.lengthOfBytes(using: .utf8) > 0 {
      valid = true
    }
    else {
      var idInfoVal: [String: Any]?
      idInfoVal <- map["_id"]
      
      if let id = idInfoVal?["$id"] as? String, id.lengthOfBytes(using: .utf8) > 0 {
        valid = true
      }
    }
    
    if !valid {
      return nil
    }
  }
  
  // for mock usage only
  init(transactionId: String) {
    self.transactionId = transactionId
  }
  
  public mutating func mapping(map: Map) {
    var idStr: String?
    idStr <- map["id"]
    if let id = idStr, id.lengthOfBytes(using: .utf8) > 0 {
      transactionId = id
    }
    else {
      var idInfoVal: [String: Any]?
      idInfoVal <- map["_id"]
      
      if let id = idInfoVal?["$id"] as? String, id.lengthOfBytes(using: .utf8) > 0 {
        transactionId = id
      }
    }
    status <- map["Status"]
    details <- map["Details"]
    dateCreatedValue <- map["Date"]
    dateModifiedValue <- map["LastModified"]
  }
  
  
  //MARK: - Public
  
  public func getDateCreated() -> Date? {
    return self.dateCreatedValue?.getDate()
  }
  
  public func getDateModified() -> Date? {
    return self.dateModifiedValue?.getDate()
  }
  
  public func getDateCreatedOriginal() -> Any? {
    return self.dateCreatedValue?.originalValue
  }
  
  public func getDateModifiedOriginal() -> Any? {
    return self.dateModifiedValue?.originalValue
  }
}


private struct BETransactionDate: Mappable {
  var dateValue: String?
  var timezoneType: Int?
  var timezone: String?
  var originalValue: Any?
  
  fileprivate static var dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ssZZZZZ"
    
    return dateFormatter
  }()
  
  init?(map: Map) {
    
  }
  
  fileprivate mutating func mapping(map: Map) {
    originalValue = map.JSON
    dateValue <- map["date"] // "2017-04-18 09:54:43"
    timezoneType <- map["timezone_type"]
    timezone <- map["timezone"] // "+00:00"
  }
  
  fileprivate func getDate() -> Date? {
    guard let dateString = self.dateValue else {
      return nil
    }
    
    guard let timezoneString = self.timezone else {
      return nil
    }
    
    let fullDateString = "\(dateString)\(timezoneString)"
    
    return BETransactionDate.dateFormatter.date(from: fullDateString)
  }
}
