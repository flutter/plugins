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
  var plugin: UrlLauncherPlugin! = nil

  override func setUp() {
    workspace = StubWorkspace()
    plugin = UrlLauncherPlugin()
  }

  override func tearDown() {
    workspace = nil
    plugin = nil
  }

  func testCanLaunch() throws {
    let call = FlutterMethodCall(
      methodName: "canLaunch",
      arguments: ["url": "https://flutter.dev"])

    plugin.handle(
      call,
      result: { (result: Any?) -> Void in
        let canLaunch: Bool? = result as? Bool
        XCTAssertTrue(canLaunch == true)
      }, with: workspace)
  }

  func testLaunch() throws {
    let call = FlutterMethodCall(
      methodName: "launch",
      arguments: ["url": "https://flutter.dev"])

    plugin.handle(
      call,
      result: { (result: Any?) -> Void in
        XCTAssertTrue(result as? Bool == true)
      }, with: workspace)
  }

}
