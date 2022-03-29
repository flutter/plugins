// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

import '../common/instance_manager.dart';
import '../common/web_kit.pigeon.dart';
import 'foundation.dart';

extension _NSKeyValueObservingOptionsConverter on NSKeyValueObservingOptions {
  NSKeyValueObservingOptionsEnumData toNSKeyValueObservingOptionsEnumData() {
    late final NSKeyValueObservingOptionsEnum? value;
    switch (this) {
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
  late final InstanceManager instanceManager;

  /// Converts objects to instances ids for [addObserver].
  Future<void> addObserverFromInstance(
    NSObject instance,
    NSObject observer,
    String keyPath,
    Set<NSKeyValueObservingOptions> options,
  ) {
    return addObserver(
      instanceManager.getInstanceId(instance)!,
      instanceManager.getInstanceId(observer)!,
      keyPath,
      options
          .map<NSKeyValueObservingOptionsEnumData>(
              (NSKeyValueObservingOptions option) =>
                  option.toNSKeyValueObservingOptionsEnumData())
          .toList(),
    );
  }

  /// Converts objects to instances ids for [removeObserver].
  Future<void> removeObserverFromInstance(
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

  /// Converts objects to instances ids for [dispose].
  Future<void> disposeFromInstance(NSObject instance) {
    instanceManager.removeInstance(instance);
    return dispose(instanceManager.getInstanceId(instance)!);
  }
}
