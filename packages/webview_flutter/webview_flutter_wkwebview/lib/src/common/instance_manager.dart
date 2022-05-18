// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Maintains instances stored to communicate with Objective-C objects.
class InstanceManager {
  // Instances that the manager wants to maintain a strong reference to.
  final Map<int, Object> _strongInstances = <int, Object>{};
  // Expando is used because it doesn't prevent its keys from becoming
  // inaccessible. This allows the manager to efficiently retrieve an instance
  // id of an object without holding a strong reference to the object.
  //
  // It also doesn't use `==` to search for instance ids, which would lead to an
  // infinite loop when comparing an object to its copy. (i.e. which is caused
  // by calling instanceManager.getInstanceId() inside of `==` while this was a
  // HashMap).
  final Expando<int> _instanceIds = Expando<int>();

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
    _instanceIds[instance] = instanceId;
    _strongInstances[instanceId] = instance;
    return instanceId;
  }

  /// Store a copy of an instance with the same instance id.
  void addCopy(Object original, Object copy) {
    assert(original.runtimeType == copy.runtimeType);
    _instanceIds[copy] = _instanceIds[original];
    assert(original == copy);
  }

  /// Remove the instance from the manager.
  ///
  /// Returns null if the instance is removed. Otherwise, return the instanceId
  /// of the removed instance.
  int? removeInstance<T extends Object>(T instance) {
    final int? instanceId = _instanceIds[instance];
    if (instanceId != null) {
      _instanceIds[instance] = null;
      _strongInstances.remove(instanceId);
    }
    return instanceId;
  }

  /// Retrieve the Object paired with instanceId.
  T? getInstance<T extends Object>(int instanceId) {
    return _strongInstances[instanceId] as T?;
  }

  /// Retrieve the instanceId paired with instance.
  int? getInstanceId(Object instance) {
    return _instanceIds[instance];
  }
}
