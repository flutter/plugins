// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'instance_manager.dart';

@immutable
class JavaObject {
  JavaObject.detached(
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager});

  /// Global instance of [InstanceManager].
  static final InstanceManager globalInstanceManager =
      InstanceManager(onWeakReferenceRemoved: (int identifier) {
    BaseObjectHostApiImpl().dispose(identifier);
  });
}
