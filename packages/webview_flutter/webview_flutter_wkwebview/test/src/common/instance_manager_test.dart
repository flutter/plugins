// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vm_service/vm_service.dart' as vm_service;
import 'package:vm_service/vm_service_io.dart';
import 'package:webview_flutter_wkwebview/src/common/instance_manager.dart';
import 'package:webview_flutter_wkwebview/src/common/weak_reference_utils.dart';

void main() {
  group('InstanceManager', () {
    test('addHostCreatedInstance', () {
      final CopyableObject object = CopyableObject();

      final InstanceManager instanceManager =
          InstanceManager(onWeakReferenceRemoved: (_) {});

      instanceManager.addHostCreatedInstance(object, 0);

      expect(instanceManager.getIdentifier(object), 0);
      expect(
        instanceManager.getInstanceWithWeakReference(0),
        object,
      );
    });

    test('addHostCreatedInstance prevents already used objects and ids', () {
      final CopyableObject object = CopyableObject();

      final InstanceManager instanceManager =
          InstanceManager(onWeakReferenceRemoved: (_) {});

      instanceManager.addHostCreatedInstance(object, 0);

      expect(
        () => instanceManager.addHostCreatedInstance(object, 0),
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
        instanceManager.getInstanceWithWeakReference(instanceId!),
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
        instanceManager.getInstanceWithWeakReference(0),
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
      final CopyableObject copy = instanceManager.getInstanceWithWeakReference(
        0,
      )!;
      expect(identical(object, copy), isFalse);
    });

    test('removeStrongReference', () {
      final CopyableObject object = CopyableObject();

      final InstanceManager instanceManager =
          InstanceManager(onWeakReferenceRemoved: (_) {});

      instanceManager.addHostCreatedInstance(object, 0);
      instanceManager.removeWeakReference(object);
      expect(instanceManager.remove(0), isA<CopyableObject>());
      expect(instanceManager.containsIdentifier(0), isFalse);
    });

    test('removeStrongReference removes only strong reference', () {
      final CopyableObject object = CopyableObject();

      final InstanceManager instanceManager =
          InstanceManager(onWeakReferenceRemoved: (_) {});

      instanceManager.addHostCreatedInstance(object, 0);
      expect(instanceManager.remove(0), isA<CopyableObject>());
      expect(
        instanceManager.getInstanceWithWeakReference(0),
        object,
      );
    });

    test('getInstance can add a new weak reference', () {
      final CopyableObject object = CopyableObject();

      final InstanceManager instanceManager =
          InstanceManager(onWeakReferenceRemoved: (_) {});

      instanceManager.addHostCreatedInstance(object, 0);
      instanceManager.removeWeakReference(object);

      final CopyableObject newWeakCopy =
          instanceManager.getInstanceWithWeakReference(
        0,
      )!;
      expect(identical(object, newWeakCopy), isFalse);
    });

    test('withWeakRefenceTo allows encapsulating class to be garbage collected',
        () async {
      final Completer<int> gcCompleter = Completer<int>();
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: gcCompleter.complete,
      );

      ClassWithCallbackClass? instance = ClassWithCallbackClass();
      instanceManager.addHostCreatedInstance(instance.callbackClass, 0);
      instance = null;

      // Force garbage collection.
      final Uri serverUri = (await Service.getInfo()).serverUri!;

      final String isolateId = Service.getIsolateID(Isolate.current)!;
      final vm_service.VmService vmService =
          await vmServiceConnectUri(_toWebSocket(serverUri));
      await vmService.getAllocationProfile(isolateId, gc: true);

      expect(gcCompleter.future, completion(0));
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

class CopyableObjectWithCallback with Copyable {
  CopyableObjectWithCallback(this.callback);

  final VoidCallback callback;

  @override
  CopyableObjectWithCallback copy() {
    return CopyableObjectWithCallback(callback);
  }
}

class ClassWithCallbackClass {
  ClassWithCallbackClass() {
    callbackClass = CopyableObjectWithCallback(
      withWeakRefenceTo(
        this,
        (WeakReference<ClassWithCallbackClass> weakReference) {
          return () {
            // Weak reference to `this` in callback.
            // ignore: unnecessary_statements
            weakReference;
          };
        },
      ),
    );
  }

  late final CopyableObjectWithCallback callbackClass;
}

List<String> _cleanupPathSegments(Uri uri) {
  final List<String> pathSegments = <String>[];
  if (uri.pathSegments.isNotEmpty) {
    pathSegments.addAll(uri.pathSegments.where(
      (String s) => s.isNotEmpty,
    ));
  }
  return pathSegments;
}

String _toWebSocket(Uri uri) {
  final List<String> pathSegments = _cleanupPathSegments(uri);
  pathSegments.add('ws');
  return uri.replace(scheme: 'ws', pathSegments: pathSegments).toString();
}
