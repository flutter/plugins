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
    tearDown(() => TestCameraSelectorHostApi.setup(null));

    test('detachedCreateTest', () async {
      final MockPreviewHostApi mockApi =
          MockTestPreviewHostApi();
      TestPreviewHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      Preview.detached(
        instanceManager: instanceManager,
        targetRotation: 90,
        targetResolution: Map<String, int>{
            width: 10,
            height: 50,
        },
      );

      verifyNever(mockApi.create(argThat(isA<int>()), argThat(isA<int>()),argThat(isA<Map<String, int>())));
    });

    test('createTest', () async {
      final MockTestCPreviewHostApi mockApi =
          MockTestPreviewHostApi();
      TestCPreviewHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      CameraSelector(
        instanceManager: instanceManager,
        targetRotation: 90,
        targetResolution: Map<String, int>{
            width: 10,
            height: 50,
        },
      );

      verify(mockApi.create(argThat(isA<int>(), argThat(equals(90)), argThat(equals( Map<String, int>{
            width: 10,
            height: 50,
        }))), null));
    });

    test('setSurfaceProviderTest', () async {
      final MockTestPreviewHostApi mockApi =
          MockTestPreviewHostApi();
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
        onCopy: (_) => CameraSelector.detached(),
      );

      when(mockApi.setTargetRotation(instanceManager.getIdentifier(preview)
      )).thenReturn(8);
      expect(await preview.setSurfaceProvider(),
          equals(8));

      verify(mockApi.setSurfaceProvider(instanceManager.getIdentifier(preview)));
    });

    test('getResolutionInfoTest', () async {
      final MockTestPreviewHostApi mockApi =
          MockTestPreviewHostApi();
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
        onCopy: (_) => CameraSelector.detached(),
      );

      when(mockApi.getResolutionInfo(instanceManager.getIdentifier(preview)
      )).thenReturn(Map<String, int> {'width': 10, 'height': 60});
      expect(await preview.getResolutionInfo(),
          equals(Map<String, int> {'width': 10, 'height': 60}));

      verify(mockApi.getResolutionInfo(instanceManager.getIdentifier(preview)));
    });

    test('flutterApiCreateTest', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final PreviewFlutterApi flutterApi = PreviewFlutterApiImpl(
        instanceManager: instanceManager,
      );

      flutterApi.create(0, 270, Map<String, int>{'width': 60, 'height': 10});

      expect(instanceManager.getInstanceWithWeakReference(0),
          isA<Preview>());
      expect(
          (instanceManager.getInstanceWithWeakReference(0)! as Preview)
              .targetRotation,
          equals(270));
      expect(
          (instanceManager.getInstanceWithWeakReference(0)! as Preview)
              .targetResolution,
          equals(Map<String, int>{'width': 60, 'height': 10}));
    });
  });
}
