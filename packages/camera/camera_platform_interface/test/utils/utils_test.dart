import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_platform_interface/src/utils/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Utility methods', () {
    test(
        'Should return CameraLensDirection when valid value is supplied when parsing camera lens direction',
        () {
      expect(
        parseCameraLensDirection('back'),
        CameraLensDirection.back,
      );
      expect(
        parseCameraLensDirection('front'),
        CameraLensDirection.front,
      );
      expect(
        parseCameraLensDirection('external'),
        CameraLensDirection.external,
      );
    });

    test(
        'Should throw ArgumentException when invalid value is supplied when parsing camera lens direction',
        () {
      expect(
        () => parseCameraLensDirection('test'),
        throwsA(isArgumentError),
      );
    });
  });
}
