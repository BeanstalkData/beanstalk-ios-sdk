import UIKit
import XCTest
import BeanstalkEngageiOSSDK
import CCTestingUserDefaults

public typealias CoreServiceTest = CoreServiceT<HTTPTimberjackManager, BETestUserDefaults>

public class BEBaseTestCase: BEAsyncTestCase {
  
  var beanstalkCoreService: CoreServiceTest?
  var session: BESessionT<BETestUserDefaults>?
  
  override public func setUp() {
    super.setUp()
    
    if let _ = getMetadata() {
      session = BESessionT<BETestUserDefaults>()
      beanstalkCoreService = CoreServiceTest(apiKey: getMetadata()!.getBeanstalkApiKey(), session: session!)
    }
  }
  
  override public func tearDown() {
    // 
    super.tearDown()
  }
  
  public func getCoreService() -> CoreServiceTest? {
    XCTAssert(beanstalkCoreService != nil)
    return beanstalkCoreService
  }
  
  public func getSession() -> BESessionT<BETestUserDefaults>? {
    XCTAssert(session != nil)
    return session
  }
  
  // override in inherited class
  public func getMetadata() -> BEBaseTestsMetadataProtocol? {
    return nil
  }
}

public class BETestUserDefaults: BEUserDefaults {
  
  static let userTransientDefaults = NSUserDefaults.transientDefaults()
  
  override public class func getTransientDefaults() -> NSUserDefaults {
    return userTransientDefaults
  }
}
