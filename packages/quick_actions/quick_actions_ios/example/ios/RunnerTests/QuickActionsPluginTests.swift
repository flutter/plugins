// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import quick_actions_ios

class QuickActionsPluginTests: XCTestCase {

  func testHandleMethodCall_setShortcutItems() {
    let rawItem = [
      "type": "SearchTheThing",
      "localizedTitle": "Search the thing",
      "icon": "search_the_thing.png",
    ]
    let item = UIApplicationShortcutItem(
      type: "SearchTheThing",
      localizedTitle: "Search the thing",
      localizedSubtitle: nil,
      icon: UIApplicationShortcutIcon(templateImageName: "search_the_thing.png"),
      userInfo: nil)

    let call = FlutterMethodCall(methodName: "setShortcutItems", arguments: [rawItem])

    let mockChannel = MockMethodChannel()
    let mockShortcutItemProvider = MockShortcutItemProvider()
    let mockShortcutItemParser = MockShortcutItemParser()

    let plugin = QuickActionsPlugin(
      channel: mockChannel,
      shortcutItemProvider: mockShortcutItemProvider,
      shortcutItemParser: mockShortcutItemParser)

    let parseShortcutItemsExpectation = expectation(
      description: "parseShortcutItems must be called.")
    mockShortcutItemParser.parseShortcutItemsStub = { items in
      XCTAssertEqual(items as? [[String: String]], [rawItem])
      parseShortcutItemsExpectation.fulfill()
      return [item]
    }

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      XCTAssertNil(result, "result block must be called with nil.")
      resultExpectation.fulfill()
    }
    XCTAssertEqual(mockShortcutItemProvider.shortcutItems, [item], "Must set shortcut items.")
    waitForExpectations(timeout: 1)
  }

  func testHandleMethodCall_clearShortcutItems() {
    let item = UIApplicationShortcutItem(
      type: "SearchTheThing",
      localizedTitle: "Search the thing",
      localizedSubtitle: nil,
      icon: UIApplicationShortcutIcon(templateImageName: "search_the_thing.png"),
      userInfo: nil)

    let call = FlutterMethodCall(methodName: "clearShortcutItems", arguments: nil)
    let mockChannel = MockMethodChannel()
    let mockShortcutItemProvider = MockShortcutItemProvider()
    let mockShortcutItemParser = MockShortcutItemParser()

    mockShortcutItemProvider.shortcutItems = [item]

    let plugin = QuickActionsPlugin(
      channel: mockChannel,
      shortcutItemProvider: mockShortcutItemProvider,
      shortcutItemParser: mockShortcutItemParser)

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      XCTAssertNil(result, "result block must be called with nil.")
      resultExpectation.fulfill()
    }

    XCTAssertEqual(mockShortcutItemProvider.shortcutItems, [], "Must clear shortcut items.")
    waitForExpectations(timeout: 1)
  }

  func testHandleMethodCall_getLaunchAction() {
    let call = FlutterMethodCall(methodName: "getLaunchAction", arguments: nil)

    let mockChannel = MockMethodChannel()
    let mockShortcutItemProvider = MockShortcutItemProvider()
    let mockShortcutItemParser = MockShortcutItemParser()

    let plugin = QuickActionsPlugin(
      channel: mockChannel,
      shortcutItemProvider: mockShortcutItemProvider,
      shortcutItemParser: mockShortcutItemParser)

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      XCTAssertNil(result, "result block must be called with nil.")
      resultExpectation.fulfill()
    }

    waitForExpectations(timeout: 1)
  }

  func testHandleMethodCall_nonExistMethods() {
    let call = FlutterMethodCall(methodName: "nonExist", arguments: nil)

    let mockChannel = MockMethodChannel()
    let mockShortcutItemProvider = MockShortcutItemProvider()
    let mockShortcutItemParser = MockShortcutItemParser()

    let plugin = QuickActionsPlugin(
      channel: mockChannel,
      shortcutItemProvider: mockShortcutItemProvider,
      shortcutItemParser: mockShortcutItemParser)

    let resultExpectation = expectation(description: "result block must be called.")

    plugin.handle(call) { result in
      XCTAssertEqual(
        result as? NSObject, FlutterMethodNotImplemented,
        "result block must be called with FlutterMethodNotImplemented")
      resultExpectation.fulfill()
    }

    waitForExpectations(timeout: 1)
  }

  func testApplicationPerformActionForShortcutItem() {
    let mockChannel = MockMethodChannel()
    let mockShortcutItemProvider = MockShortcutItemProvider()
    let mockShortcutItemParser = MockShortcutItemParser()

    let plugin = QuickActionsPlugin(
      channel: mockChannel,
      shortcutItemProvider: mockShortcutItemProvider,
      shortcutItemParser: mockShortcutItemParser)

    let item = UIApplicationShortcutItem(
      type: "SearchTheThing",
      localizedTitle: "Search the thing",
      localizedSubtitle: nil,
      icon: UIApplicationShortcutIcon(templateImageName: "search_the_thing.png"),
      userInfo: nil)

    let invokeMethodExpectation = expectation(description: "invokeMethod must be called.")
    mockChannel.invokeMethodStub = { method, arguments in
      XCTAssertEqual(method, "launch")
      XCTAssertEqual(arguments as? String, item.type)
      invokeMethodExpectation.fulfill()
    }

    let actionResult = plugin.application(
      UIApplication.shared,
      performActionFor: item
    ) { success in /* no-op */ }

    XCTAssert(actionResult, "performActionForShortcutItem must return true.")
    waitForExpectations(timeout: 1)
  }

  func testApplicationDidFinishLaunchingWithOptions_launchWithShortcut() {
    let mockChannel = MockMethodChannel()
    let mockShortcutItemProvider = MockShortcutItemProvider()
    let mockShortcutItemParser = MockShortcutItemParser()

    let plugin = QuickActionsPlugin(
      channel: mockChannel,
      shortcutItemProvider: mockShortcutItemProvider,
      shortcutItemParser: mockShortcutItemParser)

    let item = UIApplicationShortcutItem(
      type: "SearchTheThing",
      localizedTitle: "Search the thing",
      localizedSubtitle: nil,
      icon: UIApplicationShortcutIcon(templateImageName: "search_the_thing.png"),
      userInfo: nil)

    let launchResult = plugin.application(
      UIApplication.shared,
      didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey.shortcutItem: item])
    XCTAssertFalse(
      launchResult, "didFinishLaunchingWithOptions must return false if launched from shortcut.")
  }

  func testApplicationDidFinishLaunchingWithOptions_launchWithoutShortcut() {
    let mockChannel = MockMethodChannel()
    let mockShortcutItemProvider = MockShortcutItemProvider()
    let mockShortcutItemParser = MockShortcutItemParser()

    let plugin = QuickActionsPlugin(
      channel: mockChannel,
      shortcutItemProvider: mockShortcutItemProvider,
      shortcutItemParser: mockShortcutItemParser)

    let launchResult = plugin.application(UIApplication.shared, didFinishLaunchingWithOptions: [:])
    XCTAssert(
      launchResult, "didFinishLaunchingWithOptions must return true if not launched from shortcut.")
  }

  func testApplicationDidBecomeActive_launchWithoutShortcut() {
    let mockChannel = MockMethodChannel()
    let mockShortcutItemProvider = MockShortcutItemProvider()
    let mockShortcutItemParser = MockShortcutItemParser()

    let plugin = QuickActionsPlugin(
      channel: mockChannel,
      shortcutItemProvider: mockShortcutItemProvider,
      shortcutItemParser: mockShortcutItemParser)

    mockChannel.invokeMethodStub = { _, _ in
      XCTFail("invokeMethod should not be called if launch without shortcut.")
    }

    let launchResult = plugin.application(UIApplication.shared, didFinishLaunchingWithOptions: [:])
    XCTAssert(
      launchResult, "didFinishLaunchingWithOptions must return true if not launched from shortcut.")

    plugin.applicationDidBecomeActive(UIApplication.shared)
  }

  func testApplicationDidBecomeActive_launchWithShortcut() {
    let item = UIApplicationShortcutItem(
      type: "SearchTheThing",
      localizedTitle: "Search the thing",
      localizedSubtitle: nil,
      icon: UIApplicationShortcutIcon(templateImageName: "search_the_thing.png"),
      userInfo: nil)

    let mockChannel = MockMethodChannel()
    let mockShortcutItemProvider = MockShortcutItemProvider()
    let mockShortcutItemParser = MockShortcutItemParser()

    let plugin = QuickActionsPlugin(
      channel: mockChannel,
      shortcutItemProvider: mockShortcutItemProvider,
      shortcutItemParser: mockShortcutItemParser)

    let invokeMethodExpectation = expectation(description: "invokeMethod must be called.")
    mockChannel.invokeMethodStub = { method, arguments in
      XCTAssertEqual(method, "launch")
      XCTAssertEqual(arguments as? String, item.type)
      invokeMethodExpectation.fulfill()
    }

    let launchResult = plugin.application(
      UIApplication.shared,
      didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey.shortcutItem: item])

    XCTAssertFalse(
      launchResult, "didFinishLaunchingWithOptions must return false if launched from shortcut.")

    plugin.applicationDidBecomeActive(UIApplication.shared)
    waitForExpectations(timeout: 1)
  }

  func testApplicationDidBecomeActive_launchWithShortcut_becomeActiveTwice() {
    let item = UIApplicationShortcutItem(
      type: "SearchTheThing",
      localizedTitle: "Search the thing",
      localizedSubtitle: nil,
      icon: UIApplicationShortcutIcon(templateImageName: "search_the_thing.png"),
      userInfo: nil)

    let mockChannel = MockMethodChannel()
    let mockShortcutItemProvider = MockShortcutItemProvider()
    let mockShortcutItemParser = MockShortcutItemParser()

    let plugin = QuickActionsPlugin(
      channel: mockChannel,
      shortcutItemProvider: mockShortcutItemProvider,
      shortcutItemParser: mockShortcutItemParser)

    let invokeMethodExpectation = expectation(description: "invokeMethod must be called.")

    var invokeMehtodCount = 0
    mockChannel.invokeMethodStub = { method, arguments in
      invokeMehtodCount += 1
      invokeMethodExpectation.fulfill()
    }

    let launchResult = plugin.application(
      UIApplication.shared,
      didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey.shortcutItem: item])

    XCTAssertFalse(
      launchResult, "didFinishLaunchingWithOptions must return false if launched from shortcut.")

    plugin.applicationDidBecomeActive(UIApplication.shared)
    waitForExpectations(timeout: 1)

    XCTAssertEqual(invokeMehtodCount, 1, "shortcut should only be handled once per launch.")
  }

}
