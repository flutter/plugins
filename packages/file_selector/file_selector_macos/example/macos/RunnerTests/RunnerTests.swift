// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import file_selector_macos
import XCTest

class TestPanelController: NSObject, FLTPanelController {
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

// Unused stub for TestRegistrar.
class TestMessenger: NSObject, FlutterBinaryMessenger {
  func send(onChannel channel: String, message: Data?) {}
  func send(onChannel channel: String, message: Data?, binaryReply callback: FlutterBinaryReply? = nil) {}
  func setMessageHandlerOnChannel(_ channel: String, binaryMessageHandler handler: FlutterBinaryMessageHandler? = nil) -> FlutterBinaryMessengerConnection { return 0 }
  func cleanupConnection(_ connection: FlutterBinaryMessengerConnection) {}
}

// Unused stub for TestRegistrar.
class TestTextureRegistry: NSObject, FlutterTextureRegistry {
  func register(_ texture: FlutterTexture) -> Int64 { return 0 }
  func textureFrameAvailable(_ textureId: Int64) {}
  func unregisterTexture(_ textureId: Int64) {}
}

class TestRegistrar: NSObject, FlutterPluginRegistrar {
  var view: NSView?

  // Unused.
  var messenger: FlutterBinaryMessenger = TestMessenger()
  var textures: FlutterTextureRegistry = TestTextureRegistry()
  func addMethodCallDelegate(_ delegate: FlutterPlugin, channel: FlutterMethodChannel) {}
}

class exampleTests: XCTestCase {

  func testExample() throws {
    let plugin = FLTFileSelectorPlugin()
    XCTAssertNotNil(plugin)
  }

  func testOpenSimple() throws {
    let window = NSWindow()
    let registrar = TestRegistrar()
    registrar.view = window.contentView
    let panelController = TestPanelController()
    let plugin = FLTFileSelectorPlugin(registrar: registrar, panelController: panelController)

    let returnPath = "/foo/bar"
    panelController.openURLs = [URL(fileURLWithPath: returnPath)]

    let called = XCTestExpectation()
    let call = FlutterMethodCall(methodName: "openFile", arguments: [:])
    var response : [String]?
    plugin.handle(call, result: { result in
      response = result as! [String]?
      called.fulfill()
    })

    wait(for: [called], timeout: 0.5)
    XCTAssertEqual(response![0], returnPath)
    XCTAssertNotNil(panelController.openPanel)
  }

  func testSaveSimple() throws {
    let window = NSWindow()
    let registrar = TestRegistrar()
    registrar.view = window.contentView
    let panelController = TestPanelController()
    let plugin = FLTFileSelectorPlugin(registrar: registrar, panelController: panelController)

    let returnPath = "/foo/bar"
    panelController.saveURL = URL(fileURLWithPath: returnPath)

    let called = XCTestExpectation()
    let call = FlutterMethodCall(methodName: "getSavePath", arguments: [:])
    var response : String?
    plugin.handle(call, result: { result in
      response = result as! String?
      called.fulfill()
    })

    wait(for: [called], timeout: 0.5)
    XCTAssertEqual(response, returnPath)
    XCTAssertNotNil(panelController.savePanel)
  }

}
