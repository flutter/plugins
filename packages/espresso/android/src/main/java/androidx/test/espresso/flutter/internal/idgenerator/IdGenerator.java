// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.internal.idgenerator;

import com.google.errorprone.annotations.CanIgnoreReturnValue;

/** Generates unique IDs of the parameterized type. */
public interface IdGenerator<T> {

  /**
   * Returns a new, unique ID.
   *
   * @throws IdException if there were any errors in getting an ID.
   */
  @CanIgnoreReturnValue
  T next();
}
