// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.internal.protocol.impl;

/** Represents an exception/error relevant to Dart VM service. */
public final class FlutterProtocolException extends RuntimeException {

  public FlutterProtocolException(String message) {
    super(message);
  }

  public FlutterProtocolException(Throwable t) {
    super(t);
  }

  public FlutterProtocolException(String message, Throwable t) {
    super(message, t);
  }
}
