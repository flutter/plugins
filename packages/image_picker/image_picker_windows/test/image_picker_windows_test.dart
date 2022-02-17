// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_windows/file_selector_windows.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:image_picker_windows/image_picker_windows.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$ImagePickerWindows()', () {
    final ImagePickerWindows plugin = ImagePickerWindows();
    final FileSelectorWindows fileSelectorWindows = FileSelectorWindows();

    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      fileSelectorWindows.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return null;
      });

      log.clear();
    });

    test('registered instance', () {
      ImagePickerWindows.registerWith();
      expect(ImagePickerPlatform.instance, isA<ImagePickerWindows>());
      expect(FileSelectorPlatform.instance, isA<FileSelectorWindows>());
    });

    group('images', () {
      test('pickImage passes the accepted type groups correctly', () async {
        final XTypeGroup group = XTypeGroup(
            label: 'images',
            extensions: <String>[
              'jpg',
              'jpeg',
              'png',
              'bmp',
              'webp',
              'gif',
              'tif',
              'tiff',
              'apng'
            ]);

        await plugin.pickImage(source: ImageSource.gallery);

        expect(
          log,
          <Matcher>[
            isMethodCall('openFile', arguments: <String, dynamic>{
              'acceptedTypeGroups': <Map<String, dynamic>>[group.toJSON()],
              'initialDirectory': null,
              'confirmButtonText': null,
              'multiple': false,
            }),
          ],
        );
      });

      test('getImage passes the accepted type groups correctly', () async {
        final XTypeGroup group = XTypeGroup(
            label: 'images',
            extensions: <String>[
              'jpg',
              'jpeg',
              'png',
              'bmp',
              'webp',
              'gif',
              'tif',
              'tiff',
              'apng'
            ]);

        await plugin.getImage(source: ImageSource.gallery);

        expect(
          log,
          <Matcher>[
            isMethodCall('openFile', arguments: <String, dynamic>{
              'acceptedTypeGroups': <Map<String, dynamic>>[group.toJSON()],
              'initialDirectory': null,
              'confirmButtonText': null,
              'multiple': false,
            }),
          ],
        );
      });

      test('getMultiImage passes the accepted type groups correctly', () async {
        final XTypeGroup group = XTypeGroup(
            label: 'images',
            extensions: <String>[
              'jpg',
              'jpeg',
              'png',
              'bmp',
              'webp',
              'gif',
              'tif',
              'tiff',
              'apng'
            ]);

        await plugin.getMultiImage();

        expect(
          log,
          <Matcher>[
            isMethodCall('openFile', arguments: <String, dynamic>{
              'acceptedTypeGroups': <Map<String, dynamic>>[group.toJSON()],
              'initialDirectory': null,
              'confirmButtonText': null,
              'multiple': true,
            }),
          ],
        );
      });
    });
    group('videos', () {
      test('pickVideo passes the accepted type groups correctly', () async {
        final XTypeGroup group = XTypeGroup(
            label: 'videos',
            extensions: <String>[
              'mov',
              'wmv',
              'mkv',
              'mp4',
              'webm',
              'avi',
              'mpeg',
              'mpg'
            ]);

        await plugin.pickVideo(source: ImageSource.gallery);

        expect(
          log,
          <Matcher>[
            isMethodCall('openFile', arguments: <String, dynamic>{
              'acceptedTypeGroups': <Map<String, dynamic>>[group.toJSON()],
              'initialDirectory': null,
              'confirmButtonText': null,
              'multiple': false,
            }),
          ],
        );
      });

      test('getVideo passes the accepted type groups correctly', () async {
        final XTypeGroup group = XTypeGroup(
            label: 'videos',
            extensions: <String>[
              'mov',
              'wmv',
              'mkv',
              'mp4',
              'webm',
              'avi',
              'mpeg',
              'mpg'
            ]);

        await plugin.getVideo(source: ImageSource.gallery);

        expect(
          log,
          <Matcher>[
            isMethodCall('openFile', arguments: <String, dynamic>{
              'acceptedTypeGroups': <Map<String, dynamic>>[group.toJSON()],
              'initialDirectory': null,
              'confirmButtonText': null,
              'multiple': false,
            }),
          ],
        );
      });
    });
  });
}
