// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import java.util.HashMap;
import java.util.Map;

class InstanceManager {
  private final Map<Long, Object> instanceIdsToInstances = new HashMap<>();
  private final Map<Object, Long> instancesToInstanceIds = new HashMap<>();

  /** Add a new instance with instanceId. */
  void addInstance(Object instance, Long instanceId) {
    instancesToInstanceIds.put(instance, instanceId);
    instanceIdsToInstances.put(instanceId, instance);
  }

  /** Remove the instance from the manager. */
  Object removeInstanceId(Long instanceId) {
    final Object instance = instanceIdsToInstances.remove(instanceId);
    if (instance != null) {
      instancesToInstanceIds.remove(instance);
    }
    return instance;
  }

  /** Retrieve the Object paired with instanceId. */
  Object getInstance(Long instanceId) {
    return instanceIdsToInstances.get(instanceId);
  }

  /** Retrieve the instanceId paired with instance. */
  Long getInstanceId(Object instance) {
    return instancesToInstanceIds.get(instance);
  }
}
