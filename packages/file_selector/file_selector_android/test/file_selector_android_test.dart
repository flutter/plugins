// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_android/file_selector_android.dart';
import 'package:file_selector_android/src/messages.g.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import './file_selector_android_test.mocks.dart';

@GenerateMocks(<Type>[FileSelectorApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MockFileSelectorApi mockApi = MockFileSelectorApi();
  final FileSelectorAndroid plugin = FileSelectorAndroid.useFakeApi(mockApi);

  test('registers instance', () async {
    FileSelectorAndroid.registerWith();
    expect(FileSelectorPlatform.instance, isA<FileSelectorAndroid>());
  });

  group('#openFile', () {
    const XTypeGroup typeGroup =
        XTypeGroup(mimeTypes: <String>['text/plain', 'application/json']);
    final List<XTypeGroup> acceptedTypeGroups = <XTypeGroup>[typeGroup];

    setUp(() {
      when(mockApi.openFiles(any))
          .thenAnswer((_) async => <String>['/path/example/final']);
    });
    test('simple call works', () async {
      final XFile? file =
          await plugin.openFile(acceptedTypeGroups: acceptedTypeGroups);

      expect(file?.path, '/path/example/final');
    });
    test('passes acceptedTypeGroups and allowMultiple arguments correctly',
        () async {
      await plugin.openFile(acceptedTypeGroups: acceptedTypeGroups);

      final VerificationResult result = verify(mockApi.openFiles(captureAny));
      final SelectionOptions selectionOptions =
          result.captured[0] as SelectionOptions;
      expect(selectionOptions.allowMultiple, false);
      expect(selectionOptions.allowedTypes, typeGroup.mimeTypes);
    });
  });
  group('#openFiles', () {
    const XTypeGroup typeGroup =
        XTypeGroup(mimeTypes: <String>['text/plain', 'application/json']);
    final List<XTypeGroup> acceptedTypeGroups = <XTypeGroup>[typeGroup];

    setUp(() {
      when(mockApi.openFiles(any)).thenAnswer(
          (_) async => <String>['/path/example', '/path2/example2']);
    });
    test('simple call works', () async {
      final List<XFile> files =
          await plugin.openFiles(acceptedTypeGroups: acceptedTypeGroups);
      expect(files[0].path, '/path/example');
      expect(files[1].path, '/path2/example2');
    });
    test('passes acceptedTypeGroups and allowMultiple arguments correctly',
        () async {
      await plugin.openFiles(acceptedTypeGroups: acceptedTypeGroups);

      final VerificationResult result = verify(mockApi.openFiles(captureAny));
      final SelectionOptions selectionOptions =
          result.captured[0] as SelectionOptions;
      expect(selectionOptions.allowMultiple, true);
      expect(selectionOptions.allowedTypes, typeGroup.mimeTypes);
    });
  });
  group('#getDirectoryPath', () {
    setUp(() {
      when(mockApi.getDirectoryPath(any))
          .thenAnswer((_) async => '/path/example/final');
    });
    test('simple call works', () async {
      final String? path =
          await plugin.getDirectoryPath(initialDirectory: '/path/example');
      expect(path, '/path/example/final');
    });
    test('passes initialDirectory correctly', () async {
      await plugin.getDirectoryPath(initialDirectory: '/path/example');

      final VerificationResult result =
          verify(mockApi.getDirectoryPath(captureAny));
      final String initialDirectory = result.captured[0] as String;
      expect(initialDirectory, '/path/example');
    });
  });
}
