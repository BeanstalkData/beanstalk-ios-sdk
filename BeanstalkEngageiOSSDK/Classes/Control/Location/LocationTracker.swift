//
//  LocationTracker.swift
//  BeanstalkEngageiOSSDK
//
//  2017 Heartland Commerce, Inc. All rights reserved.
//

import Foundation
import CoreLocation

/**
 LocationTracker performs location tracking and notifies by handling closures.
 */
open class LocationTracker: NSObject, CLLocationManagerDelegate {
  private let locationManager = CLLocationManager()
  
  public var onDidUpdate: ((_ location: CLLocationCoordinate2D) -> Void)?
  public var onDidChangePermissions: ((_ granted: Bool) -> Void)?
  public var onDidFail: ((_ error: LocationTrackerError) -> Void)?
  
  private var p_lastLocation: CLLocationCoordinate2D?
  private var p_lastError: LocationTrackerError?
  
  private var updateTimer: Timer?
  private var coldStartTimer: Timer?
  private var coldStartTimerFired = false
  
  //  private var p_updateFrequency: TimeInterval = 60 * 60 // 1h default
  private var p_updateFrequency: TimeInterval = 60 // 1m for debug
  public var updateFrequency: TimeInterval {
    get {
      return self.p_updateFrequency
    }
    set (newValue) {
      self.p_updateFrequency = max(15 * 60, newValue) // 15m min
    }
  }
  public var accuracy: CLLocationAccuracy {
    get {
      return self.locationManager.desiredAccuracy
    }
    set (newValue) {
      self.locationManager.desiredAccuracy = newValue
    }
  }
  public var lastLocation: CLLocationCoordinate2D? {
    get {
      return self.p_lastLocation
    }
  }
  public var lastError: LocationTrackerError? {
    get {
      return self.p_lastError
    }
  }
  
  private var isAuthorizationStatusRequested = false
  
  override init() {
    super.init()
    
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
  }
  
  
  //MARK: - Public
  
  public func isPermissionsRequested() -> Bool {
    let status = CLLocationManager.authorizationStatus()
    
    return status != .notDetermined
  }
  
  public func isPermissionsGranted() -> Bool {
    let status = CLLocationManager.authorizationStatus()
    
    return self.isPermissionsGranted(status: status)
  }
  
  public func startLocationTracking() {
    self.startLocationTrackingAndSetupTimer()
  }
  
  public func stopLocationTracking() {
    self.stopLocationTrackingAndInvalidateTimer()
  }
  
  //MARK: - CLLocationManagerDelegate
  
  public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
      let coordinate = location.coordinate
      
      let previousLocationEmpty = self.p_lastLocation == nil
      
      self.p_lastError = nil
      self.p_lastLocation = coordinate
      
      if self.coldStartTimerFired && previousLocationEmpty {
        self.notifyForUpdatedLocation()
      }
    }
  }
  
  public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    let granted = self.isPermissionsGranted(status: status)
    
    if !granted {
      self.p_lastError = LocationTrackerError.locationPermissionsDenied()
      self.p_lastLocation = nil
    }
    
    if self.isAuthorizationStatusRequested {
      self.isAuthorizationStatusRequested = false
      
      if granted {
        self.startLocationTracking()
      } else if let error = self.p_lastError {
        self.onDidFail?(error)
      }
      
      return
    }
    
    self.onDidChangePermissions?(granted)
  }
  
  public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    self.p_lastError = LocationTrackerError.locationManagerDidFail(error: error)
    self.p_lastLocation = nil
  }
  
  //MARK: - Private
  
  private func isPermissionsGranted(status: CLAuthorizationStatus) -> Bool {
    var granted = false
    
    switch status {
    case .authorizedAlways:
      fallthrough
    case .authorizedWhenInUse:
      granted = true
      
    default:
      granted = false
    }
    
    return granted
  }
  
  private func startLocationTrackingAndSetupTimer() {
    if !self.isPermissionsRequested() {
      self.isAuthorizationStatusRequested = true
      self.locationManager.requestAlwaysAuthorization()
      
      return
    }
    
    if !self.isPermissionsGranted() {
      let error = LocationTrackerError.locationPermissionsDenied()
      self.p_lastError = error
      self.onDidFail?(error)
      
      return
    }
    
    if self.coldStartTimer != nil || self.updateTimer != nil {
      return
    }
    
    self.coldStartTimer = Timer.scheduledTimer(
      timeInterval: 15,
      target: self,
      selector: #selector(self.onColdStartTimer),
      userInfo: nil,
      repeats: false
    )
    
    self.locationManager.startUpdatingLocation()
  }
  
  private func stopLocationTrackingAndInvalidateTimer() {
    self.locationManager.stopUpdatingLocation()
    
    self.updateTimer?.invalidate()
    self.updateTimer = nil
    
    self.coldStartTimerFired = false
    self.coldStartTimer?.invalidate()
    self.coldStartTimer = nil
  }
  
  private func notifyForUpdatedLocation() {
    if let lastLoc = self.lastLocation {
      self.onDidUpdate?(lastLoc)
    } else if let lastLocFromManager = self.locationManager.location {
      self.onDidUpdate?(lastLocFromManager.coordinate)
    } else if let error = self.lastError {
      self.onDidFail?(error)
    }
    
    self.updateTimer = Timer.scheduledTimer(
      timeInterval: self.updateFrequency,
      target: self,
      selector: #selector(self.onUpdateTimer),
      userInfo: nil,
      repeats: false
    )
  }
  
  //MARK: - Timer actions
  
  @objc private func onUpdateTimer() {
    self.notifyForUpdatedLocation()
  }
  
  @objc private func onColdStartTimer() {
    self.coldStartTimerFired = true
    
    self.coldStartTimer?.invalidate()
    self.coldStartTimer = nil
    
    if let _ = self.lastLocation {
      self.notifyForUpdatedLocation()
    }
  }
}
