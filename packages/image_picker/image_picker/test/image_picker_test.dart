// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'image_picker_test.mocks.dart';

@GenerateMocks(<Type>[ImagePickerPlatform])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$ImagePicker', () {
    late ImagePicker picker;
    late MockPlatform mockPlatform;
    late ImagePickerPlatform realPlatform;

    setUp(() {
      realPlatform = ImagePickerPlatform.instance;
      mockPlatform = MockPlatform();
      picker = ImagePicker();
      ImagePickerPlatform.instance = mockPlatform;
    });

    tearDown(() {
      ImagePickerPlatform.instance = realPlatform;
    });

    test('ImagePicker platform instance overrides the actual platform used',
        () {
      expect(ImagePicker.platform, mockPlatform);
    });

    test('getImage passes parameters to platform', () {
      when(
        mockPlatform.pickImage(
          source: anyNamed('source'),
          maxWidth: anyNamed('maxWidth'),
          maxHeight: anyNamed('maxHeight'),
          imageQuality: anyNamed('imageQuality'),
          preferredCameraDevice: anyNamed('preferredCameraDevice'),
        ),
      ).thenAnswer((_) async => null);
      picker.getImage(
        source: ImageSource.camera,
        maxWidth: 20,
        maxHeight: 10,
        imageQuality: 30,
        preferredCameraDevice: CameraDevice.front,
      );
      verify(
        mockPlatform.pickImage(
          source: ImageSource.camera,
          maxWidth: 20,
          maxHeight: 10,
          imageQuality: 30,
          preferredCameraDevice: CameraDevice.front,
        ),
      );
    });

    test('getMultiImage passes parameters to platform', () {
      when(
        mockPlatform.pickMultiImage(
          maxWidth: anyNamed('maxWidth'),
          maxHeight: anyNamed('maxHeight'),
          imageQuality: anyNamed('imageQuality'),
        ),
      ).thenAnswer((_) async => null);
      picker.getMultiImage(
        maxWidth: 20,
        maxHeight: 10,
        imageQuality: 30,
      );
      verify(
        mockPlatform.pickMultiImage(
          maxWidth: 20,
          maxHeight: 10,
          imageQuality: 30,
        ),
      );
    });

    test('getVideo passes parameters to platform', () {
      when(
        mockPlatform.pickVideo(
          source: anyNamed('source'),
          preferredCameraDevice: anyNamed('preferredCameraDevice'),
          maxDuration: anyNamed('maxDuration'),
        ),
      ).thenAnswer((_) async => null);
      picker.getVideo(
        source: ImageSource.gallery,
        preferredCameraDevice: CameraDevice.front,
        maxDuration: const Duration(seconds: 5),
      );
      verify(
        mockPlatform.pickVideo(
          source: ImageSource.gallery,
          preferredCameraDevice: CameraDevice.front,
          maxDuration: const Duration(seconds: 5),
        ),
      );
    });

    test('getLostData passes parameters to platform', () {
      when(
        mockPlatform.retrieveLostData(),
      ).thenAnswer((_) async => LostData());
      picker.getLostData();
      verify(
        mockPlatform.retrieveLostData(),
      );
    });

    test('pickImage passes parameters to platform', () {
      when(
        mockPlatform.getImage(
          source: anyNamed('source'),
          maxWidth: anyNamed('maxWidth'),
          maxHeight: anyNamed('maxHeight'),
          imageQuality: anyNamed('imageQuality'),
          preferredCameraDevice: anyNamed('preferredCameraDevice'),
        ),
      ).thenAnswer((_) async => null);
      picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 20,
        maxHeight: 10,
        imageQuality: 30,
        preferredCameraDevice: CameraDevice.front,
      );
      verify(
        mockPlatform.getImage(
          source: ImageSource.camera,
          maxWidth: 20,
          maxHeight: 10,
          imageQuality: 30,
          preferredCameraDevice: CameraDevice.front,
        ),
      );
    });

    test('pickMultiImage passes parameters to platform', () {
      when(
        mockPlatform.getMultiImage(
          maxWidth: anyNamed('maxWidth'),
          maxHeight: anyNamed('maxHeight'),
          imageQuality: anyNamed('imageQuality'),
        ),
      ).thenAnswer((_) async => null);
      picker.pickMultiImage(
        maxWidth: 20,
        maxHeight: 10,
        imageQuality: 30,
      );
      verify(
        mockPlatform.getMultiImage(
          maxWidth: 20,
          maxHeight: 10,
          imageQuality: 30,
        ),
      );
    });

    test('pickMedia passes parameters to platform', () {
      when(
        mockPlatform.getMedia(
          options: anyNamed('options'),
        ),
      ).thenAnswer((_) async => null);
      final MediaSelectionOptions options = MediaSelectionOptions();
      picker.pickMedia(options: options);
      verify(
        mockPlatform.getMedia(options: options),
      );
    });

    test('pickVideo passes parameters to platform', () {
      when(
        mockPlatform.getVideo(
          source: anyNamed('source'),
          preferredCameraDevice: anyNamed('preferredCameraDevice'),
          maxDuration: anyNamed('maxDuration'),
        ),
      ).thenAnswer((_) async => null);
      picker.pickVideo(
        source: ImageSource.gallery,
        preferredCameraDevice: CameraDevice.front,
        maxDuration: const Duration(seconds: 5),
      );
      verify(
        mockPlatform.getVideo(
          source: ImageSource.gallery,
          preferredCameraDevice: CameraDevice.front,
          maxDuration: const Duration(seconds: 5),
        ),
      );
    });

    test('retrieveLostData passes parameters to platform', () {
      when(
        mockPlatform.getLostData(),
      ).thenAnswer((_) async => LostDataResponse());
      picker.retrieveLostData();
      verify(
        mockPlatform.getLostData(),
      );
    });
  });
}

class MockPlatform extends MockImagePickerPlatform
    with MockPlatformInterfaceMixin {}
