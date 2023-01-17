// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FlutterMacOS
import Foundation

/// Protocol for showing panels, allowing for depenedency injection in tests.
protocol PanelController {
  /// Displays the given save panel, and provides the selected URL, or nil if the panel is
  /// cancelled, to the handler.
  /// - Parameters:
  ///   - panel: The panel to show.
  ///   - window: The window to display the panel for.
  ///   - completionHandler: The completion handler to receive the results.
  func display(
    _ panel: NSSavePanel,
    for window: NSWindow?,
    completionHandler: @escaping (URL?) -> Void);

  /// Displays the given open panel, and provides the selected URLs, or nil if the panel is
  /// cancelled, to the handler.
  /// - Parameters:
  ///   - panel: The panel to show.
  ///   - window: The window to display the panel for.
  ///   - completionHandler: The completion handler to receive the results.
  func display(
    _ panel: NSOpenPanel,
    for window: NSWindow?,
    completionHandler: @escaping ([URL]?) -> Void);
}

/// Protocol to provide access to the Flutter view, allowing for dependency injection in tests.
///
/// This is necessary because Swift doesn't allow for only partially implementing a protocol, so
/// a stub implementation of FlutterPluginRegistrar for tests would break any time something was
/// added to that protocol.
protocol ViewProvider {
  /// Returns the view associated with the Flutter content.
  var view: NSView? { get }
}

public class FileSelectorPlugin: NSObject, FlutterPlugin, FileSelectorApi {
  private let viewProvider: ViewProvider
  private let panelController: PanelController

  private let openMethod = "openFile"
  private let openDirectoryMethod = "getDirectoryPath"
  private let saveMethod = "getSavePath"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = FileSelectorPlugin(
      viewProvider: DefaultViewProvider(registrar: registrar),
      panelController: DefaultPanelController())
    FileSelectorApiSetup.setUp(binaryMessenger: registrar.messenger, api: instance)
  }

  init(viewProvider: ViewProvider, panelController: PanelController) {
    self.viewProvider = viewProvider
    self.panelController = panelController
  }

  func displayOpenPanel(options: OpenPanelOptions, completion: @escaping ([String?]) -> Void) {

    let panel = NSOpenPanel()
    configure(openPanel: panel, with: options)
    panelController.display(panel, for: viewProvider.view?.window) { (selection: [URL]?) in
      completion(selection?.map({ item in item.path }) ?? [])
    }
  }

  func displaySavePanel(options: SavePanelOptions, completion: @escaping (String?) -> Void) {
    let panel = NSSavePanel()
    configure(panel: panel, with: options)
    panelController.display(panel, for: viewProvider.view?.window) { (selection: URL?) in
      completion(selection?.path)
    }
  }

  /// Configures an NSSavePanel based on channel method call arguments.
  /// - Parameters:
  ///   - panel: The panel to configure.
  ///   - arguments: The arguments dictionary from a FlutterMethodCall to this plugin.
  private func configure(panel: NSSavePanel, with options: SavePanelOptions) {
    if let directoryPath = options.directoryPath {
      panel.directoryURL = URL(fileURLWithPath: directoryPath)
    }
    if let suggestedName = options.nameFieldStringValue {
      panel.nameFieldStringValue = suggestedName
    }
    if let prompt = options.prompt {
      panel.prompt = prompt
    }

    if let acceptedTypes = options.allowedFileTypes {
      var allowedTypes: [String] = []
      // The array values are non-null by convention even though Pigeon can't currently express
      // that via the types; see messages.dart.
      allowedTypes.append(contentsOf: acceptedTypes.extensions.map({ $0! }))
      allowedTypes.append(contentsOf: acceptedTypes.utis.map({ $0! }))
      // TODO: Add support for mimeTypes in macOS 11+. See
      // https://github.com/flutter/flutter/issues/117843

      if !allowedTypes.isEmpty {
        panel.allowedFileTypes = allowedTypes
      }
    }
  }

  /// Configures an NSOpenPanel based on channel method call arguments.
  /// - Parameters:
  ///   - panel: The panel to configure.
  ///   - arguments: The arguments dictionary from a FlutterMethodCall to this plugin.
  ///   - choosingDirectory: True if the panel should allow choosing directories rather than files.
  private func configure(
    openPanel panel: NSOpenPanel,
    with options: OpenPanelOptions
  ) {
    configure(panel: panel, with: options.baseOptions)
    panel.allowsMultipleSelection = options.allowsMultipleSelection
    panel.canChooseDirectories = options.canChooseDirectories;
    panel.canChooseFiles = options.canChooseFiles;
  }
}

/// Non-test implementation of PanelController that calls the standard methods to display the panel
/// either as a sheet (if a window is provided) or modal (if not).
private class DefaultPanelController: PanelController {
  func display(
    _ panel: NSSavePanel,
    for window: NSWindow?,
    completionHandler: @escaping (URL?) -> Void
  ) {
    let completionAdapter = { response in
      completionHandler((response == NSApplication.ModalResponse.OK) ? panel.url : nil)
    }
    if let window = window {
      panel.beginSheetModal(for: window, completionHandler: completionAdapter)
    } else {
      completionAdapter(panel.runModal())
    }
  }

  func display(
    _ panel: NSOpenPanel,
    for window: NSWindow?,
    completionHandler: @escaping ([URL]?) -> Void
  ) {
    let completionAdapter = { response in
      completionHandler((response == NSApplication.ModalResponse.OK) ? panel.urls : nil)
    }
    if let window = window {
      panel.beginSheetModal(for: window, completionHandler: completionAdapter)
    } else {
      completionAdapter(panel.runModal())
    }
  }
}

/// Non-test implementation of PanelController that forwards to the plugin registrar.
private class DefaultViewProvider: ViewProvider {
  private let registrar: FlutterPluginRegistrar

  init(registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
  }

  var view: NSView? {
    get {
      registrar.view
    }
  }
}
