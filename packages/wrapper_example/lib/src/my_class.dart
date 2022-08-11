// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'base_object.dart';
import 'example_library.pigeon.dart';
import 'instance_manager.dart';
import 'my_other_class.dart';

class _MyClassHostApiImpl extends MyClassHostApi {
  _MyClassHostApiImpl({
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

@visibleForTesting
class MyClassFlutterApiImpl implements MyClassFlutterApi {
  /// Constructs a [MyClassFlutterApiImpl].
  MyClassFlutterApiImpl({
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
  void create(
    int identifier,
    String primitiveField,
    int classFieldIdentifier,
  ) {
    instanceManager.addHostCreatedInstance(
      MyClass.detached(primitiveField),
      identifier,
      onCopy: (MyClass original) => MyClass.detached(
        original.primitiveField,
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
    );
  }

  @override
  void myCallbackMethod(int identifier) {
    final MyClass instance =
        instanceManager.getInstanceWithWeakReference(identifier)!;
    if (instance.myCallbackMethod != null) {
      instance.myCallbackMethod!(instance);
    }
  }
}

/// Example class.
///
/// See <link-to-docs>.
@immutable
class MyClass extends BaseObject {
  /// Construct a [MyClass].
  MyClass(
    this.primitiveField,
    MyOtherClass classField, {
    this.myCallbackMethod,
    super.binaryMessenger,
    super.instanceManager,
  })  : _api = _MyClassHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
        super.detached() {
    _api.createFromInstances(this, primitiveField, classField);
  }

  /// Instantiate an instance not attached to a native instance.
  ///
  /// This should only be used outside of tests by subclasses created by this
  /// library or to create a copy for an [InstanceManager].
  MyClass.detached(
    this.primitiveField, {
    this.myCallbackMethod,
    super.binaryMessenger,
    super.instanceManager,
  })  : _api = _MyClassHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
        super.detached();

  /// Call a static method.
  static Future<void> myStaticMethod({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  }) {
    return _MyClassHostApiImpl(
      binaryMessenger: binaryMessenger,
      instanceManager: instanceManager,
    ).myStaticMethod();
  }

  final _MyClassHostApiImpl _api;

  /// Access a primitive field.
  final String primitiveField;

  /// Synchronously and lazily access a class field.
  late final MyOtherClass classField = _api.attachClassFieldFromInstances(
    this,
    MyOtherClass.detached(
      binaryMessenger: _api.binaryMessenger,
      instanceManager: _api.instanceManager,
    ),
  );

  /// Handle a callback from native.
  final void Function(MyClass)? myCallbackMethod;

  /// Call an instance method.
  Future<void> myMethod(String primitiveParam, MyOtherClass classParam) {
    return _api.myMethodFromInstances(this, primitiveParam, classParam);
  }
}
