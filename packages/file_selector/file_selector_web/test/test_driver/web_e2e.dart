import 'dart:async';

import 'package:e2e/e2e.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';


import 'dart:convert';
import 'dart:typed_data';
import 'dart:html';

import 'package:file_selector_web/file_selector_web.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

import 'package:platform_detect/test_utils.dart' as platform;

import 'dart:developer';

final String domElementId = '__file_selector_web-file-input';

final textGroup = XTypeGroup(label: 'test',
    fileTypes: [
      XType(extension: 'json', mime: 'application/json'),
      XType(extension: 'txt', mime: 'text/plain'),
    ]);

final String expectedStringContents = 'Hello, world!';
final Uint8List bytes = utf8.encode(expectedStringContents);
final File textFile = File([bytes], 'hello.txt');

final String expectedStringContents2 = 'This is the other test file';
final Uint8List bytes2 = utf8.encode(expectedStringContents2);
final File textFile2 = File([bytes2], 'test2.txt');

/// Test Markers
void main() {
  E2EWidgetsFlutterBinding.ensureInitialized() as E2EWidgetsFlutterBinding;

  FileSelectorPlugin plugin;

  testWidgets('Create a DOM container', (WidgetTester tester) {
    plugin = FileSelectorPlugin();

    final result = querySelector('#${domElementId}');
    expect(result, isNotNull);
  });

  group('loadFile(..)', () {
    testWidgets('creates correct input element', (WidgetTester tester) async {
      final overrides = FileSelectorPluginTestOverrides(
        getFilesWhenReady: (_) => Future.value([ XFile('path') ]),
      );

      plugin = FileSelectorPlugin(
        overrides: overrides,
      );

      final container = querySelector('#${domElementId}');

      print("Expect message: 'File chooser dialog can only be shown with a user activation'");
      final file = await plugin.loadFile(acceptedTypeGroups: [ textGroup ]);

      expect(file, isNotNull);

      final result = container?.children?.firstWhere((element) => element.tagName == 'INPUT', orElse: () => null);

      expect(result, isNotNull);
      expect(result.getAttribute('type'), 'file');
      expect(result.getAttribute('accept'), '.json,.txt');
    });

    testWidgets('input element is clicked', (WidgetTester tester) async {
      final mockInput = FileUploadInputElement();

      final overrides = FileSelectorPluginTestOverrides(
        getFilesWhenReady: (_) => Future.value([ XFile('path') ]),
        createFileInputElement: (_, __) => mockInput,
      );



      plugin = FileSelectorPlugin(
        overrides: overrides,
      );

      bool clicked = false;
      mockInput.onClick.listen((event) => clicked = true);

      print("Expect message: 'File chooser dialog can only be shown with a user activation'");
      final file = await plugin.loadFile(acceptedTypeGroups: [ textGroup ]);

      expect(clicked, true);
    });

    testWidgets('get XFile from input element', (WidgetTester tester) async {
      final mockInput = FileUploadInputElement();

      final overrides = FileSelectorPluginTestOverrides(
        getFilesFromInputElement: (_) => [textFile],
        createFileInputElement: (_, __) => mockInput,
      );

      plugin = FileSelectorPlugin(
        overrides: overrides,
      );

      // Call load file
      final file = plugin.loadFile();

      // Mock selection of a file
      mockInput.dispatchEvent(Event('change'));

      // Expect the file to complete
      expect(file, completes);

      // Expect that we can read from the file
      final loadedFile = await file;
      final contents = await loadedFile.readAsString();
      expect(contents, expectedStringContents);
      expect(loadedFile.name, textFile.name);
    });
  });
  
  
  group('loadFiles(..)', () {
    testWidgets('creates correct input element', (WidgetTester tester) async {
      final overrides = FileSelectorPluginTestOverrides(
        getFilesWhenReady: (_) => Future.value([ XFile('path'), XFile('path2') ]),
      );

      plugin = FileSelectorPlugin(
        overrides: overrides,
      );

      final container = querySelector('#${domElementId}');

      print("Expect message: 'File chooser dialog can only be shown with a user activation'");
      final files = await plugin.loadFiles(acceptedTypeGroups: [ textGroup ]);

      expect(files, isNotNull);

      final FileUploadInputElement result = container?.children?.firstWhere((element) => element.tagName == 'INPUT', orElse: () => null);

      expect(result, isNotNull);
      expect(result.getAttribute('type'), 'file');
      expect(result.getAttribute('accept'), '.json,.txt');
      expect(result.multiple, true);
    });

    testWidgets('input element is clicked', (WidgetTester tester) async {
      final mockInput = FileUploadInputElement();

      final overrides = FileSelectorPluginTestOverrides(
        getFilesWhenReady: (_) => Future.value([ XFile('path') ]),
        createFileInputElement: (_, __) => mockInput,
      );



      plugin = FileSelectorPlugin(
        overrides: overrides,
      );

      bool clicked = false;
      mockInput.onClick.listen((event) => clicked = true);

      print("Expect message: 'File chooser dialog can only be shown with a user activation'");
      final file = await plugin.loadFiles(acceptedTypeGroups: [ textGroup ]);

      expect(clicked, true);
    });

    testWidgets('get XFiles from input element', (WidgetTester tester) async {
      final mockInput = FileUploadInputElement();

      final overrides = FileSelectorPluginTestOverrides(
        getFilesFromInputElement: (_) => [textFile, textFile2],
        createFileInputElement: (_, __) => mockInput,
      );

      plugin = FileSelectorPlugin(
        overrides: overrides,
      );

      // Call load file
      final files = plugin.loadFiles();

      // Mock selection of files
      mockInput.dispatchEvent(Event('change'));

      // Expect the file to complete
      expect(files, completes);

      // Expect that we can read from the file
      final loadedFiles = await files;
      final loadedFile1 = loadedFiles[0];
      final loadedFile2 = loadedFiles[1];
      
      final contents = await loadedFile1.readAsString();
      expect(contents, expectedStringContents);
      expect(loadedFile1.name, textFile.name);
      
      final contents2 = await loadedFile2.readAsString();
      expect(contents2, expectedStringContents2);
      expect(loadedFile2.name, textFile2.name);
    });
  });

  testWidgets('getSavePath completes', (WidgetTester tester) async {
    plugin = FileSelectorPlugin();
    final path = plugin.getSavePath();
    expect(path, completes);
  });

}
