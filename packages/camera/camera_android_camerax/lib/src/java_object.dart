// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/services.dart';

import 'camerax_library.pigeon.dart';
import 'instance_manager.dart';

/// Root of the Java class hierarchy.
///
/// See https://docs.oracle.com/javase/8/docs/api/java/lang/Object.html.
@immutable
class JavaObject {
  /// Constructs a [JavaObject] without creating the associated Java object.
  ///
  /// This should only be used by subclasses created by this library or to
  /// create copies.
  JavaObject.detached({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  }) : _api = JavaObjectHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        );

  /// Global instance of [InstanceManager].
  static final InstanceManager globalInstanceManager = InstanceManager(
    onWeakReferenceRemoved: (int identifier) {
      JavaObjectHostApiImpl().dispose(identifier);
    },
  );

  /// Pigeon Host Api implementation for [JavaObject].
  final JavaObjectHostApiImpl _api;

  /// Release the reference to a native Java instance.
  static void dispose(JavaObject instance) {
    instance._api.instanceManager.removeWeakReference(instance);
  }
}

/// Handles methods calls to the native Java Object class.
class JavaObjectHostApiImpl extends JavaObjectHostApi {
  /// Constructs a [JavaObjectHostApiImpl].
  JavaObjectHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? JavaObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager instanceManager;
}

/// Handles callbacks methods for the native Java Object class.
class JavaObjectFlutterApiImpl implements JavaObjectFlutterApi {
  /// Constructs a [JavaObjectFlutterApiImpl].
  JavaObjectFlutterApiImpl({InstanceManager? instanceManager})
      : instanceManager = instanceManager ?? JavaObject.globalInstanceManager;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager instanceManager;

  @override
  void dispose(int identifier) {
    instanceManager.remove(identifier);
  }
}
