// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FlutterMacOS
import Foundation

/// Protocol for showing panels, allowing for depenedncy injection in tests.
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

public class FileSelectorPlugin: NSObject, FlutterPlugin {
  private let registrar: FlutterPluginRegistrar
  private let panelController: PanelController

  private let openMethod = "openFile"
  private let openDirectoryMethod = "getDirectoryPath"
  private let saveMethod = "getSavePath"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "plugins.flutter.io/file_selector",
      binaryMessenger: registrar.messenger)
    let instance = FileSelectorPlugin(
      registrar: registrar,
      panelController: DefaultPanelController())
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  init(registrar: FlutterPluginRegistrar, panelController: PanelController) {
    self.registrar = registrar
    self.panelController = panelController
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments = (call.arguments ?? [:]) as! [String: Any]
    switch call.method {
    case openMethod,
         openDirectoryMethod:
      let choosingDirectory = call.method == openDirectoryMethod
      let panel = NSOpenPanel()
      configure(panel: panel, with: arguments)
      configure(openPanel: panel, with: arguments, choosingDirectory: choosingDirectory)
      panelController.display(panel, for: registrar.view?.window) { (selection: [URL]?) in
        if (choosingDirectory) {
          result(selection?.first?.path)
        } else {
          result(selection?.map({ item in item.path }))
        }
      }
    case saveMethod:
      let panel = NSSavePanel()
      configure(panel: panel, with: arguments)
      panelController.display(panel, for: registrar.view?.window) { (selection: URL?) in
        result(selection?.path)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// Configures an NSSavePanel based on channel method call arguments.
  /// - Parameters:
  ///   - panel: The panel to configure.
  ///   - arguments: The arguments dictionary from a FlutterMethodCall to this plugin.
  private func configure(panel: NSSavePanel, with arguments: [String: Any]) {
    if let initialDirectory = getNonNullStringValue(for: "initialDirectory", from: arguments) {
      panel.directoryURL = URL(fileURLWithPath: initialDirectory)
    }
    if let suggestedName = getNonNullStringValue(for: "suggestedName", from: arguments) {
      panel.nameFieldStringValue = suggestedName
    }
    if let confirmButtonText = getNonNullStringValue(for: "confirmButtonText", from: arguments) {
      panel.prompt = confirmButtonText
    }

    let acceptedTypeGroups = getNonNullValue(
      for: "acceptedTypeGroups",
      from: arguments
    ) as! [[String: Any]]?
    if let acceptedTypeGroups = acceptedTypeGroups {
      // macOS doesn't support filter groups, so combine all allowed types into a flat list.
      var allowedTypes: [String] = []
      for filter in acceptedTypeGroups {
        let extensions = getNonNullStringArrayValue(for: "extensions", from: filter)
        let mimeTypes = getNonNullStringArrayValue(for: "mimeTypes", from: filter)
        let macUTIs = getNonNullStringArrayValue(for: "macUTIs", from: filter)
        // If any group allows everything, don't do any filtering.
        if (extensions.count == 0 && mimeTypes.count == 0 && macUTIs.count == 0) {
          allowedTypes.removeAll();
          break;
        }
        allowedTypes.append(contentsOf: extensions)
        allowedTypes.append(contentsOf: macUTIs)
        // TODO: Add support for mimeTypes in macOS 11+.
      }
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
    with arguments: [String: Any],
    choosingDirectory: Bool
  ) {
    panel.allowsMultipleSelection =
      getNonNullValue(for: "multiple", from: arguments) as! Bool? ?? false
    panel.canChooseDirectories = choosingDirectory;
    panel.canChooseFiles = !choosingDirectory;
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

/// Returns the value for the given key from the provided dictionary, unless the value is NSNull
/// in which case it returns nil.
/// - Parameters:
///   - key: The key to get a value for.
///   - dictionary: The dictionary to get the value from.
/// - Returns: The value, or nil for NSNull.
private func getNonNullValue(for key: String, from dictionary: [String: Any]) -> Any? {
  let value = dictionary[key];
  return value is NSNull ? nil : value;
}

/// A convenience wrapper for getNonNullValue for string values.
private func getNonNullStringValue(for key: String, from dictionary: [String: Any]) -> String? {
  return getNonNullValue(for: key, from: dictionary) as! String?
}

/// A convenience wrapper for getNonNullValue for array-of-string values.
/// - Parameters:
///   - key: The key to get a value for.
///   - dictionary: The dictionary to get the value from.
/// - Returns: The value, or an empty array for nil for NSNull.
private func getNonNullStringArrayValue(
  for key: String,
  from dictionary: [String: Any]
) -> [String] {
  return getNonNullValue(for: key, from: dictionary) as! [String]? ?? []
}
