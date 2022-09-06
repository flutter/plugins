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
  private let shortcutService: FLTShortcutStateManager

  @objc
  public init(
    channel: FlutterMethodChannel,
    shortcutService: FLTShortcutStateManager = FLTShortcutStateManager())
  {
    self.channel = channel
    self.shortcutService = shortcutService
  }

  @objc
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "setShortcutItems":
      let items = call.arguments as? [[String:Any]] ?? []
      shortcutService.setShortcutItems(items)
      result(nil)
    case "clearShortcutItems":
      shortcutService.setShortcutItems([])
      result(nil)
    case "getLaunchAction":
      result(nil)
    case _:
      result(FlutterMethodNotImplemented)
    }
  }

  public func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) -> Bool {
    handleShortcut(shortcutItem.type)
    return true
  }

  public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
    let shortcutItem = launchOptions[UIApplication.LaunchOptionsKey.shortcutItem]
    if let shortcutItem = shortcutItem as? UIApplicationShortcutItem {
      self.shortcutService.launchingShortcutType = shortcutItem.type
      return false
    }
    return true
  }

  public func applicationDidBecomeActive(_ application: UIApplication) {
    if let shortcutType = shortcutService.launchingShortcutType {
      handleShortcut(shortcutType)
      shortcutService.launchingShortcutType = nil
    }
  }

  private func handleShortcut(_ shortcut: String) {
    channel.invokeMethod("launch", arguments: shortcut)
  }

}
