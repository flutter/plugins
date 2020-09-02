// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:file_selector/file_selector.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

void main() {
  final mock = MockFileSelector();
  FileSelectorPlatform.instance = mock;

  test('getSavePath', () async {
    final expectedPath = '/example/path';

    final typeGroup = XTypeGroup(label: 'group', extensions: ['jpg', 'png']);

    when(mock.getSavePath(
      acceptedTypeGroups: [typeGroup],
      initialDirectory: 'dir',
      suggestedName: 'name',
      confirmButtonText: 'save',
    )).thenAnswer((_) => Future.value(expectedPath));

    final result = await getSavePath(
        acceptedTypeGroups: [typeGroup],
        initialDirectory: 'dir',
        suggestedName: 'name',
        confirmButtonText: 'save');

    expect(result, expectedPath);
  });

  test('openFile', () async {
    final file = XFile('path');

    final typeGroup = XTypeGroup(label: 'group', extensions: ['jpg', 'png']);

    when(mock.openFile(
      acceptedTypeGroups: [typeGroup],
      initialDirectory: 'dir',
      confirmButtonText: 'load',
    )).thenAnswer((_) => Future.value(file));

    final result = await openFile(
        acceptedTypeGroups: [typeGroup],
        initialDirectory: 'dir',
        confirmButtonText: 'load');

    expect(result, isNotNull);
  });

  test('openFiles', () async {
    final file = XFile('path');

    final typeGroup = XTypeGroup(label: 'group', extensions: ['jpg', 'png']);

    when(mock.openFiles(
      acceptedTypeGroups: [typeGroup],
      initialDirectory: 'dir',
      confirmButtonText: 'load',
    )).thenAnswer((_) => Future.value([file]));

    final result = await openFiles(
        acceptedTypeGroups: [typeGroup],
        initialDirectory: 'dir',
        confirmButtonText: 'load');

    expect(result, isNotNull);
  });
}

class MockFileSelector extends Mock
    with MockPlatformInterfaceMixin
    implements FileSelectorPlatform {}
