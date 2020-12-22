// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.9

import 'dart:html';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:file_selector_web/src/dom_helper.dart';
import 'package:pedantic/pedantic.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('FileSelectorWeb', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    DomHelper domHelper;
    MockInput mockInput;

    setUp(() {
      mockInput = MockInput();
      domHelper = DomHelper(input: mockInput);
    });

    testWidgets('creates a container and an <input /> element', (_) async {
      domHelper = DomHelper();
      final container = querySelector('file-selector');
      final input = querySelector('file-selector input');

      expect(container, isNotNull);
      expect(input, isNotNull);
    });

    group('getFilesFromInput', () {
      testWidgets('sets the <input /> attributes and click it', (_) async {
        final accept = '.png,.jpg,.txt,.json';
        final multiple = true;

        unawaited(
            domHelper.getFilesFromInput(accept: accept, multiple: multiple));

        expect(mockInput.accept, accept);
        expect(mockInput.multiple, multiple);
        verify(mockInput.click());
      });
    });
  });
}

class MockInput extends Mock implements FileUploadInputElement {}
