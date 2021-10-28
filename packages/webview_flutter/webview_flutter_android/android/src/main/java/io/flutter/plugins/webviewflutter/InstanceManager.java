// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.util.LongSparseArray;
import java.util.HashMap;
import java.util.Map;

class InstanceManager {
  private final LongSparseArray<Object> instanceIdsToInstances = new LongSparseArray<>();
  private final Map<Object, Long> instancesToInstanceIds = new HashMap<>();

  /** Add a new instance with instanceId. */
  void addInstance(Object instance, long instanceId) {
    instancesToInstanceIds.put(instance, instanceId);
    instanceIdsToInstances.append(instanceId, instance);
  }

  /** Remove the instance from the manager. */
  void removeInstance(long instanceId) {
    final Object instance = instanceIdsToInstances.get(instanceId);
    if (instance != null) {
      instanceIdsToInstances.remove(instanceId);
      instancesToInstanceIds.remove(instance);
    }
  }

  /** Retrieve the Object paired with instanceId. */
  Object getInstance(long instanceId) {
    return instanceIdsToInstances.get(instanceId);
  }

  /** Retrieve the instanceId paired with instance. */
  Long getInstanceId(Object instance) {
    return instancesToInstanceIds.get(instance);
  }
}
