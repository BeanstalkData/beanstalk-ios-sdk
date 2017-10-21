//
//  BEOpeningDayHour.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 10/21/17.
//
//

import Foundation
public class BEOpeningDayHour: NSObject, NSCoding {
  
  fileprivate static let kOpeningHours = "BEOpeningDayHour_openingHours"
  
  open var openingHours: [BEOpeningHour]
  
  init(_ openingHours: [BEOpeningHour]) {
    self.openingHours = openingHours
  }
  
  //MARK: - NSCoding -
  required public init?(coder aDecoder: NSCoder) {
    guard let openingHoursData = aDecoder.decodeObject(forKey: BEOpeningDayHour.kOpeningHours) as? Data else {
     return nil
    }
    
    guard let openingHours = NSKeyedUnarchiver.unarchiveObject(with: openingHoursData) as?  [BEOpeningHour] else {
      return nil
    }
    
    self.openingHours = openingHours
  }
  
  public func encode(with aCoder: NSCoder) {
    aCoder.encode(NSKeyedArchiver.archivedData(withRootObject: openingHours as NSArray), forKey: BEOpeningDayHour.kOpeningHours)
  }
}
