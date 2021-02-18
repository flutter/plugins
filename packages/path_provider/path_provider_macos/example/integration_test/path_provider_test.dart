// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.9

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('getTemporaryDirectory', (WidgetTester tester) async {
    final PathProviderPlatform provider = PathProviderPlatform.instance;
    final String result = await provider.getTemporaryPath();
    _verifySampleFile(result, 'temporaryDirectory');
  });

  testWidgets('getApplicationDocumentsDirectory', (WidgetTester tester) async {
    final PathProviderPlatform provider = PathProviderPlatform.instance;
    final String result = await provider.getApplicationDocumentsPath();
    _verifySampleFile(result, 'applicationDocuments');
  });

  testWidgets('getApplicationSupportDirectory', (WidgetTester tester) async {
    final PathProviderPlatform provider = PathProviderPlatform.instance;
    final String result = await provider.getApplicationSupportPath();
    _verifySampleFile(result, 'applicationSupport');
  });

  testWidgets('getLibraryDirectory', (WidgetTester tester) async {
    final PathProviderPlatform provider = PathProviderPlatform.instance;
    final String result = await provider.getLibraryPath();
    _verifySampleFile(result, 'library');
  });

  testWidgets('getDownloadsDirectory', (WidgetTester tester) async {
    final PathProviderPlatform provider = PathProviderPlatform.instance;
    final String result = await provider.getDownloadsPath();
    // Create if necessary, since the native implementation doesn't guarantee
    // that the folder exists.
    _verifySampleFile(result, 'downloads', createDirectory: true);
  });
}

/// Verify a file called [name] in [directoryPath] by recreating it with test
/// contents when necessary.
///
/// If [createDirectory] is true, the directory will be created if missing.
void _verifySampleFile(
  String directoryPath,
  String name, {
  bool createDirectory = false,
}) {
  final Directory directory = Directory(directoryPath);
  final File file = File('${directory.path}${Platform.pathSeparator}$name');

  if (file.existsSync()) {
    file.deleteSync();
    expect(file.existsSync(), isFalse);
  }

  if (createDirectory) {
    directory.createSync(recursive: true);
  }

  file.writeAsStringSync('Hello world!');
  expect(file.readAsStringSync(), 'Hello world!');
  expect(directory.listSync(), isNotEmpty);
  file.deleteSync();
}
