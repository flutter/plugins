import 'package:camera_android_camerax/camera_android_camerax.dart';
import 'package:camera_android_camerax/src/camera_info.dart';
import 'package:camera_android_camerax/src/camera_selector.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/java_object.dart';
import 'package:camera_android_camerax/src/process_camera_provider.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'android_camera_camerax_test.mocks.dart';

//import 'process_camera_provider_test.mocks.dart';
import 'test_camerax_library.pigeon.dart';

@GenerateMocks(<Type>[
  ProcessCameraProvider,
  CameraSelector,
  CameraInfo,
  TestProcessCameraProviderHostApi,
  TestCameraSelectorHostApi,
  TestCameraInfoHostApi,
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

    final MockTestProcessCameraProviderHostApi
        mockTestProcessCameraProviderHostApi =
        MockTestProcessCameraProviderHostApi();
    TestProcessCameraProviderHostApi.setup(
        mockTestProcessCameraProviderHostApi);

    final MockTestCameraSelectorHostApi mockTestCameraSelectorHostApi =
        MockTestCameraSelectorHostApi();
    TestCameraSelectorHostApi.setup(mockTestCameraSelectorHostApi);

    final MockTestCameraInfoHostApi mockTestCameraInfoHostApi =
        MockTestCameraInfoHostApi();
    TestCameraInfoHostApi.setup(mockTestCameraInfoHostApi);

    final InstanceManager instanceManager = JavaObject.globalInstanceManager;
    final ProcessCameraProvider processCameraProvider =
        ProcessCameraProvider.detached(
      instanceManager: instanceManager,
    );

    instanceManager.addHostCreatedInstance(
      processCameraProvider,
      0,
      onCopy: (_) => ProcessCameraProvider.detached(),
    );
    final CameraInfo fakeBackCameraInfo =
        CameraInfo.detached(instanceManager: instanceManager);
    instanceManager.addHostCreatedInstance(
      fakeBackCameraInfo,
      1,
      onCopy: (_) => CameraInfo.detached(),
    );
    final CameraInfo fakeFrontCameraInfo =
        CameraInfo.detached(instanceManager: instanceManager);
    instanceManager.addHostCreatedInstance(
      fakeFrontCameraInfo,
      2,
      onCopy: (_) => CameraInfo.detached(),
    );

    when(mockTestProcessCameraProviderHostApi.getInstance())
        .thenAnswer((_) async => 0);
    when(mockTestProcessCameraProviderHostApi.getAvailableCameraInfos(0))
        .thenReturn(<int>[1, 2]);

    when(mockTestCameraSelectorHostApi.filter(any, [1])).thenReturn([1]);
    final List<List<int>> responses = <List<int>>[
      <int>[],
      <int>[2]
    ];
    when(mockTestCameraSelectorHostApi.filter(any, [2]))
        .thenAnswer((_) => responses.removeAt(0));

    when(mockTestCameraInfoHostApi.getSensorRotationDegrees(1)).thenReturn(0);
    when(mockTestCameraInfoHostApi.getSensorRotationDegrees(2)).thenReturn(90);

    AndroidCameraCameraX.registerWith();
    final AndroidCameraCameraX androidCameraCamerax = AndroidCameraCameraX();
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
