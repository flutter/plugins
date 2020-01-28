// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.common;

import java.util.concurrent.TimeUnit;

/** A utility class to hold various constants used by the Espresso-Flutter library. */
public final class Constants {

  // Do not initialize.
  private Constants() {}

  /** Default timeout for actions and asserts like {@code WidgetAction}. */
  public static final Duration DEFAULT_INTERACTION_TIMEOUT = new Duration(10, TimeUnit.SECONDS);
}
