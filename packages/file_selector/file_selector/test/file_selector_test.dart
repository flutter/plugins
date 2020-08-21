// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:file_selector/file_selector.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

void main() {
  final MockFileSelector mock = MockFileSelector();
  FileSelectorPlatform.instance = mock;

  test('getSavePath', () async {
    String expectedPath = '/example/path';

    when(
        mock.getSavePath(
          initialDirectory: 'dir',
          suggestedName: 'name',
        )
    ).thenAnswer((_) => Future.value(expectedPath));

    String result = await getSavePath(initialDirectory: 'dir', suggestedName: 'name');

    expect(result, expectedPath);
  });

  test('loadFile', () async {
    XFile file = XFile('path');

    XTypeGroup typeGroup = XTypeGroup(label: 'group', fileTypes: [ XType(extension: '.json', mime: 'application/json') ]);

    when(
        mock.loadFile(
          acceptedTypeGroups: [typeGroup],
          initialDirectory: 'dir',
        )
    ).thenAnswer((_) => Future.value(file));

    XFile result = await loadFile(acceptedTypeGroups: [typeGroup], initialDirectory: 'dir');

    expect(result, isNotNull);
  });

  test('loadFiles', () async {
    XFile file = XFile('path');

    XTypeGroup typeGroup = XTypeGroup(label: 'group', fileTypes: [ XType(extension: '.json', mime: 'application/json') ]);

    when(
        mock.loadFiles(
          acceptedTypeGroups: [typeGroup],
          initialDirectory: 'dir',
        )
    ).thenAnswer((_) => Future.value([file]));

    List<XFile> result = await loadFiles(acceptedTypeGroups: [typeGroup], initialDirectory: 'dir');

    expect(result, isNotNull);
  });
}

class MockFileSelector extends Mock
    with MockPlatformInterfaceMixin
    implements FileSelectorPlatform {}