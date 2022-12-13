// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

private let elementWaitingTime: TimeInterval = 30

class RunnerUITests: XCTestCase {

  private var exampleApp: XCUIApplication!

  override func setUp() {
    super.setUp()
    self.continueAfterFailure = false
    exampleApp = XCUIApplication()
  }

  override func tearDown() {
    super.tearDown()
    exampleApp.terminate()
    exampleApp = nil
  }

  func testQuickActionWithFreshStart() {
    let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    let quickActionsAppIcon = springboard.icons["quick_actions_example"]
    if !quickActionsAppIcon.waitForExistence(timeout: elementWaitingTime) {
      XCTFail(
        "Failed due to not able to find the example app from springboard with \(elementWaitingTime) seconds. Springboard debug description: \(springboard.debugDescription)"
      )
    }

    quickActionsAppIcon.press(forDuration: 2)

    let actionTwo = springboard.buttons["Action two"]
    if !actionTwo.waitForExistence(timeout: elementWaitingTime) {
      XCTFail(
        "Failed due to not able to find the actionTwo button from springboard with \(elementWaitingTime) seconds. Springboard debug description: \(springboard.debugDescription)"
      )
    }

    actionTwo.tap()

    let actionTwoConfirmation = exampleApp.otherElements["action_two"]
    if !actionTwoConfirmation.waitForExistence(timeout: elementWaitingTime) {
      XCTFail(
        "Failed due to not able to find the actionTwoConfirmation in the app with \(elementWaitingTime) seconds. Springboard debug description: \(springboard.debugDescription)"
      )
    }

    XCTAssert(actionTwoConfirmation.exists)
  }
}
