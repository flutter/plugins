// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FlutterMacOS
import Foundation

public class SharedPreferencesPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "plugins.flutter.io/shared_preferences",
      binaryMessenger: registrar.messenger)
    let instance = SharedPreferencesPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let method = call.method
    if method == "getAll" {
      result(getAllPrefs())
    } else if method == "setBool" ||
              method == "setInt" ||
              method == "setInt" ||
              method == "setDouble" ||
              method == "setString" ||
              method == "setStringList" {
      let arguments = call.arguments as! [String : Any]
      let key = arguments["key"] as! String
      UserDefaults.standard.set(arguments["value"], forKey: key)
      result(true)
    } else if (method == "commit") {
      // UserDefaults does not need to be synchronized.
      result(true)
    } else if (method == "remove") {
      let arguments = call.arguments as! [String : Any]
      let key = arguments["key"] as! String
      UserDefaults.standard.removeObject(forKey: key)
      result(true)
    } else if (method == "clear") {
      let defaults = UserDefaults.standard
      for (key, _) in getAllPrefs() {
        defaults.removeObject(forKey: key)
      }
      result(true)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }
}

private func getAllPrefs() -> [String : Any] {
  var filteredPrefs: [String : Any] = [:]
  if let appDomain = Bundle.main.bundleIdentifier,
     let prefs = UserDefaults.standard.persistentDomain(forName: appDomain) {
    for (key, value) in prefs {
      if key.hasPrefix("flutter.") {
        filteredPrefs[key] = value
      }
    }
  }
  return filteredPrefs
}
