// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Maintains instances stored to communicate with Objective-C objects.
class InstanceManager {
  final Map<int, Object> _strongInstances = <int, Object>{};
  final Map<Object, int> _identifiers = <Object, int>{};

  int _nextIdentifier = 0;

  /// Global instance of [InstanceManager].
  static final InstanceManager instance = InstanceManager();

  /// Attempt to add a new instance.
  ///
  /// Returns new if [instance] has already been added. Otherwise, it is added
  /// with a new instance id.
  int addDartCreatedInstance(Object instance) {
    assert(getIdentifier(instance) == null);

    final int instanceId = _nextIdentifier++;
    _identifiers[instance] = instanceId;
    _strongInstances[instanceId] = instance;
    return instanceId;
  }

  /// Remove the instance from the manager.
  ///
  /// Returns null if the instance is removed. Otherwise, return the instanceId
  /// of the removed instance.
  int? removeWeakReference<T extends Object>(T instance) {
    final int? instanceId = _identifiers[instance];
    if (instanceId != null) {
      _identifiers.remove(instance);
      _strongInstances.remove(instanceId);
    }
    return instanceId;
  }

  /// Retrieve the Object paired with instanceId.
  T? getInstance<T extends Object>(int identifier) {
    return _strongInstances[identifier] as T?;
  }

  /// Retrieve the instanceId paired with instance.
  int? getIdentifier(Object instance) {
    return _identifiers[instance];
  }
}
