//
//  BEStoreProtocol.swift
//  Pods
//
//  Created by Pavel Dvorovenko on 10/18/17.
//
//

import Foundation
import ObjectMapper

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
