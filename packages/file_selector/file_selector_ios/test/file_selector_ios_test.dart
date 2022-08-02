// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_ios/file_selector_ios.dart';
import 'package:file_selector_ios/src/messages.g.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'file_selector_ios_test.mocks.dart';
import 'test_api.dart';

@GenerateMocks(<Type>[TestFileSelectorApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final FileSelectorIOS plugin = FileSelectorIOS();
  late MockTestFileSelectorApi mockApi;

  setUp(() {
    mockApi = MockTestFileSelectorApi();
    TestFileSelectorApi.setup(mockApi);
  });

  test('registered instance', () {
    FileSelectorIOS.registerWith();
    expect(FileSelectorPlatform.instance, isA<FileSelectorIOS>());
  });

  group('openFile', () {
    setUp(() {
      when(mockApi.openFile(any)).thenAnswer((_) async => <String>['foo']);
    });

    test('passes the accepted type groups correctly', () async {
      final XTypeGroup group = XTypeGroup(
        label: 'text',
        extensions: <String>['txt'],
        mimeTypes: <String>['text/plain'],
        macUTIs: <String>['public.text'],
      );

      final XTypeGroup groupTwo = XTypeGroup(
          label: 'image',
          extensions: <String>['jpg'],
          mimeTypes: <String>['image/jpg'],
          macUTIs: <String>['public.image'],
          webWildCards: <String>['image/*']);

      await plugin.openFile(acceptedTypeGroups: <XTypeGroup>[group, groupTwo]);

      final VerificationResult result = verify(mockApi.openFile(captureAny));
      final FileSelectorConfig config =
          result.captured[0] as FileSelectorConfig;

      // iOS only accepts macUTIs.
      expect(listEquals(config.utis, <String>['public.text', 'public.image']),
          isTrue);
      expect(config.allowMultiSelection, isFalse);
    });
    test('throws for a type group that does not support iOS', () async {
      final XTypeGroup group = XTypeGroup(
        label: 'images',
        webWildCards: <String>['images/*'],
      );

      await expectLater(
          plugin.openFile(acceptedTypeGroups: <XTypeGroup>[group]),
          throwsArgumentError);
    });

    test('allows a wildcard group', () async {
      final XTypeGroup group = XTypeGroup(
        label: 'text',
      );

      await expectLater(
          plugin.openFile(acceptedTypeGroups: <XTypeGroup>[group]), completes);
    });
  });

  group('openFiles', () {
    setUp(() {
      when(mockApi.openFile(any)).thenAnswer((_) async => <String>['foo']);
    });

    test('passes the accepted type groups correctly', () async {
      final XTypeGroup group = XTypeGroup(
        label: 'text',
        extensions: <String>['txt'],
        mimeTypes: <String>['text/plain'],
        macUTIs: <String>['public.text'],
      );

      final XTypeGroup groupTwo = XTypeGroup(
          label: 'image',
          extensions: <String>['jpg'],
          mimeTypes: <String>['image/jpg'],
          macUTIs: <String>['public.image'],
          webWildCards: <String>['image/*']);

      await plugin.openFiles(acceptedTypeGroups: <XTypeGroup>[group, groupTwo]);

      final VerificationResult result = verify(mockApi.openFile(captureAny));
      final FileSelectorConfig config =
          result.captured[0] as FileSelectorConfig;

      // iOS only accepts macUTIs.
      expect(listEquals(config.utis, <String>['public.text', 'public.image']),
          isTrue);
      expect(config.allowMultiSelection, isTrue);
    });
    test('throws for a type group that does not support iOS', () async {
      final XTypeGroup group = XTypeGroup(
        label: 'images',
        webWildCards: <String>['images/*'],
      );

      await expectLater(
          plugin.openFiles(acceptedTypeGroups: <XTypeGroup>[group]),
          throwsArgumentError);
    });

    test('allows a wildcard group', () async {
      final XTypeGroup group = XTypeGroup(
        label: 'text',
      );

      await expectLater(
          plugin.openFiles(acceptedTypeGroups: <XTypeGroup>[group]), completes);
    });
  });
}
