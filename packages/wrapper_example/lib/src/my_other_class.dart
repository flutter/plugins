import 'package:flutter/services.dart';

import 'example_library.pigeon.dart';

import 'base_object.dart';
import 'instance_manager.dart';

class MyOtherClassHostApiImpl extends MyOtherClassHostApi {
  MyOtherClassHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? BaseObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  final BinaryMessenger? binaryMessenger;

  final InstanceManager instanceManager;

  Future<void> createFromInstances(MyOtherClass instance) {
    return create(instanceManager.addDartCreatedInstance(instance));
  }
}

class MyOtherClass extends BaseObject {
  MyOtherClass({
    super.binaryMessenger,
    super.instanceManager,
  })  : _api = MyOtherClassHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
        super.detached() {
    _api.createFromInstances(this);
  }

  final MyOtherClassHostApiImpl _api;

  MyOtherClass.detached({
    super.binaryMessenger,
    super.instanceManager,
  })  : _api = MyOtherClassHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
        super.detached();

  @override
  MyOtherClass copy() {
    return MyOtherClass(binaryMessenger: _api.binaryMessenger, instanceManager: _api.instanceManager);
  }
}
