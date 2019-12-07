// Copyright 2019 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
