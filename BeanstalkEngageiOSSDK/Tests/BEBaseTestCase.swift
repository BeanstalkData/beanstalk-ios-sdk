import UIKit
import XCTest
import BeanstalkEngageiOSSDK

public class BEBaseTestCase: BEAsyncTestCase {
  
  var beanstalkCoreService: CoreService?
  
  override public func setUp() {
    super.setUp()
    
    if let _ = getMetadata() {
      beanstalkCoreService = CoreService(apiKey: getMetadata()!.getBeanstalkApiKey(), session: BESession())
    }
  }
  
  override public func tearDown() {
    // 
    super.tearDown()
  }
  
  public func getCoreService() -> CoreService? {
    XCTAssert(beanstalkCoreService != nil)
    return beanstalkCoreService
  }
  
  // override in inherited class
  public func getMetadata() -> BEBaseTestsMetadataProtocol? {
    return nil
  }
}
