// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Maintains instances stored to communicate with java objects.
class InstanceManager {
  final Map<int, Object> _instanceIdsToInstances = <int, Object>{};
  final Map<Object, int> _instancesToInstanceIds = <Object, int>{};

  int _nextInstanceId = 0;

  /// Global instance of [InstanceManager].
  static final InstanceManager instance = InstanceManager();

  /// Attempt to add a new instance.
  ///
  /// Returns new if [instance] has already been added. Otherwise, it is added
  /// with a new instance id.
  int? tryAddInstance(Object instance) {
    if (_instancesToInstanceIds.containsKey(instance)) {
      return null;
    }

    final int instanceId = _nextInstanceId++;
    _instancesToInstanceIds[instance] = instanceId;
    _instanceIdsToInstances[instanceId] = instance;
    return instanceId;
  }

  /// Remove the instance from the manager.
  ///
  /// Returns null if the instance is removed. Otherwise, return the instanceId
  /// of the removed instance.
  int? removeInstance(Object instance) {
    final int? instanceId = _instancesToInstanceIds[instance];
    if (instanceId != null) {
      _instancesToInstanceIds.remove(instance);
      _instanceIdsToInstances.remove(instanceId);
    }
    return instanceId;
  }

  /// Retrieve the Object paired with instanceId.
  Object? getInstance(int instanceId) {
    return _instanceIdsToInstances[instanceId];
  }

  /// Retrieve the instanceId paired with instance.
  int? getInstanceId(Object instance) {
    return _instancesToInstanceIds[instance];
  }
}
