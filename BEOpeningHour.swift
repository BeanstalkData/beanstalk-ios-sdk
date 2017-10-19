//
//  BEOpeningHour.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 10/18/17.
//
//

import Foundation

public class BEOpeningHour: NSObject, NSCoding {
  fileprivate static let kDayOfWeek = "BEOpeningHour_dayOfWeek"
  fileprivate static let kFromHour = "BEOpeningHour_fromHour"
  fileprivate static let kFromMinute = "BEOpeningHour_fromMinute"
  fileprivate static let kToHour = "BEOpeningHour_toHour"
  fileprivate static let kToMinute = "BEOpeningHour_toMinute"
  
  open let dayOfWeek: Int
  open let fromHour: Int
  open let fromMinute: Int
  open let toHour: Int
  open let toMinute: Int
  
  init(dayOfWeek: Int, fromHour: Int, fromMinute: Int, toHour: Int, toMinute: Int) {
    self.dayOfWeek = dayOfWeek
    self.fromHour = fromHour
    self.fromMinute = fromMinute
    self.toHour = toHour
    self.toMinute = toMinute
  }
  
  //MARK: - NSCoding -
  required public init?(coder aDecoder: NSCoder) {
    guard let dayOfWeek = aDecoder.decodeObject(forKey: BEOpeningHour.kDayOfWeek) as? Int,
      let fromHour = aDecoder.decodeObject(forKey: BEOpeningHour.kFromHour) as? Int,
      let fromMinute = aDecoder.decodeObject(forKey: BEOpeningHour.kFromMinute) as? Int,
      let toHour = aDecoder.decodeObject(forKey: BEOpeningHour.kToHour) as? Int,
      let toMinute = aDecoder.decodeObject(forKey: BEOpeningHour.kToMinute) as? Int else {
        return nil
    }
    
    self.dayOfWeek = dayOfWeek
    self.fromHour = fromHour
    self.fromMinute = fromMinute
    self.toMinute = toMinute
    self.toHour = toHour
  }
  
  public func encode(with aCoder: NSCoder) {
    aCoder.encode(dayOfWeek, forKey: BEOpeningHour.kDayOfWeek)
    aCoder.encode(fromHour, forKey: BEOpeningHour.kFromHour)
    aCoder.encode(fromMinute, forKey: BEOpeningHour.kFromMinute)
    aCoder.encode(toHour, forKey: BEOpeningHour.kToHour)
    aCoder.encode(toMinute, forKey: BEOpeningHour.kToMinute)
  }
}
