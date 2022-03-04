// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@testable import file_selector_macos
import FlutterMacOS
import XCTest

class TestPanelController: NSObject, PanelController {
  // The last panels that the relevant display methods were called on.
  public var savePanel: NSSavePanel?
  public var openPanel: NSOpenPanel?

  // Mock return values for the display methods.
  public var saveURL: URL?
  public var openURLs: [URL]?

  func display(_ panel: NSSavePanel, for window: NSWindow?, completionHandler handler: @escaping (URL?) -> Void) {
    savePanel = panel
    handler(saveURL)
  }

  func display(_ panel: NSOpenPanel, for window: NSWindow?, completionHandler handler: @escaping ([URL]?) -> Void) {
    openPanel = panel
    handler(openURLs)
  }
}

class TestViewProvider: NSObject, ViewProvider {
  var view: NSView? {
    get {
      window?.contentView
    }
  }
  var window: NSWindow? = NSWindow()
}

class exampleTests: XCTestCase {

  func testOpenSimple() throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let returnPath = "/foo/bar"
    panelController.openURLs = [URL(fileURLWithPath: returnPath)]

    let called = XCTestExpectation()
    let call = FlutterMethodCall(methodName: "openFile", arguments: [:])
    plugin.handle(call) { result in
      XCTAssertEqual((result as! [String]?)![0], returnPath)
      called.fulfill()
    }

    wait(for: [called], timeout: 0.5)
    XCTAssertNotNil(panelController.openPanel)
    if let panel = panelController.openPanel {
      XCTAssertTrue(panel.canChooseFiles)
      // For consistency across platforms, directory selection is disabled.
      XCTAssertFalse(panel.canChooseDirectories)
    }
  }

  func testOpenWithArguments() throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let returnPath = "/foo/bar"
    panelController.openURLs = [URL(fileURLWithPath: returnPath)]

    let called = XCTestExpectation()
    let call = FlutterMethodCall(
      methodName: "openFile",
      arguments: [
        "initialDirectory": "/some/dir",
        "suggestedName": "a name",
        "confirmButtonText": "Open it!",
      ]
    )
    plugin.handle(call) { result in
      XCTAssertEqual((result as! [String]?)![0], returnPath)
      called.fulfill()
    }

    wait(for: [called], timeout: 0.5)
    XCTAssertNotNil(panelController.openPanel)
    if let panel = panelController.openPanel {
      XCTAssertEqual(panel.directoryURL?.path, "/some/dir")
      XCTAssertEqual(panel.nameFieldStringValue, "a name")
      XCTAssertEqual(panel.prompt, "Open it!")
    }
  }

  func testOpenMultiple() throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let returnPaths = ["/foo/bar", "/foo/baz"]
    panelController.openURLs = returnPaths.map({ path in URL(fileURLWithPath: path) })

    let called = XCTestExpectation()
    let call = FlutterMethodCall(
      methodName: "openFile",
      arguments: ["multiple": true]
    )
    plugin.handle(call) { result in
      let paths = (result as! [String]?)!
      XCTAssertEqual(paths.count, returnPaths.count)
      XCTAssertEqual(paths[0], returnPaths[0])
      XCTAssertEqual(paths[1], returnPaths[1])
      called.fulfill()
    }

    wait(for: [called], timeout: 0.5)
    XCTAssertNotNil(panelController.openPanel)
  }

  func testOpenWithFilter() throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let returnPath = "/foo/bar"
    panelController.openURLs = [URL(fileURLWithPath: returnPath)]

    let called = XCTestExpectation()
    let call = FlutterMethodCall(
      methodName: "openFile",
      arguments: [
        "acceptedTypes": [
          "extensions": ["txt", "json"],
          "UTIs": ["public.text", "public.image"],
        ]
      ]
    )
    plugin.handle(call) { result in
      XCTAssertEqual((result as! [String]?)![0], returnPath)
      called.fulfill()
    }

    wait(for: [called], timeout: 0.5)
    XCTAssertNotNil(panelController.openPanel)
    if let panel = panelController.openPanel {
      XCTAssertEqual(panel.allowedFileTypes, ["txt", "json", "public.text", "public.image"])
    }
  }

  func testOpenCancel() throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let called = XCTestExpectation()
    let call = FlutterMethodCall(methodName: "openFile", arguments: [:])
    plugin.handle(call) { result in
      XCTAssertNil(result)
      called.fulfill()
    }

    wait(for: [called], timeout: 0.5)
    XCTAssertNotNil(panelController.openPanel)
  }

  func testSaveSimple() throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let returnPath = "/foo/bar"
    panelController.saveURL = URL(fileURLWithPath: returnPath)

    let called = XCTestExpectation()
    let call = FlutterMethodCall(methodName: "getSavePath", arguments: [:])
    plugin.handle(call) { result in
      XCTAssertEqual(result as! String?, returnPath)
      called.fulfill()
    }

    wait(for: [called], timeout: 0.5)
    XCTAssertNotNil(panelController.savePanel)
  }

  func testSaveWithArguments() throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let returnPath = "/foo/bar"
    panelController.saveURL = URL(fileURLWithPath: returnPath)

    let called = XCTestExpectation()
    let call = FlutterMethodCall(
      methodName: "getSavePath",
      arguments: [
        "initialDirectory": "/some/dir",
        "confirmButtonText": "Save it!",
      ]
    )
    plugin.handle(call) { result in
      XCTAssertEqual(result as! String?, returnPath)
      called.fulfill()
    }

    wait(for: [called], timeout: 0.5)
    XCTAssertNotNil(panelController.savePanel)
    if let panel = panelController.savePanel {
      XCTAssertEqual(panel.directoryURL?.path, "/some/dir")
      XCTAssertEqual(panel.prompt, "Save it!")
    }
  }

  func testSaveCancel() throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let called = XCTestExpectation()
    let call = FlutterMethodCall(methodName: "getSavePath", arguments: [:])
    plugin.handle(call) { result in
      XCTAssertNil(result)
      called.fulfill()
    }

    wait(for: [called], timeout: 0.5)
    XCTAssertNotNil(panelController.savePanel)
  }

  func testGetDirectorySimple() throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let returnPath = "/foo/bar"
    panelController.openURLs = [URL(fileURLWithPath: returnPath)]

    let called = XCTestExpectation()
    let call = FlutterMethodCall(methodName: "getDirectoryPath", arguments: [:])
    plugin.handle(call) { result in
      XCTAssertEqual(result as! String?, returnPath)
      called.fulfill()
    }

    wait(for: [called], timeout: 0.5)
    XCTAssertNotNil(panelController.openPanel)
    if let panel = panelController.openPanel {
      XCTAssertTrue(panel.canChooseDirectories)
      // For consistency across platforms, file selection is disabled.
      XCTAssertFalse(panel.canChooseFiles)
      // The Dart API only allows a single directory to be returned, so users shouldn't be allowed
      // to select multiple.
      XCTAssertFalse(panel.allowsMultipleSelection)
    }
  }

  func testGetDirectoryCancel() throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let called = XCTestExpectation()
    let call = FlutterMethodCall(methodName: "getDirectoryPath", arguments: [:])
    plugin.handle(call) { result in
      XCTAssertNil(result)
      called.fulfill()
    }

    wait(for: [called], timeout: 0.5)
    XCTAssertNotNil(panelController.openPanel)
  }

}
