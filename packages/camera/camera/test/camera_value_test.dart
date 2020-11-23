import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('camera_value', () {
    test('Can be created', () {
      var cameraValue = const CameraValue(
        isInitialized: false,
        errorDescription: null,
        previewSize: Size(10, 10),
        isRecordingPaused: false,
        isRecordingVideo: false,
        isTakingPicture: false,
        isStreamingImages: false,
      );

      expect(cameraValue, isA<CameraValue>());
      expect(cameraValue.isInitialized, isFalse);
      expect(cameraValue.errorDescription, null);
      expect(cameraValue.previewSize, Size(10, 10));
      expect(cameraValue.isRecordingPaused, isFalse);
      expect(cameraValue.isRecordingVideo, isFalse);
      expect(cameraValue.isTakingPicture, isFalse);
      expect(cameraValue.isStreamingImages, isFalse);
    });

    test('Can be created as uninitialized', () {
      var cameraValue = const CameraValue.uninitialized();

      expect(cameraValue, isA<CameraValue>());
      expect(cameraValue.isInitialized, isFalse);
      expect(cameraValue.errorDescription, null);
      expect(cameraValue.previewSize, null);
      expect(cameraValue.isRecordingPaused, isFalse);
      expect(cameraValue.isRecordingVideo, isFalse);
      expect(cameraValue.isTakingPicture, isFalse);
      expect(cameraValue.isStreamingImages, isFalse);
    });

    test('Can be copied with isInitialized', () {
      var cv = const CameraValue.uninitialized();
      var cameraValue = cv.copyWith(isInitialized: true);

      expect(cameraValue, isA<CameraValue>());
      expect(cameraValue.isInitialized, isTrue);
      expect(cameraValue.errorDescription, null);
      expect(cameraValue.previewSize, null);
      expect(cameraValue.isRecordingPaused, isFalse);
      expect(cameraValue.isRecordingVideo, isFalse);
      expect(cameraValue.isTakingPicture, isFalse);
      expect(cameraValue.isStreamingImages, isFalse);
    });

    test('Has aspectRatio after setting size', () {
      var cv = const CameraValue.uninitialized();
      var cameraValue =
          cv.copyWith(isInitialized: true, previewSize: Size(20, 10));

      expect(cameraValue.aspectRatio, 0.5);
    });

    test('hasError is true after setting errorDescription', () {
      var cv = const CameraValue.uninitialized();
      var cameraValue = cv.copyWith(errorDescription: 'error');

      expect(cameraValue.hasError, isTrue);
      expect(cameraValue.errorDescription, 'error');
    });

    test('Recording paused is false when not recording', () {
      var cv = const CameraValue.uninitialized();
      var cameraValue = cv.copyWith(
          isInitialized: true,
          isRecordingVideo: false,
          isRecordingPaused: true);

      expect(cameraValue.isRecordingPaused, isFalse);
    });

    test('toString() works as expected', () {
      var cameraValue = const CameraValue(
        isInitialized: false,
        errorDescription: null,
        previewSize: Size(10, 10),
        isRecordingPaused: false,
        isRecordingVideo: false,
        isTakingPicture: false,
        isStreamingImages: false,
      );

      expect(cameraValue.toString(),
          'CameraValue(isRecordingVideo: false, isRecordingVideo: false, isInitialized: false, errorDescription: null, previewSize: Size(10.0, 10.0), isStreamingImages: false)');
    });
  });
}
