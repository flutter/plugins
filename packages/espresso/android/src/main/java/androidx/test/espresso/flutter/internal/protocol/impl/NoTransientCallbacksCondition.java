// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.internal.protocol.impl;

/** Represents a condition that waits until no transient callbacks in the Flutter framework. */
class NoTransientCallbacksCondition extends WaitCondition {

  public NoTransientCallbacksCondition() {
    super("NoTransientCallbacksCondition");
  }
}
