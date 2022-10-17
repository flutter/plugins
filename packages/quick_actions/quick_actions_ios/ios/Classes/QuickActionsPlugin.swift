// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter

public final class QuickActionsPlugin: NSObject, FlutterPlugin {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "plugins.flutter.io/quick_actions_ios",
      binaryMessenger: registrar.messenger())
    let instance = QuickActionsPlugin(channel: channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addApplicationDelegate(instance)
  }

  private let channel: FlutterMethodChannel
  private let shortcutStateManager: FLTShortcutStateManager
  /// The type of the shortcut item selected when launching the app.
  private var launchingShortcutType: String? = nil

  // TODO: (hellohuanlin) remove `@objc` attribute and make it non-public after migrating tests to Swift.
  @objc
  public init(
    channel: FlutterMethodChannel,
    shortcutStateManager: FLTShortcutStateManager = FLTShortcutStateManager()
  ) {
    self.channel = channel
    self.shortcutStateManager = shortcutStateManager
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "setShortcutItems":
      // `arguments` must be an array of dictionaries
      let items = call.arguments as! [[String: Any]]
      shortcutStateManager.setShortcutItems(items)
      result(nil)
    case "clearShortcutItems":
      shortcutStateManager.setShortcutItems([])
      result(nil)
    case "getLaunchAction":
      result(nil)
    case _:
      result(FlutterMethodNotImplemented)
    }
  }

  public func application(
    _ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem,
    completionHandler: @escaping (Bool) -> Void
  ) -> Bool {
    handleShortcut(shortcutItem.type)
    return true
  }

  public func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any] = [:]
  ) -> Bool {
    if let shortcutItem = launchOptions[UIApplication.LaunchOptionsKey.shortcutItem]
      as? UIApplicationShortcutItem
    {
      // Keep hold of the shortcut type and handle it in the
      // `applicationDidBecomeActive:` method once the Dart MethodChannel
      // is initialized.
      launchingShortcutType = shortcutItem.type

      // Return false to indicate we handled the quick action to ensure
      // the `application:performActionFor:` method is not called (as
      // per Apple's documentation:
      // https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622935-application).
      return false
    }
    return true
  }

  public func applicationDidBecomeActive(_ application: UIApplication) {
    if let shortcutType = launchingShortcutType {
      handleShortcut(shortcutType)
      launchingShortcutType = nil
    }
  }

  private func handleShortcut(_ shortcut: String) {
    channel.invokeMethod("launch", arguments: shortcut)
  }

}
