// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.internal.protocol.impl;

/**
 * Represents a condition that waits until no pending frame is scheduled in the Flutter framework.
 */
class NoPendingFrameCondition extends WaitCondition {

  public NoPendingFrameCondition() {
    super("NoPendingFrameCondition");
  }
}
