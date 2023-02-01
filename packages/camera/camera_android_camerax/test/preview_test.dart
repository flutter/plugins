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
      Preview(
        instanceManager: instanceManager,
        targetRotation: 90,
        targetResolution: ResolutionInfo(width: 10, height: 50),
      );

      final VerificationResult createVerification = verify(
          mockApi.create(argThat(isA<int>()), argThat(equals(90)), captureAny));
      final ResolutionInfo capturedResolutionInfo =
          createVerification.captured.single as ResolutionInfo;
      expect(capturedResolutionInfo.width, equals(10));
      expect(capturedResolutionInfo.height, equals(50));
    });

    test(
        'setSurfaceProvider makes call to set surface provider for preview instance',
        () async {
      final MockTestPreviewHostApi mockApi = MockTestPreviewHostApi();
      TestPreviewHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final Preview preview = Preview.detached(
        instanceManager: instanceManager,
      );

      instanceManager.addHostCreatedInstance(
        preview,
        0,
        onCopy: (_) => Preview.detached(),
      );

      when(mockApi.setSurfaceProvider(instanceManager.getIdentifier(preview)))
          .thenReturn(8);
      expect(await preview.setSurfaceProvider(), equals(8));

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
      final ResolutionInfo testResolutionInfo =
          ResolutionInfo(width: 10, height: 60);

      instanceManager.addHostCreatedInstance(
        preview,
        0,
        onCopy: (_) => Preview.detached(),
      );

      when(mockApi.getResolutionInfo(instanceManager.getIdentifier(preview)))
          .thenReturn(testResolutionInfo);

      final ResolutionInfo previewResolutionInfo =
          await preview.getResolutionInfo();
      expect(previewResolutionInfo.width, equals(10));
      expect(previewResolutionInfo.height, equals(60));

      verify(mockApi.getResolutionInfo(instanceManager.getIdentifier(preview)));
    });
  });
}
