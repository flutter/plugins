import 'dart:async';

import 'package:e2e/e2e.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';


import 'dart:convert';
import 'dart:typed_data';
import 'dart:html';

import 'package:file_picker_web/file_picker_web.dart';
import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';

import 'package:platform_detect/test_utils.dart' as platform;

final String expectedStringContents = 'Hello, world!';
final expectedSize = expectedStringContents.length;
final Uint8List bytes = utf8.encode(expectedStringContents);
final File textFile = File([bytes], 'hello.txt');

/// Test Markers
void main() {
  E2EWidgetsFlutterBinding.ensureInitialized() as E2EWidgetsFlutterBinding;

  test('Select a single file to load', () async {
    final mockInput = FileUploadInputElement();

    final plugin = FilePickerPlugin(
        overrides: FilePickerPluginTestOverrides()
          ..createFileInputElement = ((_) => mockInput)
          ..getFilesFromInputElement = ((_) => [textFile])
    );

    // Call load file
    final files = plugin.loadFile();
    // Mock selection of a file
    mockInput.dispatchEvent(Event('change'));

    // Expect the file to complete
    expect(files, completes);

    // Expect that we can read from the file
    final loadedFiles = await files;
    final loadedFile = loadedFiles.first;
    expect(loadedFile.readAsBytes(), completion(isNotEmpty));
    expect(loadedFile.length(), completion(equals(expectedSize)));
    expect(loadedFile.name, 'hello.txt');
  });
}
