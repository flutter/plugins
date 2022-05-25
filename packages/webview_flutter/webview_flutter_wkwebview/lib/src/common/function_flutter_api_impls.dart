// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'instance_manager.dart';
import 'web_kit.pigeon.dart';

/// Flutter api to dispose functions.
class FunctionFlutterApiImpl extends FunctionFlutterApi {
  /// Constructs a [FunctionFlutterApiImpl].
  FunctionFlutterApiImpl({InstanceManager? instanceManager}) {
    this.instanceManager = instanceManager ?? InstanceManager.instance;
  }

  /// Maintains instances stored to communicate with native language objects.
  late final InstanceManager instanceManager;

  @override
  void dispose(int instanceId) {
    final Function? function = instanceManager.getInstance(instanceId);
    if (function != null) {
      instanceManager.removeInstance(function);
    }
  }
}
