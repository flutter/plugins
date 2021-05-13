// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common.dart';

/// A script to read a JSON String and output the value of a key.
class MapReadJsonCommand extends Command<void> {
  /// Constructor
  MapReadJsonCommand(this.fileSystem) {
    argParser.addOption(
      _kJsonOption,
      help:
          'The path to a .json file to read from. The content of the file must be a valid json format.',
    );
    argParser.addOption(
      _kKeyOption,
      help:
          'The key in the JSON to be extract. The value of this key will be the output.',
    );
  }

  /// The file system used to read the json file from.
  final FileSystem fileSystem;

  @override
  String get description =>
      'A simple command reads the JSON String in the .json file indicated by $_kJsonOption, '
      'extract the value of the key indicated by $_kKeyOption, outputs the value.\n'
      'Only JSON formatted as a map is supported. The key must be at top level.';

  @override
  String get name => 'read-map-json';

  static const String _kJsonOption = 'json-file';
  static const String _kKeyOption = 'key';

  @override
  Future<void> run() async {
    final String jsonFilePath = argResults[_kJsonOption] as String;
    final String key = argResults[_kKeyOption] as String;
    if (jsonFilePath == null) {
      printErrorAndExit(errorMessage: '$_kJsonOption is not specified');
    }
    if (key == null) {
      printErrorAndExit(errorMessage: '$_kKeyOption is not specified');
    }
    final File jsonFile = fileSystem.file(jsonFilePath);
    final String jsonString = jsonFile.readAsStringSync();
    final Map<String, dynamic> jsonMap =
        jsonDecode(jsonString) as Map<String, dynamic>;
    print(jsonMap[key]);
  }
}
