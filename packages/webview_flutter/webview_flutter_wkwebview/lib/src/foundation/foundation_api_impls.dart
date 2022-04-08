// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../common/function_flutter_api_impls.dart';
import '../common/instance_manager.dart';
import '../common/web_kit.pigeon.dart';
import 'foundation.dart';

Iterable<NSKeyValueObservingOptionsEnumData>
    _toNSKeyValueObservingOptionsEnumData(
  Iterable<NSKeyValueObservingOptions> options,
) {
  return options.map<NSKeyValueObservingOptionsEnumData>((
    NSKeyValueObservingOptions option,
  ) {
    late final NSKeyValueObservingOptionsEnum? value;
    switch (option) {
      case NSKeyValueObservingOptions.newValue:
        value = NSKeyValueObservingOptionsEnum.newValue;
        break;
      case NSKeyValueObservingOptions.oldValue:
        value = NSKeyValueObservingOptionsEnum.oldValue;
        break;
      case NSKeyValueObservingOptions.initialValue:
        value = NSKeyValueObservingOptionsEnum.initialValue;
        break;
      case NSKeyValueObservingOptions.priorNotification:
        value = NSKeyValueObservingOptionsEnum.priorNotification;
        break;
    }

    return NSKeyValueObservingOptionsEnumData(value: value);
  });
}

/// Handles initialization of Flutter APIs for the Foundation library.
class FoundationFlutterApis {
  /// Constructs a [FoundationFlutterApis].
  ///
  /// This should only be changed for testing purposes.
  @visibleForTesting
  FoundationFlutterApis({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  }) {
    functionFlutterApi =
        FunctionFlutterApiImpl(instanceManager: instanceManager);
  }

  /// Mutable instance containing all Flutter Apis for the Foundation library.
  ///
  /// This should only be changed for testing purposes.
  static FoundationFlutterApis instance = FoundationFlutterApis();

  /// Sends binary data across the Flutter platform barrier.
  final BinaryMessenger? binaryMessenger;

  bool _hasBeenSetUp = false;

  /// Flutter Api for disposing functions.
  @visibleForTesting
  late final FunctionFlutterApiImpl functionFlutterApi;

  /// Ensures all the Flutter APIs have been setup to receive calls from native code.
  void ensureSetUp() {
    if (!_hasBeenSetUp) {
      FunctionFlutterApi.setup(
        functionFlutterApi,
        binaryMessenger: binaryMessenger,
      );
      _hasBeenSetUp = true;
    }
  }
}

/// Host api implementation for [NSObject].
class NSObjectHostApiImpl extends NSObjectHostApi {
  /// Constructs an [NSObjectHostApiImpl].
  NSObjectHostApiImpl({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? InstanceManager.instance,
        super(binaryMessenger: binaryMessenger) {
    FoundationFlutterApis.instance.ensureSetUp();
  }

  /// Maintains instances stored to communicate with Objective-C objects.
  final InstanceManager instanceManager;

  /// Calls [addObserver] with the ids of the provided object instances.
  Future<void> addObserverForInstances(
    NSObject instance,
    NSObject observer,
    String keyPath,
    Set<NSKeyValueObservingOptions> options,
  ) {
    return addObserver(
      instanceManager.getInstanceId(instance)!,
      instanceManager.getInstanceId(observer)!,
      keyPath,
      _toNSKeyValueObservingOptionsEnumData(options).toList(),
    );
  }

  /// Calls [removeObserver] with the ids of the provided object instances.
  Future<void> removeObserverForInstances(
    NSObject instance,
    NSObject observer,
    String keyPath,
  ) {
    return removeObserver(
      instanceManager.getInstanceId(instance)!,
      instanceManager.getInstanceId(observer)!,
      keyPath,
    );
  }

  /// Calls [dispose] with the ids of the provided object instances.
  Future<void> disposeForInstances(NSObject instance) async {
    final int? instanceId = instanceManager.removeInstance(instance);
    if (instanceId != null) {
      await dispose(instanceId);
    }
  }
}
