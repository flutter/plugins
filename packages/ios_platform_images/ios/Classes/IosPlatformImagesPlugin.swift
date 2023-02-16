// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Flutter

/// A plugin for Flutter that allows Flutter to load images in a platform
/// specific way on iOS.
public class IosPlatformImagesPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "plugins.flutter.io/ios_platform_images",
      binaryMessenger: registrar.messenger()
    )
    let instance = IosPlatformImagesPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "loadImage":
      guard let name = call.arguments as? String,
            let image = UIImage(named: name),
            let data = image.pngData()
      else {
        result(nil)
        return
      }
      result([
        "scale": image.scale,
        "data": FlutterStandardTypedData(bytes: data)
      ])
    case "resolveURL":
      guard let args = call.arguments as? [String?],
            let name = args[0]
      else {
        result(nil)
        return
      }
      let url = Bundle.main.url(forResource: name, withExtension: args[1])
      result(url?.absoluteString)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
