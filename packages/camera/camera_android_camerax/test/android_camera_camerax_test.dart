import 'package:camera_android_camerax/camera_android_camerax.dart';
import 'package:camera_android_camerax/src/camera_info.dart';
import 'package:camera_android_camerax/src/camera_selector.dart';
import 'package:camera_android_camerax/src/process_camera_provider.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'android_camera_camerax_test.mocks.dart';

@GenerateMocks(<Type>[
  ProcessCameraProvider,
  CameraSelector,
  CameraInfo,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Should fetch CameraDescription instances for available cameras',
      () async {
    // Arrange
    final List<dynamic> returnData = <dynamic>[
      <String, dynamic>{
        'name': 'Camera 0',
        'lensFacing': 'back',
        'sensorOrientation': 0
      },
      <String, dynamic>{
        'name': 'Camera 1',
        'lensFacing': 'front',
        'sensorOrientation': 90
      }
    ];

    //Create mocks to use
    final MockProcessCameraProvider mockProcessCameraProvider =
        MockProcessCameraProvider();
    final MockCameraSelector mockBackCameraSelector = MockCameraSelector();
    final MockCameraSelector mockFrontCameraSelector = MockCameraSelector();
    final MockCameraInfo mockFrontCameraInfo = MockCameraInfo();
    final MockCameraInfo mockBackCameraInfo = MockCameraInfo();
    AndroidCameraCameraX.registerWith();

    //Set class level ProcessCameraProvider and camera selectors to created mocks
    final AndroidCameraCameraX androidCameraCamerax = AndroidCameraCameraX();
    androidCameraCamerax.setDefaultBackCameraSelector(mockBackCameraSelector);
    androidCameraCamerax.setDefaultFrontCameraSelector(mockFrontCameraSelector);
    androidCameraCamerax.setProcessCameraProvider(mockProcessCameraProvider);

    //Mock calls to native platform
    when(mockProcessCameraProvider.getAvailableCameraInfos())
        .thenAnswer((_) async => [mockBackCameraInfo, mockFrontCameraInfo]);
    when(mockBackCameraSelector.filter([mockFrontCameraInfo]))
        .thenAnswer((_) async => []);
    when(mockBackCameraSelector.filter([mockBackCameraInfo]))
        .thenAnswer((_) async => [mockBackCameraInfo]);
    when(mockFrontCameraSelector.filter([mockBackCameraInfo]))
        .thenAnswer((_) async => []);
    when(mockFrontCameraSelector.filter([mockFrontCameraInfo]))
        .thenAnswer((_) async => [mockFrontCameraInfo]);
    when(mockBackCameraInfo.getSensorRotationDegrees())
        .thenAnswer((_) async => 0);
    when(mockFrontCameraInfo.getSensorRotationDegrees())
        .thenAnswer((_) async => 90);

    final List<CameraDescription> cameraDescriptions =
        await androidCameraCamerax.availableCameras();

    expect(cameraDescriptions.length, returnData.length);
    for (int i = 0; i < returnData.length; i++) {
      final Map<String, Object?> typedData =
          (returnData[i] as Map<dynamic, dynamic>).cast<String, Object?>();
      final CameraDescription cameraDescription = CameraDescription(
        name: typedData['name']! as String,
        lensDirection: (typedData['lensFacing']! as String) == 'front'
            ? CameraLensDirection.front
            : CameraLensDirection.back,
        sensorOrientation: typedData['sensorOrientation']! as int,
      );
      expect(cameraDescriptions[i], cameraDescription);
    }
  });
}
