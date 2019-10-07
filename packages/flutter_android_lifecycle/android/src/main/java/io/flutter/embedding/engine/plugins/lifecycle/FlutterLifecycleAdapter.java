// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.embedding.engine.plugins.lifecycle;

import androidx.annotation.NonNull;
import androidx.lifecycle.Lifecycle;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import io.flutter.Log;

public class FlutterLifecycleAdapter {
  private static final String TAG = "FlutterLifecycleAdapter";

  @NonNull
  private Lifecycle lifecycle = null;

  public FlutterLifecycleAdapter(@NonNull Object reference) {
    try {
      Class hiddenLifecycleClass = Class.forName(
          "io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference"
      );

      if (!reference.getClass().equals(hiddenLifecycleClass)) {
        throw new IllegalArgumentException(
            "The reference argument must be of type HiddenLifecycleReference. Was actually "
                + reference);
      }

      Method getLifecycle = reference.getClass().getMethod("getLifecycle");
      this.lifecycle = (Lifecycle) getLifecycle.invoke(reference);
    } catch (ClassNotFoundException | NoSuchMethodException | IllegalAccessException | InvocationTargetException e) {
      Log.w(TAG, "You are attempting to use Flutter plugins that are newer than your"
          + " version of Flutter. Plugins may not work as expected.");
    }
  }

  @NonNull
  public Lifecycle getLifecycle() {
    return lifecycle;
  }
}
