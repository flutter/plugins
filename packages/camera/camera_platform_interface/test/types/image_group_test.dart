import 'package:camera_platform_interface/src/types/types.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$ImageFormatGroup tests', () {
    test('ImageFormatGroupName extension returns correct values', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(ImageFormatGroup.jpeg.name(), 'jpeg');
      expect(ImageFormatGroup.yuv420.name(), 'yuv420');
      expect(ImageFormatGroup.bgra8888.name(), 'unknown');
      expect(ImageFormatGroup.unknown.name(), 'unknown');
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(ImageFormatGroup.bgra8888.name(), 'bgra8888');
      expect(ImageFormatGroup.yuv420.name(), 'yuv420');
      expect(ImageFormatGroup.jpeg.name(), 'unknown');
      expect(ImageFormatGroup.unknown.name(), 'unknown');
    });
  });
}
