// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:file_selector/file_selector.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

void main() {
  final MockFileSelector mock = MockFileSelector();
  FileSelectorPlatform.instance = mock;

  test('getSavePath', () async {
    String expectedPath = '/example/path';

    XTypeGroup typeGroup = XTypeGroup(label: 'group', extensions: ['jpg', 'png']);

    when(
        mock.getSavePath(
          acceptedTypeGroups: [typeGroup],
          initialDirectory: 'dir',
          suggestedName: 'name',
          confirmButtonText: 'save',
        )
    ).thenAnswer((_) => Future.value(expectedPath));

    String result = await getSavePath(acceptedTypeGroups: [typeGroup], initialDirectory: 'dir', suggestedName: 'name', confirmButtonText: 'save');

    expect(result, expectedPath);
  });

  test('loadFile', () async {
    XFile file = XFile('path');

    XTypeGroup typeGroup = XTypeGroup(label: 'group', extensions: ['jpg', 'png']);

    when(
        mock.loadFile(
          acceptedTypeGroups: [typeGroup],
          initialDirectory: 'dir',
          confirmButtonText: 'load',
        )
    ).thenAnswer((_) => Future.value(file));

    XFile result = await loadFile(acceptedTypeGroups: [typeGroup], initialDirectory: 'dir', confirmButtonText: 'load');

    expect(result, isNotNull);
  });

  test('loadFiles', () async {
    XFile file = XFile('path');

    XTypeGroup typeGroup = XTypeGroup(label: 'group', extensions: ['jpg', 'png']);

    when(
        mock.loadFiles(
          acceptedTypeGroups: [typeGroup],
          initialDirectory: 'dir',
          confirmButtonText: 'load',
        )
    ).thenAnswer((_) => Future.value([file]));

    List<XFile> result = await loadFiles(acceptedTypeGroups: [typeGroup], initialDirectory: 'dir', confirmButtonText: 'load');

    expect(result, isNotNull);
  });
}

class MockFileSelector extends Mock
    with MockPlatformInterfaceMixin
    implements FileSelectorPlatform {}