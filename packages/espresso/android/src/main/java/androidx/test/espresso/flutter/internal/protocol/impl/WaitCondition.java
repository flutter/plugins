// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.internal.protocol.impl;

import static com.google.common.base.Preconditions.checkNotNull;

/** The base class that represents a wait condition in the Flutter app. */
abstract class WaitCondition {
  // Used in JSON serialization.
  @SuppressWarnings("unused")
  private final String conditionName;

  public WaitCondition(String conditionName) {
    this.conditionName = checkNotNull(conditionName);
  }
}
