// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_wkwebview/src/common/instance_manager.dart';

void main() {
  group('InstanceManager', () {
    test('addHostCreatedInstance', () {
      final CopyableObject object = CopyableObject();

      final InstanceManager instanceManager =
          InstanceManager(onWeakReferenceRemoved: (_) {});

      instanceManager.addHostCreatedInstance(object, 0);

      expect(instanceManager.getIdentifier(object), 0);
      expect(
        instanceManager.getInstance(0, returnedInstanceMayBeUsed: false),
        object,
      );
    });

    test('addHostCreatedInstance prevents already used objects and ids', () {
      final CopyableObject object = CopyableObject();

      final InstanceManager instanceManager =
          InstanceManager(onWeakReferenceRemoved: (_) {});

      instanceManager.addHostCreatedInstance(object, 0);

      expect(
        () => instanceManager.addHostCreatedInstance(object, 1),
        throwsAssertionError,
      );

      expect(
        () => instanceManager.addHostCreatedInstance(CopyableObject(), 0),
        throwsAssertionError,
      );
    });

    test('addFlutterCreatedInstance', () {
      final CopyableObject object = CopyableObject();

      final InstanceManager instanceManager =
          InstanceManager(onWeakReferenceRemoved: (_) {});

      instanceManager.addDartCreatedInstance(object);

      final int? instanceId = instanceManager.getIdentifier(object);
      expect(instanceId, isNotNull);
      expect(
        instanceManager.getInstance(
          instanceId!,
          returnedInstanceMayBeUsed: false,
        ),
        object,
      );
    });

    test('removeWeakReference', () {
      final CopyableObject object = CopyableObject();

      int? weakInstanceId;
      final InstanceManager instanceManager =
          InstanceManager(onWeakReferenceRemoved: (int instanceId) {
        weakInstanceId = instanceId;
      });

      instanceManager.addHostCreatedInstance(object, 0);

      expect(instanceManager.removeWeakReference(object), 0);
      expect(
        instanceManager.getInstance(0, returnedInstanceMayBeUsed: false),
        isA<CopyableObject>(),
      );
      expect(weakInstanceId, 0);
    });

    test('removeWeakReference removes only weak reference', () {
      final CopyableObject object = CopyableObject();

      final InstanceManager instanceManager =
          InstanceManager(onWeakReferenceRemoved: (_) {});

      instanceManager.addHostCreatedInstance(object, 0);

      expect(instanceManager.removeWeakReference(object), 0);
      final CopyableObject copy = instanceManager.getInstance(
        0,
        returnedInstanceMayBeUsed: false,
      )!;
      expect(identical(object, copy), isFalse);
    });

    test('removeStrongReference', () {
      final CopyableObject object = CopyableObject();

      final InstanceManager instanceManager =
          InstanceManager(onWeakReferenceRemoved: (_) {});

      instanceManager.addHostCreatedInstance(object, 0);
      instanceManager.removeWeakReference(object);
      expect(instanceManager.removeReference(0), isA<CopyableObject>());
      expect(
        instanceManager.getInstance(0, returnedInstanceMayBeUsed: false),
        isNull,
      );
    });

    test('removeStrongReference removes only strong reference', () {
      final CopyableObject object = CopyableObject();

      final InstanceManager instanceManager =
          InstanceManager(onWeakReferenceRemoved: (_) {});

      instanceManager.addHostCreatedInstance(object, 0);
      expect(instanceManager.removeReference(0), isA<CopyableObject>());
      expect(
        instanceManager.getInstance(0, returnedInstanceMayBeUsed: false),
        object,
      );
    });

    test('getInstance can add a new weak reference', () {
      final CopyableObject object = CopyableObject();

      final InstanceManager instanceManager =
          InstanceManager(onWeakReferenceRemoved: (_) {});

      instanceManager.addHostCreatedInstance(object, 0);
      instanceManager.removeWeakReference(object);

      final CopyableObject strongCopy = instanceManager.getInstance(
        0,
        returnedInstanceMayBeUsed: false,
      )!;
      final CopyableObject newWeakCopy = instanceManager.getInstance(
        0,
        returnedInstanceMayBeUsed: true,
      )!;
      expect(identical(strongCopy, newWeakCopy), isFalse);
    });
  });
}

class CopyableObject with Copyable {
  @override
  Copyable copy() {
    return CopyableObject();
  }

  @override
  int get hashCode {
    return 0;
  }

  @override
  bool operator ==(Object other) {
    return other is CopyableObject;
  }
}
