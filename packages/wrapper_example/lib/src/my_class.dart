// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'base_object.dart';
import 'example_library.pigeon.dart';
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
      instanceManager.addDartCreatedInstance(
        instance,
        onCopy: (MyClass original) => MyClass.detached(
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

  MyOtherClass attachClassFieldFromInstances(
    MyClass instance,
    MyOtherClass classField,
  ) {
    attachClassField(
      instanceManager.getIdentifier(instance)!,
      instanceManager.addDartCreatedInstance(
        classField,
        onCopy: (MyOtherClass original) => MyOtherClass.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
      ),
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

@immutable
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

  MyClass.detached(
    this.primitiveField, {
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

  Future<void> myMethod(String primitiveParam, MyOtherClass classParam) {
    return _api.myMethodFromInstances(this, primitiveParam, classParam);
  }
}
