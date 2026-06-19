import Flutter
import UIKit
import XCTest

@testable import suprsend_flutter_sdk

class RunnerTests: XCTestCase {

  func testUnknownMethodReturnsNotImplemented() {
    let plugin = SuprsendFlutterSdkPlugin()
    let call = FlutterMethodCall(methodName: "doesNotExist", arguments: nil)

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      XCTAssertTrue(result is NSObject)
      XCTAssertEqual(result as? NSObject, FlutterMethodNotImplemented)
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
  }

}
