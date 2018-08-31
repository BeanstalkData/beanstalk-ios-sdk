//
//  CoreService+Promise.swift
//  Alamofire
//
//  Created by Alexander Frolikov on 8/31/18.
//

import Foundation
import CoreLocation
import PromiseKit

extension CoreServiceT {
  
  open func registerLoyaltyAccount <ContactClass: BEContact> (request: ContactRequest, contactClass: ContactClass.Type) -> Promise<Void> {
    return Promise { seal in
      registerLoyaltyAccount(request: request, contactClass: contactClass, handler: {  _, error in
        seal.resolve(error)
      })
    }
  }
  
  open func checkLoyaltyAccount() -> Promise<Void> {
    return Promise { seal in
      checkLoyaltyAccount(handler: { seal.resolve($1)})
    }
  }
  
  open func register <ContactClass: BEContact> (request : ContactRequest, contactClass: ContactClass.Type) -> Promise<Void> {
    return Promise { seal in
      register(request: request, contactClass: contactClass, handler: { _, error in
        seal.resolve(error)
      })
    }
  }
  
  open func autoSignIn <ContactClass: BEContact> (contactClass: ContactClass.Type) -> Promise<Void> {
    return Promise { seal in
      autoSignIn(contactClass: contactClass, handler: { _, error in
        seal.resolve(error)
      })
    }
  }
  
  open func authenticate <ContactClass: BEContact> (email: String?, password: String?, contactClass: ContactClass.Type) -> Promise<Void> {
    return Promise { seal in
      authenticate(email: email, password: password, contactClass: contactClass, handler: { _, error in
        seal.resolve(error)
      })
    }
  }
  
  open func authWithFacebookUser<ContactClass: BEContact>(facebookId: String, facebookToken: String, contactClass: ContactClass.Type) -> Promise<Void> {
    return Promise { seal in
      authWithFacebookUser(facebookId: facebookId, facebookToken: facebookToken, contactClass: contactClass, handler: { _, error in
        seal.resolve(error)
      })
    }
  }
  
  open func authWithGoogleUser<ContactClass: BEContact>(googleId: String, googleToken: String, contactClass: ContactClass.Type) -> Promise<Void> {
    return Promise { seal in
      authWithGoogleUser(googleId: googleId, googleToken: googleToken, contactClass: contactClass, handler: { _, error in
        seal.resolve(error)
      })
    }
  }
  
  open func resetPassword(email : String?) -> Promise<Void> {
    return Promise { seal in
      resetPassword(email: email, handler: { _, error in
        seal.resolve(error)
      })
    }
  }
  
  open func logout() -> Promise<Void> {
    return Promise { seal in
      logout(handler: { _, error in
        seal.resolve(error)
      })
    }
  }
  
  //MARK: - Contact

  open func getContact <ContactClass: BEContact> (contactClass: ContactClass.Type) -> Promise<ContactClass> {
    return Promise { seal in
      getContact(contactClass: contactClass, handler: { _, contact, error in
        seal.resolve(error, contact)
      })
    }
  }
  
  open func createContact <ContactClass: BEContact> ( _ request : ContactRequest, contactClass: ContactClass.Type, fetchContact: Bool = false) -> Promise<(contactId: String?, contact: ContactClass?)> {
    return Promise { seal in
      createContact(request, contactClass: contactClass, fetchContact: fetchContact, handler: { _, contactId, contact, error in
        seal.resolve(error, (contactId: contactId, contact: contact))
      })
    }
  }
  
  open func updateContact <ContactClass: BEContact> (request : ContactRequest, contactClass : ContactClass.Type, fetchContact : Bool = false) -> Promise<ContactClass> {
    return Promise { seal in
      updateContact(request: request, contactClass: contactClass, handler: { _, contact, error in
        seal.resolve(error, contact)
      })
    }
  }
  
  open func relocateContact( latitude: String, longitude: String) -> Promise<Void> {
    return Promise { seal in
      relocateContact(latitude: latitude, longitude: longitude, handler: { _, error in
        seal.resolve(error)
      })
    }
  }
  
  open func getContactGeoAssets() -> Promise<ContactGeoAssetsResponse> {
    return Promise { seal in
      getContactGeoAssets(handler: { response, error in
        seal.resolve(error, response)
      })
    }
  }
  
  open func deleteContact( contactId: String) -> Promise<Void> {
    return Promise { seal in
      deleteContact(contactId: contactId, handler: { _, error in
        seal.resolve(error)
      })
    }
  }
  
  open func fetchContactBy <ContactClass: BEContact> (fetchField: ContactFetchField, fieldValue: String, caseSensitive: Bool = false, prospectTypes: [ProspectType] = [], contactClass: ContactClass.Type) -> Promise<ContactClass?> {
    return Promise { seal in
      fetchContactBy(fetchField: fetchField, fieldValue: fieldValue, contactClass: contactClass, handler: { _, conatct, error in
        seal.resolve(error, conatct)
      })
    }
  }
  
  open func checkContactsByEmailExisted( email: String, prospectTypes: [ProspectType]) -> Promise<Bool> {
    return Promise { seal in
      checkContactsByEmailExisted(email: email, prospectTypes: prospectTypes, handler: { _, existed, error in
        seal.resolve(error, existed)
      })
    }
  }
  
  open func checkContactsByPhoneExisted( phoneNumber: String, prospectTypes: [ProspectType]) -> Promise<Bool> {
    return Promise { seal in
      checkContactsByPhoneExisted(phoneNumber: phoneNumber, prospectTypes: prospectTypes, handler: { _, existed, error in
        seal.resolve(error, existed)
      })
    }
  }
  
  open func updatePassword(password: String?, confirmPassword: String?) -> Promise<Void> {
    return Promise { seal in
      updatePassword(password: password, confirmPassword: confirmPassword, handler: { _, error in
        seal.resolve(error)
      })
    }
  }
  
  open func getAvailableRewards() -> Promise<[BECouponProtocol]> {
    return Promise { seal in
      getAvailableRewards(handler: { _, coupons, error in
        seal.resolve(error, coupons)
      })
    }
  }
  
  open func getAvailableRewards <CouponClass: BECoupon> (couponClass: CouponClass.Type) -> Promise<[BECouponProtocol]> {
    return Promise { seal in
      getAvailableRewards(couponClass: couponClass, handler: { _, coupons, errro in
        seal.resolve(errro, coupons)
      })
    }
  }
  
  open func getUserProgress() -> Promise<Double> {
    return Promise { seal in
      getUserProgress(handler: { _, value, error in
        seal.resolve(error, value)
      })
    }
  }
  
  open func getGiftCards() -> Promise<[BEGiftCard]> {
    return Promise { seal in
      getGiftCards(handler: { _, cards, error in
        seal.resolve(error, cards)
      })
    }
  }
  
  open func getGiftCards <GiftCardClass: BEGiftCard> (giftCardClass: GiftCardClass.Type) -> Promise<[BEGiftCard]> {
    return Promise { seal in
      getGiftCards(giftCardClass: giftCardClass, handler: { _, cards, error in
        seal.resolve(error, cards)
      })
    }
  }
  
  open func startPayment(cardId : String?, coupons: [BECouponProtocol]) -> Promise<BarCodeInfo> {
    return Promise { seal in
      startPayment(cardId: cardId, coupons: coupons, handler: { _, info, error in
        seal.resolve(error, info)
      })
    }
  }
  
  //MARK: - Push Notifications

  open func pushNotificationEnroll(_ deviceToken: String) -> Promise<Void> {
    return Promise { seal in
      pushNotificationEnroll(deviceToken, handler: { _, error in
        seal.resolve(error)
      })
    }
  }
  
  open func pushNotificationDelete() -> Promise<Void> {
    return Promise { seal in
      pushNotificationDelete({ _, error in
        seal.resolve(error)
      })
    }
  }
  
  open func pushNotificationGetMessages (maxResults: Int) -> Promise<[BEPushNotificationMessage]> {
    return Promise { seal in
      pushNotificationGetMessages(maxResults: maxResults, handler: { _, messages, error in
        seal.resolve(error, messages)
      })
    }
  }
  
  open func pushNotificationUpdateStatus(_ messageId: String, status: PushNotificationStatus) -> Promise<Void> {
    return Promise { seal in
      pushNotificationUpdateStatus(messageId, status: status, handler: { _, error in
        seal.resolve(error)
      })
    }
  }
  
  open func pushNotificationGetMessageById(_ messageId: String) -> Promise<BEPushNotificationMessage> {
    return Promise { seal in
      pushNotificationGetMessageById(messageId, handler: { _, message, error in
        seal.resolve(error, message)
      })
    }
  }
  
  //MARK: - Locations
  
  open func getStoresAtLocation(coordinate: CLLocationCoordinate2D?) -> Promise< [BEStoreProtocol]> {
    return Promise { seal in
      getStoresAtLocation(coordinate: coordinate, handler: { _, stores, error in
        seal.resolve(error, stores)
      })
    }
  }
  
  //MARK: - Transactions
  
  open func trackTransaction( transactionData: String) -> Promise<BETransaction> {
    return Promise { seal in
      trackTransaction(transactionData: transactionData, handler: { transaction, error in
        seal.resolve(error, transaction)
      })
    }
  }
  
  open func getTransactions( startDate: Date?, endDate: Date?) -> Promise<[BETransaction]> {
    return Promise { seal in
      getTransactions(startDate: startDate, endDate: endDate, handler: { transactions, error in
        seal.resolve(error, transactions)
      })
    }
  }
  
  //MARK: - Support
  
  public func sendSupportRequest( supportRequest: SupportRequest) -> Promise<Void> {
    return Promise { seal in
      sendSupportRequest(supportRequest: supportRequest, handler: { seal.resolve($0) })
    }
  }
}
