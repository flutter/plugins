// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'base_object.dart';
import 'example_library.pigeon.dart';
import 'instance_manager.dart';

class _MyOtherClassHostApiImpl extends MyOtherClassHostApi {
  _MyOtherClassHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? BaseObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  final BinaryMessenger? binaryMessenger;

  final InstanceManager instanceManager;

  Future<void> createFromInstances(MyOtherClass instance) {
    return create(
      instanceManager.addDartCreatedInstance(
        instance,
        onCopy: (MyOtherClass original) => MyOtherClass.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
      ),
    );
  }
}

@immutable
class MyOtherClass extends BaseObject {
  MyOtherClass({
    super.binaryMessenger,
    super.instanceManager,
  })  : _api = _MyOtherClassHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
        super.detached() {
    _api.createFromInstances(this);
  }

  MyOtherClass.detached({
    super.binaryMessenger,
    super.instanceManager,
  })  : _api = _MyOtherClassHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
        super.detached();

  final _MyOtherClassHostApiImpl _api;
}
