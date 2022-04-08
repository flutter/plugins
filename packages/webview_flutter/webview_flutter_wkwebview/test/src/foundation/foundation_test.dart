// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_wkwebview/src/common/instance_manager.dart';
import 'package:webview_flutter_wkwebview/src/common/web_kit.pigeon.dart';
import 'package:webview_flutter_wkwebview/src/foundation/foundation.dart';

import '../common/test_web_kit.pigeon.dart';
import 'foundation_test.mocks.dart';

@GenerateMocks(<Type>[
  TestNSObjectHostApi,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Foundation', () {
    late InstanceManager instanceManager;

    setUp(() {
      instanceManager = InstanceManager();
    });

    group('$NSObject', () {
      late MockTestNSObjectHostApi mockPlatformHostApi;

      late NSObject object;

      setUp(() {
        mockPlatformHostApi = MockTestNSObjectHostApi();
        TestNSObjectHostApi.setup(mockPlatformHostApi);

        object = NSObject(instanceManager: instanceManager);
        instanceManager.tryAddInstance(object);
      });

      tearDown(() {
        TestNSObjectHostApi.setup(null);
      });

      test('addObserver', () async {
        final NSObject observer = NSObject(instanceManager: instanceManager);
        instanceManager.tryAddInstance(observer);

        await object.addObserver(
          observer,
          keyPath: 'aKeyPath',
          options: <NSKeyValueObservingOptions>{
            NSKeyValueObservingOptions.initialValue,
            NSKeyValueObservingOptions.priorNotification,
          },
        );

        final List<NSKeyValueObservingOptionsEnumData?> optionsData =
            verify(mockPlatformHostApi.addObserver(
          instanceManager.getInstanceId(object),
          instanceManager.getInstanceId(observer),
          'aKeyPath',
          captureAny,
        )).captured.single as List<NSKeyValueObservingOptionsEnumData?>;

        expect(optionsData, hasLength(2));
        expect(
          optionsData[0]!.value,
          NSKeyValueObservingOptionsEnum.initialValue,
        );
        expect(
          optionsData[1]!.value,
          NSKeyValueObservingOptionsEnum.priorNotification,
        );
      });

      test('removeObserver', () async {
        final NSObject observer = NSObject(instanceManager: instanceManager);
        instanceManager.tryAddInstance(observer);

        await object.removeObserver(observer, keyPath: 'aKeyPath');

        verify(mockPlatformHostApi.removeObserver(
          instanceManager.getInstanceId(object),
          instanceManager.getInstanceId(observer),
          'aKeyPath',
        ));
      });

      test('dispose', () async {
        final int instanceId = instanceManager.getInstanceId(object)!;

        await object.dispose();
        verify(
          mockPlatformHostApi.dispose(instanceId),
        );
      });
    });
  });
}
