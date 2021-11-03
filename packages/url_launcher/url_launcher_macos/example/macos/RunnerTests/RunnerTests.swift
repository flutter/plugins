// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FlutterMacOS
import XCTest
import url_launcher_macos

class StubWorkspace: URLLauncher {
  var isSuccessful = true
  var url = URL.init(string: "https://flutter.dev")

  func open(_ url: URL) -> Bool {
    return isSuccessful
  }

  func urlForApplication(toOpen: URL) -> URL? {
    return url
  }

}

class RunnerTests: XCTestCase {

  var workspace: StubWorkspace! = nil
  var pluginWithStubWorkspace: UrlLauncherPlugin! = nil
  var plugin: UrlLauncherPlugin! = nil

  override func setUp() {
    workspace = StubWorkspace()
    pluginWithStubWorkspace = UrlLauncherPlugin(workspace)
    plugin = UrlLauncherPlugin()
  }

  override func tearDown() {
    workspace = nil
    pluginWithStubWorkspace = nil
    plugin = nil
  }

  func testCanLaunchSuccessTrue() throws {
    let call = FlutterMethodCall(
      methodName: "canLaunch",
      arguments: ["url": "https://flutter.dev"])

    plugin.handle(
      call,
      result: { (result: Any?) -> Void in
        XCTAssertNotNil(result)
        let canLaunch = result! as? Bool
        XCTAssertNotNil(canLaunch)
        XCTAssertTrue(canLaunch!)
      })
  }

  func testCanLaunchFailureFalse() throws {
    let call = FlutterMethodCall(
      methodName: "canLaunch",
      arguments: ["url": "brokenUrl"])

    plugin.handle(
      call,
      result: { (result: Any?) -> Void in
        XCTAssertNotNil(result)
        let canLaunch = result! as? Bool
        XCTAssertNotNil(canLaunch)
        XCTAssertFalse(canLaunch!)
      })
  }

  func testCanLaunchFailureError() throws {
    let call = FlutterMethodCall(
      methodName: "canLaunch",
      arguments: [])

    plugin.handle(
      call,
      result: { (result: Any?) -> Void in
        XCTAssertNotNil(result)
        XCTAssertTrue(result! is FlutterError)
      })
  }

  func testLaunchSuccess() throws {
    let call = FlutterMethodCall(
      methodName: "launch",
      arguments: ["url": "https://flutter.dev"])

    pluginWithStubWorkspace.handle(
      call,
      result: { (result: Any?) -> Void in
        XCTAssertNotNil(result)
        let launch = result! as? Bool
        XCTAssertNotNil(launch)
      })
  }

  func testLaunchFailureError() throws {
    let call = FlutterMethodCall(
      methodName: "canLaunch",
      arguments: [])

    pluginWithStubWorkspace.handle(
      call,
      result: { (result: Any?) -> Void in
        XCTAssertNotNil(result)
        XCTAssertTrue(result! is FlutterError)
      })
  }

}
