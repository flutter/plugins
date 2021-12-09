// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.util.LongSparseArray;
import java.util.HashMap;
import java.util.Map;

/**
 * Maintains instances to intercommunicate with Dart objects.
 *
 * <p>When an instance is added with an instanceId, either can be used to retrieve the other.
 */
public class InstanceManager {
  private final LongSparseArray<Object> instanceIdsToInstances = new LongSparseArray<>();
  private final Map<Object, Long> instancesToInstanceIds = new HashMap<>();

  /**
   * Add a new instance to the manager.
   *
   * <p>If an instance or instanceId has already been added, it will be replaced by the new values.
   *
   * @param instance the new object to be added
   * @param instanceId unique id of the added object
   */
  public void addInstance(Object instance, long instanceId) {
    instancesToInstanceIds.put(instance, instanceId);
    instanceIdsToInstances.append(instanceId, instance);
  }

  /**
   * Remove the instance with instanceId from the manager.
   *
   * @param instanceId the id of the instance to be removed
   * @return the removed instance if the manager contains the instanceId, otherwise null
   */
  public Object removeInstanceWithId(long instanceId) {
    final Object instance = instanceIdsToInstances.get(instanceId);
    if (instance != null) {
      instanceIdsToInstances.remove(instanceId);
      instancesToInstanceIds.remove(instance);
    }
    return instance;
  }

  /**
   * Remove the instance from the manager.
   *
   * @param instance the instance to be removed
   * @return the instanceId of the removed instance if the manager contains the value, otherwise
   *     null
   */
  public Long removeInstance(Object instance) {
    final Long instanceId = instancesToInstanceIds.get(instance);
    if (instanceId != null) {
      instanceIdsToInstances.remove(instanceId);
      instancesToInstanceIds.remove(instance);
    }
    return instanceId;
  }

  /**
   * Retrieve the Object paired with instanceId.
   *
   * @param instanceId the instanceId of the desired instance
   * @return the instance stored with the instanceId if the manager contains the value, otherwise
   *     null
   */
  public Object getInstance(long instanceId) {
    return instanceIdsToInstances.get(instanceId);
  }

  /**
   * Retrieve the instanceId paired with an instance.
   *
   * @param instance the value paired with the desired instanceId
   * @return the instanceId paired with instance if the manager contains the value, otherwise null
   */
  public Long getInstanceId(Object instance) {
    return instancesToInstanceIds.get(instance);
  }
}
