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
  @visibleForTesting
  FoundationFlutterApis({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  }) : _binaryMessenger = binaryMessenger {
    functionFlutterApi =
        FunctionFlutterApiImpl(instanceManager: instanceManager);
  }

  static FoundationFlutterApis _instance = FoundationFlutterApis();

  /// Sets the global instance containing the Flutter Apis for the Foundation library.
  @visibleForTesting
  static set instance(FoundationFlutterApis instance) {
    _instance = instance;
  }

  /// Global instance containing the Flutter Apis for the Foundation library.
  static FoundationFlutterApis get instance {
    return _instance;
  }

  final BinaryMessenger? _binaryMessenger;
  bool _hasBeenSetUp = false;

  /// Flutter Api for disposing functions.
  ///
  /// This FlutterApi is placed here because [FoundationFlutterApis.ensureSetUp]
  /// is called inside [NSObject] and [NSObject] is the parent class of all
  /// objects.
  @visibleForTesting
  late final FunctionFlutterApiImpl functionFlutterApi;

  /// Ensures all the Flutter APIs have been set up to receive calls from native code.
  void ensureSetUp() {
    if (!_hasBeenSetUp) {
      FunctionFlutterApi.setup(
        functionFlutterApi,
        binaryMessenger: _binaryMessenger,
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
        super(binaryMessenger: binaryMessenger);

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
      instanceManager.getIdentifier(instance)!,
      instanceManager.getIdentifier(observer)!,
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
      instanceManager.getIdentifier(instance)!,
      instanceManager.getIdentifier(observer)!,
      keyPath,
    );
  }

  /// Calls [dispose] with the ids of the provided object instances.
  Future<void> disposeForInstances(NSObject instance) async {
    final int? identifier = instanceManager.removeWeakReference(instance);
    if (identifier != null) {
      await dispose(identifier);
    }
  }
}
