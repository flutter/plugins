// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

@testable import quick_actions_ios

final class MockMethodChannel: MethodChannel {
  var invokeMethodStub: ((_ methods: String, _ arguments: Any?) -> Void)? = nil
  func invokeMethod(_ method: String, arguments: Any?) {
    invokeMethodStub?(method, arguments)
  }
}
