// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  input: 'pigeons/messages.dart',
  javaOut:
      'android/src/main/java/io/flutter/plugins/file_selector/Messages.java',
  javaOptions: JavaOptions(
      className: 'Messages', package: 'io.flutter.plugins.file_selector'),
  dartOut: 'lib/src/messages.g.dart',
  dartTestOut: 'test/messages_test.g.dart',
  copyrightHeader: 'pigeons/copyright.txt',
))
class SelectionOptions {
  SelectionOptions({
    this.allowMultiple = false,
    this.allowedTypes = const <String?>[],
  });
  bool allowMultiple;

  List<String?> allowedTypes;
}

@HostApi(dartHostTestHandler: 'TestFileSelectorApi')
abstract class FileSelectorApi {
  @async
  List<String?> openFiles(
    SelectionOptions options,
  );
  @async
  String? getDirectoryPath(
    String? initialDirectory,
  );
}
