// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter

/// A channel for platform code to communicate with the Dart code.
protocol MethodChannel {
  /// Invokes a method in Dart code.
  /// - Parameter method the method name.
  /// - Parameter arguments the method arguments.
  func invokeMethod(_ method: String, arguments: Any?)
}

/// A default implementation of the `MethodChannel` protocol.
extension FlutterMethodChannel: MethodChannel {}
