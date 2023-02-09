// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/preview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'preview_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[TestPreviewHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Preview', () {
    tearDown(() => TestPreviewHostApi.setup(null));

    test('detached create does not call create on the Java side', () async {
      final MockTestPreviewHostApi mockApi = MockTestPreviewHostApi();
      TestPreviewHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      Preview.detached(
        instanceManager: instanceManager,
        targetRotation: 90,
        targetResolution: ResolutionInfo(width: 50, height: 10),
      );

      verifyNever(mockApi.create(argThat(isA<int>()), argThat(isA<int>()),
          argThat(isA<ResolutionInfo>())));
    });

    test('create calls create on the Java side', () async {
      final MockTestPreviewHostApi mockApi = MockTestPreviewHostApi();
      TestPreviewHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      const int targetRotation = 90;
      const int targetResolutionWidth = 10;
      const int targetResolutionHeight = 50;
      Preview(
        instanceManager: instanceManager,
        targetRotation: targetRotation,
        targetResolution: ResolutionInfo(
            width: targetResolutionWidth, height: targetResolutionHeight),
      );

      final VerificationResult createVerification = verify(mockApi.create(
          argThat(isA<int>()), argThat(equals(targetRotation)), captureAny));
      final ResolutionInfo capturedResolutionInfo =
          createVerification.captured.single as ResolutionInfo;
      expect(capturedResolutionInfo.width, equals(targetResolutionWidth));
      expect(capturedResolutionInfo.height, equals(targetResolutionHeight));
    });

    test(
        'setSurfaceProvider makes call to set surface provider for preview instance',
        () async {
      final MockTestPreviewHostApi mockApi = MockTestPreviewHostApi();
      TestPreviewHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      const int textureId = 8;
      final Preview preview = Preview.detached(
        instanceManager: instanceManager,
      );
      instanceManager.addHostCreatedInstance(
        preview,
        0,
        onCopy: (_) => Preview.detached(),
      );

      when(mockApi.setSurfaceProvider(instanceManager.getIdentifier(preview)))
          .thenReturn(textureId);
      expect(await preview.setSurfaceProvider(), equals(textureId));

      verify(
          mockApi.setSurfaceProvider(instanceManager.getIdentifier(preview)));
    });

    test(
        'releaseFlutterSurfaceTexture makes call to relase flutter surface texture entry',
        () async {
      final MockTestPreviewHostApi mockApi = MockTestPreviewHostApi();
      TestPreviewHostApi.setup(mockApi);

      final Preview preview = Preview.detached();

      preview.releaseFlutterSurfaceTexture();

      verify(mockApi.releaseFlutterSurfaceTexture());
    });

    test(
        'getResolutionInfo makes call to get resolution information for preview instance',
        () async {
      final MockTestPreviewHostApi mockApi = MockTestPreviewHostApi();
      TestPreviewHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final Preview preview = Preview.detached(
        instanceManager: instanceManager,
      );
      const int resolutionWidth = 10;
      const int resolutionHeight = 60;
      final ResolutionInfo testResolutionInfo =
          ResolutionInfo(width: resolutionWidth, height: resolutionHeight);

      instanceManager.addHostCreatedInstance(
        preview,
        0,
        onCopy: (_) => Preview.detached(),
      );

      when(mockApi.getResolutionInfo(instanceManager.getIdentifier(preview)))
          .thenReturn(testResolutionInfo);

      final ResolutionInfo previewResolutionInfo =
          await preview.getResolutionInfo();
      expect(previewResolutionInfo.width, equals(resolutionWidth));
      expect(previewResolutionInfo.height, equals(resolutionHeight));

      verify(mockApi.getResolutionInfo(instanceManager.getIdentifier(preview)));
    });
  });
}
