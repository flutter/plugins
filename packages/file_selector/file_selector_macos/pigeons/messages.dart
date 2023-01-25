// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  input: 'pigeons/messages.dart',
  swiftOut: 'macos/Classes/messages.g.swift',
  dartOut: 'lib/src/messages.g.dart',
  dartTestOut: 'test/messages_test.g.dart',
  copyrightHeader: 'pigeons/copyright.txt',
))

/// A Pigeon representation of the macOS portion of an `XTypeGroup`.
class AllowedTypes {
  const AllowedTypes({
    this.extensions = const <String>[],
    this.mimeTypes = const <String>[],
    this.utis = const <String>[],
  });

  // TODO(stuartmorgan): Declare these as non-nullable generics once
  // https://github.com/flutter/flutter/issues/97848 is fixed. In practice,
  // the values will never be null, and the native implementation assumes that.
  final List<String?> extensions;
  final List<String?> mimeTypes;
  final List<String?> utis;
}

/// Options for save panels.
///
/// These correspond to NSSavePanel properties (which are, by extension
/// NSOpenPanel properties as well).
class SavePanelOptions {
  const SavePanelOptions({
    this.allowedFileTypes,
    this.directoryPath,
    this.nameFieldStringValue,
    this.prompt,
  });
  final AllowedTypes? allowedFileTypes;
  final String? directoryPath;
  final String? nameFieldStringValue;
  final String? prompt;
}

/// Options for open panels.
///
/// These correspond to NSOpenPanel properties.
class OpenPanelOptions extends SavePanelOptions {
  const OpenPanelOptions({
    this.allowsMultipleSelection = false,
    this.canChooseDirectories = false,
    this.canChooseFiles = true,
    this.baseOptions = const SavePanelOptions(),
  });
  final bool allowsMultipleSelection;
  final bool canChooseDirectories;
  final bool canChooseFiles;
  // NSOpenPanel inherits from NSSavePanel, so shares all of its options.
  // Ideally this would be done with inheritance rather than composition, but
  // Pigeon doesn't currently support data class inheritance:
  // https://github.com/flutter/flutter/issues/117819.
  final SavePanelOptions baseOptions;
}

@HostApi(dartHostTestHandler: 'TestFileSelectorApi')
abstract class FileSelectorApi {
  /// Shows an open panel with the given [options], returning the list of
  /// selected paths.
  ///
  /// An empty list corresponds to a cancelled selection.
  // TODO(stuartmorgan): Declare this return as a non-nullable generic once
  // https://github.com/flutter/flutter/issues/97848 is fixed. In practice,
  // the values will never be null, and the calling code assumes that.
  @async
  List<String?> displayOpenPanel(OpenPanelOptions options);

  /// Shows a save panel with the given [options], returning the selected path.
  ///
  /// A null return corresponds to a cancelled save.
  @async
  String? displaySavePanel(SavePanelOptions options);
}
