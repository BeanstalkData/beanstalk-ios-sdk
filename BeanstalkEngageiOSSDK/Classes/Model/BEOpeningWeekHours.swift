//
//  BEOpeningWeekHours.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 10/20/17.
//
//

import Foundation
import ObjectMapper

/** Special cases
 1. To indicate that a store is open 24 hours on a specific day, set 00:00 as both the opening and closing time for that day.
 
 Example: open all day on Saturdays – dayOfWeek:7 fromHour: 00 fromMinute: 00 toHour:00 toMinute:00
 
 2. To indicate that a store is closed on a specific day, omit that day from the list or set it as closed
 
 Example: closed on Sundays – 1:closed
 
 3. To indicate that a store has split hours on a specific day, submit a set of hours for each block of time the location is open.
 
 Example: open from 9:00 AM to 12:00 PM and again from 1:00 PM to 5:00 PM on Mondays –
 dayOfWeek:2 fromHour: 09 fromMinute: 00 toHour:12 toMinute:00
 dayOfWeek:2 fromHour: 13 fromMinute: 00 toHour:17 toMinute:00
 */

public class BEOpeningWeekHours: NSObject, NSCoding {

  fileprivate static let kOpeningHours = "BEOpeningWeekHours_openingHours"
  
  fileprivate static let kClosedStore = "closed"
  
  open var openingHours: [Int: BEOpeningDayHour]?
  
  init(openingHours: [Int: BEOpeningDayHour]?) {
    self.openingHours = openingHours
  }
  
  init(formattedString: String?) {
    guard let openDayComponents = formattedString?.components(separatedBy: ",") else {
      return
    }
    
    self.openingHours = [Int: BEOpeningDayHour]()
    
    for openDayComponent in openDayComponents {
      let openHourComponents = openDayComponent.components(separatedBy: ":")
      switch openHourComponents.count {
      case 2:
        if let dayOfWeek = Int(openHourComponents[0]) {
          let state = openHourComponents[1]
          
          if state.caseInsensitiveCompare(BEOpeningWeekHours.kClosedStore) == .orderedSame {
            let openingHour = BEOpeningHour(closedDayOfWeek: dayOfWeek)
          }
        }
      
      case 5:
        if let dayOfWeek = Int(openHourComponents[0]),
          let fromHour = Int(openHourComponents[1]),
          let fromMinute = Int(openHourComponents[2]),
          let toHour = Int(openHourComponents[3]),
          let toMinute = Int(openHourComponents[4]) {
          
          let openingHour = BEOpeningHour(dayOfWeek: dayOfWeek, fromHour: fromHour, fromMinute: fromMinute, toHour: toHour, toMinute: toMinute)
          var openingHoursForDay = openingHours?[dayOfWeek]
          if openingHoursForDay == nil {
            openingHoursForDay = BEOpeningDayHour([openingHour])
          } else {
            openingHoursForDay?.openingHours.append(openingHour)
          }
          openingHours?[dayOfWeek] = openingHoursForDay
        }
      default:
        break
      }
    }
  }
  
  //MARK: - NSCoding -
  required public init(coder aDecoder: NSCoder) {
    if let openingHours = aDecoder.decodeObject(forKey: BEOpeningWeekHours.kOpeningHours) as? Data {
      self.openingHours = NSKeyedUnarchiver.unarchiveObject(with: openingHours) as? [Int: BEOpeningDayHour]
    }
  }
  
  open func encode(with aCoder: NSCoder) {
    if let openingHours = self.openingHours {
      aCoder.encode(NSKeyedArchiver.archivedData(withRootObject: openingHours), forKey: BEOpeningWeekHours.kOpeningHours)
    } else {
      aCoder.encode(nil, forKey: BEOpeningWeekHours.kOpeningHours)
    }
  }
}
