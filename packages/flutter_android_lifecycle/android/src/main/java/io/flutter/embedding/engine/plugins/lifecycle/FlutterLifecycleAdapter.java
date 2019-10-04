// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.embedding.engine.plugins.lifecycle;

import androidx.lifecycle.Lifecycle;
import androidx.annotation.NonNull;

public class FlutterLifecycleAdapter {
  @NonNull
  private final Lifecycle lifecycle;

  public FlutterLifecycleAdapter(@NonNull Object reference) {
    if (!(reference instanceof HiddenLifecycleReference)) {
      throw new IllegalArgumentException("The reference argument must be of type HiddenLifecycleReference. Was actually " + reference);
    }

    this.lifecycle = ((HiddenLifecycleReference) reference).getLifecycle();
  }

  @NonNull
  public Lifecycle getLifecycle() {
    return lifecycle;
  }
}
