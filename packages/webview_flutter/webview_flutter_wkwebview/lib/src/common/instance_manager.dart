// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Maintains instances stored to communicate with Objective-C objects.
class InstanceManager {
  final Map<int, Object> _instanceIdsToInstances = <int, Object>{};
  final Expando<Object> _instancesToInstanceIds = Expando<Object>();

  int _nextInstanceId = 0;

  /// Global instance of [InstanceManager].
  static final InstanceManager instance = InstanceManager();

  /// Attempt to add a new instance.
  ///
  /// Returns new if [instance] has already been added. Otherwise, it is added
  /// with a new instance id.
  int? tryAddInstance(Object instance) {
    if (getInstanceId(instance) != null) {
      return null;
    }

    final int instanceId = _nextInstanceId++;
    _instancesToInstanceIds[instance] = instanceId;
    _instanceIdsToInstances[instanceId] = instance;
    return instanceId;
  }

  /// Store a copy of an instance with the same instance id.
  void addCopy(Object original, Object copy) {
    assert(original.runtimeType == copy.runtimeType);
    _instancesToInstanceIds[copy] = _instancesToInstanceIds[original];
    assert(original == copy);
  }

  /// Remove the instance from the manager.
  ///
  /// Returns null if the instance is removed. Otherwise, return the instanceId
  /// of the removed instance.
  int? removeInstance<T extends Object>(T instance) {
    final int? instanceId = _instancesToInstanceIds[instance] as int?;
    if (instanceId != null) {
      _instancesToInstanceIds[instance] = null;
      _instanceIdsToInstances.remove(instanceId);
    }
    return instanceId;
  }

  /// Retrieve the Object paired with instanceId.
  T? getInstance<T extends Object>(int instanceId) {
    return _instanceIdsToInstances[instanceId] as T?;
  }

  /// Retrieve the instanceId paired with instance.
  int? getInstanceId(Object instance) {
    return _instancesToInstanceIds[instance] as int?;
  }
}
