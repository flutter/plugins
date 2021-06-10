// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FlutterMacOS
import XCTest
import shared_preferences_macos

class RunnerTests: XCTestCase {
  func testHandlesCommitNoOp() throws {
    let plugin = SharedPreferencesPlugin()
    let call = FlutterMethodCall(methodName: "commit", arguments: nil)
    var called = false
    plugin.handle(
      call,
      result: { (result: Any?) -> Void in
        called = true
        XCTAssert(result as? Bool == true)
      })
    XCTAssert(called)
  }

  func testSetAndGet() throws {
    let plugin = SharedPreferencesPlugin()
    let setCall = FlutterMethodCall(
      methodName: "setInt",
      arguments: [
        "key": "flutter.foo",
        "value": 42,
      ])
    plugin.handle(
      setCall,
      result: { (result: Any?) -> Void in
        XCTAssert(result as? Bool == true)
      })

    var value: Int?
    plugin.handle(
      FlutterMethodCall(methodName: "getAll", arguments: nil),
      result: { (result: Any?) -> Void in
        if let prefs = result as? [String: Any] {
          value = prefs["flutter.foo"] as? Int
        }
      })
    XCTAssertEqual(value, 42)
  }

  func testClear() throws {
    let plugin = SharedPreferencesPlugin()
    let setCall = FlutterMethodCall(
      methodName: "setInt",
      arguments: [
        "key": "flutter.foo",
        "value": 42,
      ])
    plugin.handle(setCall, result: { (result: Any?) -> Void in })

    // Make sure there is something to clear, so the test can't pass due to a set failure.
    let getCall = FlutterMethodCall(methodName: "getAll", arguments: nil)
    var value: Int?
    plugin.handle(
      getCall,
      result: { (result: Any?) -> Void in
        if let prefs = result as? [String: Any] {
          value = prefs["flutter.foo"] as? Int
        }
      })
    XCTAssertEqual(value, 42)

    // Clear the value.
    plugin.handle(
      FlutterMethodCall(methodName: "clear", arguments: nil),
      result: { (result: Any?) -> Void in
        XCTAssert(result as? Bool == true)
      })

    // Get the value again, which should clear |value|.
    plugin.handle(
      getCall,
      result: { (result: Any?) -> Void in
        if let prefs = result as? [String: Any] {
          value = prefs["flutter.foo"] as? Int
          XCTAssert(prefs.isEmpty)
        }
      })
    XCTAssertEqual(value, nil)
  }
}
