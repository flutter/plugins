// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FlutterMacOS
import XCTest
import url_launcher_macos

class RunnerTests: XCTestCase {
  func testCanLaunch() throws {
    let plugin = UrlLauncherPlugin()
    let call = FlutterMethodCall(
      methodName: "canLaunch",
      arguments: ["url": "https://flutter.dev"])
    var canLaunch: Bool?
    plugin.handle(
      call,
      result: { (result: Any?) -> Void in
        canLaunch = result as? Bool
      })

    XCTAssertTrue(canLaunch == true)
  }
}
