//
//  BERespondersHolder.swift
//  Gauge
//
//  Created by Dmytro Nadtochyy on 22.07.16.
//  Copyright © 2016 Dev-Pro. All rights reserved.
//

import Foundation

public protocol BEAbstractRespondersHolder {
  
  associatedtype I
  
  func addResponder(responder: I)
  func removeResponder(responder: I)
}

public protocol WeakResponderHolder {
  func isEmpty() -> Bool
}

public class BERespondersHolder <I where I: Equatable, I: WeakResponderHolder>: BEAbstractRespondersHolder {
  private var responders = [I]()
  
  public init() {
  }
  
  //MARK: - Public
  
  public func addResponder(responder: I) {
    if !self.responders.contains({ $0 == responder }) {
      self.responders.insert(responder, atIndex: 0)
    }
  }
  
  public func removeResponder(responder: I) {
    if let index = self.responders.indexOf({ $0 == responder }) {
      self.responders.removeAtIndex(index)
    }
  }
  
  public func enumerateResponders(handler: (I) -> Bool?) {
    self.removeEmptyResponders()
    
    for responder in self.responders {
      if let result = handler(responder) {
        if result {
          break
        }
      }
    }
  }
  
  public func enumerateObservers(handler: (I) -> Void) {
    self.removeEmptyResponders()
    
    for responder in self.responders {
      handler(responder)
    }
  }
  
  //MARK: - Private
  
  private func removeEmptyResponders() {
    let emptyResponders = self.responders.filter() { $0.isEmpty() }
    
    if (emptyResponders.count > 0) {
      for emptyResponder in emptyResponders {
        if let index = self.responders.indexOf({ $0 == emptyResponder }) {
          self.responders.removeAtIndex(index)
        }
      }
    }
  }
}

