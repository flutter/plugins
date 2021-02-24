// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.common;

import static com.google.common.base.Preconditions.checkNotNull;

import java.util.concurrent.TimeUnit;
import javax.annotation.Nullable;

/**
 * A simple implementation of a time duration, supposed to be used within the Espresso-Flutter
 * library.
 *
 * <p>This class is immutable.
 */
public final class Duration {

  private final long quantity;
  private final TimeUnit unit;

  /**
   * Initializes a Duration instance.
   *
   * @param quantity the amount of time in the given unit.
   * @param unit the time unit. Cannot be null.
   */
  public Duration(long quantity, TimeUnit unit) {
    this.quantity = quantity;
    this.unit = checkNotNull(unit, "Time unit cannot be null.");
  }

  /** Returns the amount of time. */
  public long getQuantity() {
    return quantity;
  }

  /** Returns the time unit. */
  public TimeUnit getUnit() {
    return unit;
  }

  /** Returns the amount of time in milliseconds. */
  public long toMillis() {
    return TimeUnit.MILLISECONDS.convert(quantity, unit);
  }

  /**
   * Returns a new Duration instance that adds this instance to the given {@code duration}. If the
   * given {@code duration} is null, this method simply returns this instance.
   */
  public Duration plus(@Nullable Duration duration) {
    if (duration == null) {
      return this;
    }
    long add = unit.convert(duration.quantity, duration.unit);
    long newQuantity = quantity + add;
    return new Duration(newQuantity, unit);
  }
}
