// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:args/command_runner.dart';
import 'package:flutter_plugin_tools/src/common.dart';

/// A script to read a JSON String and output the value of a key.
class MapReadJsonCommand extends Command<void> {

   /// Constructor
  MapReadJsonCommand() {
    argParser.addOption(
      _kJsonOption,
      help:
          'The JSON String to read.',
    );
    argParser.addOption(
      _kKeyOption,
      help:
          'The key in the JSON to be extract. The value of this key will be the output.',
    );
  }

  @override
  String get description => 'A simple command reads the JSON String indicated from $_kJsonOption, '
                            'extract the value of the key indicated by $_kKeyOption, outputs the value.\n'
                            'Only JSON formatted as a map is supported. The key must be at top level.';

  @override
  String get name => 'read-map-json';

  static const String _kJsonOption = 'json';
  static const String _kKeyOption = 'key';

  @override
  Future<void> run() async {
    final String jsonString = argResults[_kJsonOption] as String;
    final String key = argResults[_kKeyOption] as String;
    if (jsonString == null) {
      printErrorAndExit(errorMessage: '$_kJsonOption is not specified');
    }
    if (key == null) {
      printErrorAndExit(errorMessage: '$_kKeyOption is not specified');
    }
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    print(jsonMap[key]);
  }
}