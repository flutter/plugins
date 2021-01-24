// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FlutterMacOS
import Foundation

public class UrlLauncherPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "plugins.flutter.io/url_launcher",
      binaryMessenger: registrar.messenger)
    let instance = UrlLauncherPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let urlString: String? = (call.arguments as? [String: Any])?["url"] as? String
    switch call.method {
    case "canLaunch":
      guard let unwrappedURLString = urlString,
        let url = URL.init(string: unwrappedURLString)
      else {
        result(invalidURLError(urlString))
        return
      }
      result(NSWorkspace.shared.urlForApplication(toOpen: url) != nil)
    case "launch":
      guard let unwrappedURLString = urlString,
        let url = URL.init(string: unwrappedURLString)
      else {
        result(invalidURLError(urlString))
        return
      }
      result(NSWorkspace.shared.open(url))
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

/// Returns an error for the case where a URL string can't be parsed as a URL.
private func invalidURLError(_ url: String?) -> FlutterError {
  return FlutterError(
    code: "argument_error",
    message: "Unable to parse URL",
    details: "Provided URL: \(String(describing: url))")
}
