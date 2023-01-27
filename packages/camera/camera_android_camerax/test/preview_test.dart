// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camerax_library.pigeon.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/preview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'preview_test.mocks.dart';
import 'test_camerax_library.pigeon.dart';

@GenerateMocks(<Type>[TestPreviewHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Preview', () {
    tearDown(() => TestPreviewHostApi.setup(null));

    test('detachedCreateTest', () async {
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

    test('createTest', () async {
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
      expect(createVerification.captured.single.width, equals(10));
      expect(createVerification.captured.single.height, equals(50));
    });

    test('setSurfaceProviderTest', () async {
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

    test('getResolutionInfoTest', () async {
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

      ResolutionInfo previewResolutionInfo = await preview.getResolutionInfo();
      expect(previewResolutionInfo.width, equals(10));
      expect(previewResolutionInfo.height, equals(60));

      verify(mockApi.getResolutionInfo(instanceManager.getIdentifier(preview)));
    });
  });
}
