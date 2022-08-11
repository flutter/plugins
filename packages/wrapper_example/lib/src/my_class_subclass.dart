import 'package:flutter/services.dart';
import 'package:wrapper_example/src/my_other_class.dart';

import 'base_object.dart';
import 'example_library.pigeon.dart';
import 'instance_manager.dart';
import 'my_class.dart';

class _MyClassSubclassHostApiImpl extends MyClassSubclassHostApi {
  _MyClassSubclassHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? BaseObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  final BinaryMessenger? binaryMessenger;

  final InstanceManager instanceManager;

  Future<void> createFromInstances(
    MyClassSubclass instance,
    String primitiveField,
    MyOtherClass classField,
  ) {
    return create(
      instanceManager.addDartCreatedInstance(
        instance,
        onCopy: (MyClassSubclass original) => MyClassSubclass.detached(
          original.primitiveField,
          myCallbackMethod: original.myCallbackMethod,
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
      ),
      primitiveField,
      instanceManager.getIdentifier(classField)!,
    );
  }
}

class MyClassSubclass extends MyClass {
  MyClassSubclass(
    super.primitiveField,
    super.classField, {
    super.myCallbackMethod,
    super.binaryMessenger,
    super.instanceManager,
  })  : _api = _MyClassSubclassHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
        super() {
    _api.createFromInstances(this, primitiveField, classField);
  }

  MyClassSubclass.detached(
    super.primitiveField, {
    super.myCallbackMethod,
    super.binaryMessenger,
    super.instanceManager,
  })  : _api = _MyClassSubclassHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
        super.detached();

  final _MyClassSubclassHostApiImpl _api;
}
