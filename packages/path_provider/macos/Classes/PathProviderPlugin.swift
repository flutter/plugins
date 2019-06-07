// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FlutterMacOS
import Foundation

public class PathProviderPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "plugins.flutter.io/path_provider",
      binaryMessenger: registrar.messenger)
    let instance = PathProviderPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let method = call.method
    if method == "getTemporaryDirectory" {
      result(getDirectory(ofType: FileManager.SearchPathDirectory.cachesDirectory))
    } else if method == "getApplicationDocumentsDirectory" {
      result(getDirectory(ofType: FileManager.SearchPathDirectory.documentDirectory))
    } else if (method == "getApplicationSupportDirectory") {
      var path = getDirectory(ofType: FileManager.SearchPathDirectory.applicationSupportDirectory)
      if let basePath = path {
        let basePathURL = URL.init(fileURLWithPath: basePath)
        path = basePathURL.appendingPathComponent(Bundle.main.bundleIdentifier!).path
        do {
          try FileManager.default.createDirectory(atPath: path!, withIntermediateDirectories: true)
        } catch {
          result(FlutterError(
            code:"directory_creation_failure",
            message: error.localizedDescription,
            details: "\(error)"))
          return
        }
      }
      result(path)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }
}

private func getDirectory(ofType directory: FileManager.SearchPathDirectory) -> String? {
  let paths = NSSearchPathForDirectoriesInDomains(
    directory,
    FileManager.SearchPathDomainMask.userDomainMask,
    true)
  return paths.first
}
