// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:image_picker_windows/image_picker_windows.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'image_picker_windows_test.mocks.dart';

@GenerateMocks(<Type>[FileSelectorPlatform])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$ImagePickerWindows()', () {
    final ImagePickerWindows plugin = ImagePickerWindows();
    late MockFileSelectorPlatform mockFileSelectorPlatform;

    setUp(() {
      mockFileSelectorPlatform = MockFileSelectorPlatform();

      when(mockFileSelectorPlatform.openFile(
              acceptedTypeGroups: anyNamed('acceptedTypeGroups')))
          .thenAnswer((_) async => null);

      when(mockFileSelectorPlatform.openFiles(
              acceptedTypeGroups: anyNamed('acceptedTypeGroups')))
          .thenAnswer((_) async => List<XFile>.empty());

      ImagePickerWindows.fileSelector = mockFileSelectorPlatform;
    });

    test('registered instance', () {
      ImagePickerWindows.registerWith();
      expect(ImagePickerPlatform.instance, isA<ImagePickerWindows>());
    });

    group('images', () {
      test('pickImage passes the accepted type groups correctly', () async {
        await plugin.pickImage(source: ImageSource.gallery);

        expect(
            verify(mockFileSelectorPlatform.openFile(
                    acceptedTypeGroups: captureAnyNamed('acceptedTypeGroups')))
                .captured
                .single[0]
                .extensions,
            ImagePickerWindows.imageFormats);
      });

      test('pickImage throws UnimplementedError when source is camera',
          () async {
        expect(() async => await plugin.pickImage(source: ImageSource.camera),
            throwsA(isA<UnimplementedError>()));
      });

      test('getImage passes the accepted type groups correctly', () async {
        await plugin.getImage(source: ImageSource.gallery);

        expect(
            verify(mockFileSelectorPlatform.openFile(
                    acceptedTypeGroups: captureAnyNamed('acceptedTypeGroups')))
                .captured
                .single[0]
                .extensions,
            ImagePickerWindows.imageFormats);
      });

      test('getImage throws UnimplementedError when source is camera',
          () async {
        expect(() async => await plugin.getImage(source: ImageSource.camera),
            throwsA(isA<UnimplementedError>()));
      });

      test('getMultiImage passes the accepted type groups correctly', () async {
        await plugin.getMultiImage();

        expect(
            verify(mockFileSelectorPlatform.openFiles(
                    acceptedTypeGroups: captureAnyNamed('acceptedTypeGroups')))
                .captured
                .single[0]
                .extensions,
            ImagePickerWindows.imageFormats);
      });
    });
    group('videos', () {
      test('pickVideo passes the accepted type groups correctly', () async {
        await plugin.pickVideo(source: ImageSource.gallery);

        expect(
            verify(mockFileSelectorPlatform.openFile(
                    acceptedTypeGroups: captureAnyNamed('acceptedTypeGroups')))
                .captured
                .single[0]
                .extensions,
            ImagePickerWindows.videoFormats);
      });

      test('pickVideo throws UnimplementedError when source is camera',
          () async {
        expect(() async => await plugin.pickVideo(source: ImageSource.camera),
            throwsA(isA<UnimplementedError>()));
      });

      test('getVideo passes the accepted type groups correctly', () async {
        await plugin.getVideo(source: ImageSource.gallery);

        expect(
            verify(mockFileSelectorPlatform.openFile(
                    acceptedTypeGroups: captureAnyNamed('acceptedTypeGroups')))
                .captured
                .single[0]
                .extensions,
            ImagePickerWindows.videoFormats);
      });

      test('getVideo throws UnimplementedError when source is camera',
          () async {
        expect(() async => await plugin.getVideo(source: ImageSource.camera),
            throwsA(isA<UnimplementedError>()));
      });
    });
  });
}
