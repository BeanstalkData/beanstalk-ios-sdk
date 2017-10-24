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
  
  fileprivate static let kClosedHours = -1
  
  /** dayOfWeek = day of the week –
      1 – Sunday
      2 – Monday
      3 – Tuesday
      4 – Wednesday
      5 – Thursday
      6 – Friday
      7 – Saturday
  */
  open let dayOfWeek: Int
  // fromHour:fromMinute = opening time in 24-hour format
  open let fromHour: Int
  open let fromMinute: Int
  // toHour:toMinute = closing time in 24-hour format
  open let toHour: Int
  open let toMinute: Int
  
  init(dayOfWeek: Int, fromHour: Int, fromMinute: Int, toHour: Int, toMinute: Int) {
    self.dayOfWeek = dayOfWeek
    self.fromHour = fromHour
    self.fromMinute = fromMinute
    self.toHour = toHour
    self.toMinute = toMinute
  }
  
  init(closedDayOfWeek dayOfWeek: Int) {
    self.dayOfWeek = dayOfWeek
    self.fromHour = BEOpeningHour.kClosedHours
    self.fromMinute = BEOpeningHour.kClosedHours
    self.toHour = BEOpeningHour.kClosedHours
    self.toMinute = BEOpeningHour.kClosedHours
  }
  
  open func isClosed() -> Bool {
    return (self.fromHour == BEOpeningHour.kClosedHours)
  }
  
  //MARK: - NSCoding -
  required public init?(coder aDecoder: NSCoder) {
    let dayOfWeek = aDecoder.decodeInt32(forKey: BEOpeningHour.kDayOfWeek)
    guard dayOfWeek > 0 &&  dayOfWeek < 8 else {
      return nil
    }
    
    let fromHour = aDecoder.decodeInt32(forKey: BEOpeningHour.kFromHour)
    let fromMinute = aDecoder.decodeInt32(forKey: BEOpeningHour.kFromMinute)
    let toHour = aDecoder.decodeInt32(forKey: BEOpeningHour.kToHour)
    let toMinute = aDecoder.decodeInt32(forKey: BEOpeningHour.kToMinute)
    
    self.dayOfWeek = Int(dayOfWeek)
    self.fromHour = Int(fromHour)
    self.fromMinute = Int(fromMinute)
    self.toMinute = Int(toMinute)
    self.toHour = Int(toHour)
  }
  
  public func encode(with aCoder: NSCoder) {
    aCoder.encode(Int32(dayOfWeek), forKey: BEOpeningHour.kDayOfWeek)
    aCoder.encode(Int32(fromHour), forKey: BEOpeningHour.kFromHour)
    aCoder.encode(Int32(fromMinute), forKey: BEOpeningHour.kFromMinute)
    aCoder.encode(Int32(toHour), forKey: BEOpeningHour.kToHour)
    aCoder.encode(Int32(toMinute), forKey: BEOpeningHour.kToMinute)
  }
}
