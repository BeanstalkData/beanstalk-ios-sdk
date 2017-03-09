//
//  BERespondersHolder.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation

public protocol BEAbstractRespondersHolder {
  
  associatedtype I
  
  func addResponder(_ responder: I)
  func removeResponder(_ responder: I)
}

public protocol WeakResponderHolder {
  func isEmpty() -> Bool
}

open class BERespondersHolder <I>: BEAbstractRespondersHolder where I: Equatable, I: WeakResponderHolder {
  fileprivate var responders = [I]()
  
  public init() {
  }
  
  //MARK: - Public
  
  open func addResponder(_ responder: I) {
    if !self.responders.contains(where: { $0 == responder }) {
      self.responders.insert(responder, at: 0)
    }
  }
  
  open func removeResponder(_ responder: I) {
    if let index = self.responders.index(where: { $0 == responder }) {
      self.responders.remove(at: index)
    }
  }
  
  open func enumerateResponders(_ handler: (I) -> Bool?) {
    self.removeEmptyResponders()
    
    for responder in self.responders {
      if let result = handler(responder) {
        if result {
          break
        }
      }
    }
  }
  
  open func enumerateObservers(_ handler: (I) -> Void) {
    self.removeEmptyResponders()
    
    for responder in self.responders {
      handler(responder)
    }
  }
  
  //MARK: - Private
  
  fileprivate func removeEmptyResponders() {
    let emptyResponders = self.responders.filter() { $0.isEmpty() }
    
    if (emptyResponders.count > 0) {
      for emptyResponder in emptyResponders {
        if let index = self.responders.index(where: { $0 == emptyResponder }) {
          self.responders.remove(at: index)
        }
      }
    }
  }
}

