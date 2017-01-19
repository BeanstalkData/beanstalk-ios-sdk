import UIKit
import XCTest
import BeanstalkEngageiOSSDK

public class BEBaseTestCase: BEAsyncTestCase {
  
  var beanstalkCoreService: CoreService<HTTPTimberjackManager>?
  var session: BESession?
  
  override public func setUp() {
    super.setUp()
    
    if let _ = getMetadata() {
      session = BESession()
      beanstalkCoreService = CoreService<HTTPTimberjackManager>(apiKey: getMetadata()!.getBeanstalkApiKey(), session: session!)
    }
  }
  
  override public func tearDown() {
    // 
    super.tearDown()
  }
  
  public func getCoreService() -> CoreService<HTTPTimberjackManager>? {
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
