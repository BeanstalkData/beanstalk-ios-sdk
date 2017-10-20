//
//  BEStoreProtocol.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 10/18/17.
//
//

import Foundation
import ObjectMapper

/** Special cases
 1. To indicate that a store is open 24 hours on a specific day, set 00:00 as both the opening and closing time for that day.
 
   Example: open all day on Saturdays – dayOfWeek:7 fromHour: 00 fromMinute: 00 toHour:00 toMinute:00
 
 2. To indicate that a store is closed on a specific day, omit that day from the list
 
 3. To indicate that a store has split hours on a specific day, submit a set of hours for each block of time the location is open.
 
 Example: open from 9:00 AM to 12:00 PM and again from 1:00 PM to 5:00 PM on Mondays – 
   dayOfWeek:2 fromHour: 09 fromMinute: 00 toHour:12 toMinute:00
   dayOfWeek:2 fromHour: 13 fromMinute: 00 toHour:17 toMinute:00
*/

public protocol BEStoreProtocol: NSObjectProtocol, BaseMappable {
  var id: String? { get }
  var customerId: String? { get }
  var name: String? { get }
  var phone: String? { get }
  var website: String? { get }
  var email: String? { get }
  var storeId: String? { get }
  var timeZone: String? { get }
  var paymentLoyaltyParticipation: Bool? { get }
  var geoEnabled: Bool? { get }
  var openDate: Date? { get }
  
  // location
  var address1: String? { get }
  var address2: String? { get }
  var city: String? { get }
  var state: String? { get }
  var zip: Int? { get }
  var country: String? { get }
  var longitude: String? { get }
  var latitude: String? { get }
  
  // Opening hours
  var openingHours: [Int: BEOpeningHour]? { get }
}
