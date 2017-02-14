import UIKit
import XCTest
import BeanstalkEngageiOSSDK
import CCTestingUserDefaults

public typealias CoreServiceTest = CoreServiceT<HTTPTimberjackManager>

public class BEBaseTestCase: BEAsyncTestCase {
  
  var beanstalkCoreService: CoreServiceTest?
  var session: BESession?
  
  override public func setUp() {
    super.setUp()
    
    self.beanstalkCoreService = self.createCoreService()
    self.session = self.beanstalkCoreService?.getSession()
  }
  
  override public func tearDown() {
    // 
    super.tearDown()
  }
  
  public func createCoreService() -> CoreServiceTest? {
    if let _ = getMetadata() {
      let session = BESession(userDefaults: BETestUserDefaults())
      let beanstalkCoreService = CoreServiceTest(apiKey: getMetadata()!.getBeanstalkApiKey(), session: session)
      
      return beanstalkCoreService
    }
    
    return nil
  }
  
  public func getCoreService() -> CoreServiceTest? {
    XCTAssert(beanstalkCoreService != nil)
    return beanstalkCoreService
  }
  
  public func getSession() -> BESession? {
    XCTAssert(session != nil)
    return session
  }
  
  // override in inherited class
  public func getMetadata() -> BEBaseTestsMetadataProtocol? {
    return nil
  }
}

public class BETestUserDefaults: BEUserDefaults {
  
  let userTransientDefaults = NSUserDefaults.transientDefaults()
  
  override public func getTransientDefaults() -> NSUserDefaults {
    return userTransientDefaults
  }
}
