//
//  ContactRequestResponse.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import ObjectMapper


/**
 Response model for contact create/update request.
 */
public struct ContactRequestResponse <ContactClass: Mappable> {
  let contactId: String
  let contact: ContactClass?
  let fetchContactRequested: Bool
}
