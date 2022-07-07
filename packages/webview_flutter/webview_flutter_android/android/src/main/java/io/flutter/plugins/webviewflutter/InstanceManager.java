// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.os.Handler;
import androidx.annotation.Nullable;
import java.lang.ref.ReferenceQueue;
import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.WeakHashMap;

@SuppressWarnings("unchecked")
public class InstanceManager {
  // Identifiers are locked to a specific range to avoid collisions with objects
  // created simultaneously from Dart.
  // Host uses identifiers >= 2^16 and Dart is expected to use values n where,
  // 0 <= n < 2^16.
  private static final long MIN_HOST_CREATED_IDENTIFIER = 65536;
  private static final long CLEAR_FINALIZED_WEAK_REFERENCES_INTERVAL = 30000;

  public interface FinalizationListener {
    void onFinalize(long identifier);
  }

  private final WeakHashMap<Object, Long> identifiers = new WeakHashMap<>();
  private final HashMap<Long, WeakReference<Object>> weakInstances = new HashMap<>();
  private final HashMap<Long, Object> strongInstances = new HashMap<>();

  private final ReferenceQueue<Object> referenceQueue = new ReferenceQueue<>();
  private final HashMap<WeakReference<Object>, Long> weakReferencesToIdentifiers = new HashMap<>();

  private final Handler handler = new Handler();

  private final FinalizationListener finalizationListener;
  private long nextIdentifier = MIN_HOST_CREATED_IDENTIFIER;

  public static InstanceManager open(FinalizationListener finalizedCallback) {
    return new InstanceManager(finalizedCallback);
  }

  private InstanceManager(FinalizationListener finalizationListener) {
    this.finalizationListener = finalizationListener;
    handler.postDelayed(
        this::releaseAllFinalizedInstances, CLEAR_FINALIZED_WEAK_REFERENCES_INTERVAL);
  }

  public <T> T remove(long identifier) {
    return (T) strongInstances.remove(identifier);
  }

  @Nullable
  public Long getIdentifierForStrongReference(Object instance) {
    final Long identifier = identifiers.get(instance);
    if (identifier != null) {
      strongInstances.put(identifier, instance);
    }
    return identifier;
  }

  public void addDartCreatedInstance(Object instance, long identifier) {
    addInstance(instance, identifier);
  }

  public long addHostCreatedInstance(Object instance) {
    final long identifier = nextIdentifier++;
    addInstance(instance, identifier);
    return identifier;
  }

  @Nullable
  public <T> T getInstance(long identifier) {
    final WeakReference<T> instance = (WeakReference<T>) weakInstances.get(identifier);
    if (instance != null) {
      return instance.get();
    }
    return (T) strongInstances.get(identifier);
  }

  public boolean containsInstance(Object instance) {
    return identifiers.containsKey(instance);
  }

  private void releaseAllFinalizedInstances() {
    WeakReference<Object> reference;
    while ((reference = (WeakReference<Object>) referenceQueue.poll()) != null) {
      final Long identifier = weakReferencesToIdentifiers.remove(reference);
      if (identifier != null) {
        System.out.println("I be running with " + identifier);
        weakInstances.remove(identifier);
        strongInstances.remove(identifier);
        finalizationListener.onFinalize(identifier);
      }
    }
    handler.postDelayed(
        this::releaseAllFinalizedInstances, CLEAR_FINALIZED_WEAK_REFERENCES_INTERVAL);
  }

  private void addInstance(Object instance, long identifier) {
    if (identifier < 0) {
      throw new IllegalArgumentException("Identifier must be >= 0.");
    }
    final WeakReference<Object> weakReference = new WeakReference<>(instance, referenceQueue);
    identifiers.put(instance, identifier);
    weakInstances.put(identifier, weakReference);
    weakReferencesToIdentifiers.put(weakReference, identifier);
    strongInstances.put(identifier, instance);
  }

  public void close() {
    handler.removeCallbacks(this::releaseAllFinalizedInstances);
  }
}
