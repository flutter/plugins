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

      final typeGroup = XTypeGroup(label: 'test',
          fileTypes: [
            XType(extension: 'json', mime: 'application/json'),
            XType(extension: 'txt', mime: 'text/plain'),
          ]);

      final file = await plugin.loadFile(acceptedTypeGroups: [ typeGroup ]);

      expect(file, isNotNull);

      final result = container?.children?.firstWhere((element) => element.tagName == 'INPUT', orElse: () => null);

      expect(result, isNotNull);
      expect(result.getAttribute('type'), 'file');
      expect(result.getAttribute('accept'), '.json,.txt');
    });
  });
}
