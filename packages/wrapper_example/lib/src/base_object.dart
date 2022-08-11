// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:wrapper_example/src/instance_manager.dart';

import 'example_library.pigeon.dart';

class _BaseObjectHostApiImpl extends BaseObjectHostApi {
  _BaseObjectHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? BaseObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  final BinaryMessenger? binaryMessenger;

  final InstanceManager instanceManager;
}

@visibleForTesting
class BaseObjectFlutterApiImpl implements BaseObjectFlutterApi {
  /// Constructs a [BaseObjectFlutterApiImpl].
  BaseObjectFlutterApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  }) : instanceManager = instanceManager ?? BaseObject.globalInstanceManager;

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager instanceManager;

  @override
  void dispose(int identifier) {
    instanceManager.remove(identifier);
  }
}

@immutable
class BaseObject {
  BaseObject.detached({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  }) : _api = _BaseObjectHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        );

  /// Global instance of [InstanceManager].
  static final InstanceManager globalInstanceManager =
      InstanceManager(onWeakReferenceRemoved: (int identifier) {
    _BaseObjectHostApiImpl().dispose(identifier);
  });

  final _BaseObjectHostApiImpl _api;
}
