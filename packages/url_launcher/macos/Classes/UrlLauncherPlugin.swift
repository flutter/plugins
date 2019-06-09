// Copyright 2019 The Chromium Authors. All rights reserved.
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
    let method = call.method
    let urlString: String? = (call.arguments as? Dictionary<String, Any>)?["url"] as? String
    if method == "canLaunch" {
      guard let unwrappedURLString = urlString,
            let url = URL.init(string: unwrappedURLString) else {
        result(invalidURLError(urlString))
        return
      }
      result(NSWorkspace.shared.urlForApplication(toOpen: url) != nil)
    } else if method == "launch" {
      guard let unwrappedURLString = urlString,
            let url = URL.init(string: unwrappedURLString) else {
        result(invalidURLError(urlString))
        return
      }
      result(NSWorkspace.shared.open(url))
    } else {
      result(FlutterMethodNotImplemented)
    }
  }
}

private func invalidURLError(_ url: String?) -> FlutterError {
  return FlutterError(
    code:"argument_error",
    message: "Unable to parse URL",
    details: "Provided URL: \(String(describing: url))")
}
