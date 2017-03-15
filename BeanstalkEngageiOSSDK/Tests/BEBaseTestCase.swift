import UIKit
import XCTest
import BeanstalkEngageiOSSDK
import CCTestingUserDefaults

public typealias CoreServiceTest = CoreServiceT<HTTPTimberjackManager>

open class BEBaseTestCase: BEAsyncTestCase {
  
  var beanstalkCoreService: CoreServiceTest?
  var session: BESession?
  
  override open func setUp() {
    super.setUp()
    
    Timberjack.register()
    
    self.beanstalkCoreService = self.createCoreService()
    self.session = self.beanstalkCoreService?.getSession()
  }
  
  override open func tearDown() {
    Timberjack.unregister()
    
    super.tearDown()
  }
  
  open func createCoreService() -> CoreServiceTest? {
    if let _ = getMetadata() {
      let session = BESession(userDefaults: BETestUserDefaults())
      let beanstalkCoreService = CoreServiceTest(apiKey: getMetadata()!.getBeanstalkApiKey(), session: session)
      
      return beanstalkCoreService
    }
    
    return nil
  }
  
  open func getCoreService() -> CoreServiceTest? {
    XCTAssert(beanstalkCoreService != nil)
    return beanstalkCoreService
  }
  
  open func getSession() -> BESession? {
    XCTAssert(session != nil)
    return session
  }
  
  // override in inherited class
  open func getMetadata() -> BEBaseTestsMetadataProtocol? {
    return nil
  }
}

open class BETestUserDefaults: BEUserDefaults {
  
  let userTransientDefaults = UserDefaults.transient()
  
  override open func getTransientDefaults() -> UserDefaults {
    return userTransientDefaults!
  }
}
