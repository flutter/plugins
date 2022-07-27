import 'package:flutter/services.dart';

import 'example_library.pigeon.dart';

import 'base_object.dart';
import 'instance_manager.dart';
import 'my_other_class.dart';

class MyClassHostApiImpl extends MyClassHostApi {
  MyClassHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? BaseObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  final BinaryMessenger? binaryMessenger;

  final InstanceManager instanceManager;

  Future<void> createFromInstances(
    MyClass instance,
    String primitiveField,
    MyOtherClass classField,
  ) {
    return create(
      instanceManager.addDartCreatedInstance(instance),
      primitiveField,
      instanceManager.getIdentifier(classField)!,
    );
  }

  MyOtherClass attachClassFieldFromInstances(
    MyClass instance,
    MyOtherClass classField,
  ) {
    attachClassField(
      instanceManager.getIdentifier(instance)!,
      instanceManager.addDartCreatedInstance(classField),
    );
    return classField;
  }

  Future<void> myMethodFromInstances(
    MyClass instance,
    String primitiveParam,
    MyOtherClass classParam,
  ) {
    return myMethod(
      instanceManager.getIdentifier(instance)!,
      primitiveParam,
      instanceManager.getIdentifier(classParam)!,
    );
  }
}

class MyClass extends BaseObject {
  MyClass(
    this.primitiveField,
    MyOtherClass classField, {
    this.myCallbackMethod,
    super.binaryMessenger,
    super.instanceManager,
  })  : _api = MyClassHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
        super.detached() {
    _api.createFromInstances(this, primitiveField, classField);
  }

  final MyClassHostApiImpl _api;

  final String primitiveField;

  late final MyOtherClass classField = _api.attachClassFieldFromInstances(
    this,
    MyOtherClass.detached(
      binaryMessenger: _api.binaryMessenger,
      instanceManager: _api.instanceManager,
    ),
  );

  final void Function()? myCallbackMethod;

  MyClass.detached(
    this.primitiveField,
    MyOtherClass classField, {
    this.myCallbackMethod,
    super.binaryMessenger,
    super.instanceManager,
  })  : _api = MyClassHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
        super.detached();

  static Future<void> myStaticMethod({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  }) {
    return MyClassHostApiImpl(
      binaryMessenger: binaryMessenger,
      instanceManager: instanceManager,
    ).myStaticMethod();
  }

  Future<void> myMethod(String primitiveParam, MyOtherClass classParam) {
    return _api.myMethodFromInstances(this, primitiveParam, classParam);
  }

  @override
  MyClass copy() {
    return MyClass(
      primitiveField,
      classField,
      myCallbackMethod: myCallbackMethod,
      binaryMessenger: _api.binaryMessenger,
      instanceManager: _api.instanceManager,
    );
  }
}
