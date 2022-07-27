import 'package:flutter/services.dart';
import 'package:wrapper_example/src/instance_manager.dart';

import 'example_library.pigeon.dart';

class BaseObjectHostApiImpl extends BaseObjectHostApi {
  BaseObjectHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? BaseObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  final BinaryMessenger? binaryMessenger;

  final InstanceManager instanceManager;
}

class BaseObject implements Copyable {
  BaseObject.detached({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  }) : _api = BaseObjectHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        );

  /// Global instance of [InstanceManager].
  static final InstanceManager globalInstanceManager =
      InstanceManager(onWeakReferenceRemoved: (int identifier) {
    BaseObjectHostApiImpl().dispose(identifier);
  });

  final BaseObjectHostApiImpl _api;

  @override
  Copyable copy() {
    return BaseObject.detached(
      binaryMessenger: _api.binaryMessenger,
      instanceManager: _api.instanceManager,
    );
  }
}
