import UIKit
import XCTest
import BeanstalkEngageiOSSDK
import BeanstalkEngageiOSSDKTests

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
    
    self.getCoreService()?.authenticate(nil, email: getMetadata()?.getRegisteredUser1Email(), password: getMetadata()?.getRegisteredUser1Password(), handler: { (success, additionalInfo) in
      
      XCTAssert(success, "Can not sighIn with email " + "\(self.getMetadata()!.getRegisteredUser1Email())")
    })
    
    // This is an example of a functional test case.
    XCTAssert(true, "Pass")
  }
}
