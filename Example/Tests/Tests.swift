import UIKit
import XCTest
import BeanstalkEngageiOSSDK
import Pods_BeanstalkEngageiOSSDK_Tests

class Tests: BEBaseTestCase {
  
  let testsMetadata = TestsMetadata()
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
    
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  override func getMetadata() -> BEBaseTestsMetadataProtocol? {
    return testsMetadata
  }
  
  func testLoginRegisteredUser() {
    
//    XCTAssert(success, "Can not sighIn with email " + "\(self.getMetadata()!.getRegisteredUser1Email())")

  }
}
