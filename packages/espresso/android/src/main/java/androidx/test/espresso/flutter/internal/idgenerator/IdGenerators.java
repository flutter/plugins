/*
 * Copyright (C) 2019 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package androidx.test.espresso.flutter.internal.idgenerator;

import static com.google.common.base.Preconditions.checkArgument;

import java.util.UUID;
import java.util.concurrent.atomic.AtomicInteger;

/** Some simple in-memory ID generators. */
public final class IdGenerators {

  private IdGenerators() {}

  private static final IdGenerator<String> UUID_STRING_GENERATOR =
      new IdGenerator<String>() {
        @Override
        public String next() {
          return UUID.randomUUID().toString();
        }
      };

  /**
   * Returns a {@code Integer} ID generator whose next value is the value passed in. The value
   * returned increases by one each time until {@code Integer.MAX_VALUE}. After that an {@code
   * IdException} is thrown. This IdGenerator is threadsafe.
   */
  public static IdGenerator<Integer> newIntegerIdGenerator(int nextValue) {
    checkArgument(nextValue >= 0, "ID values must be non-negative");
    final AtomicInteger nextInt = new AtomicInteger(nextValue);
    return new IdGenerator<Integer>() {
      @Override
      public Integer next() {
        int value = nextInt.getAndIncrement();
        if (value >= 0) {
          return value;
        }

        // Make sure that all subsequent calls throw by setting to the most
        // negative value possible.
        nextInt.set(Integer.MIN_VALUE);
        throw new IdException("Returned the last integer value available");
      }
    };
  }

  /**
   * Returns a {@code Integer} ID generator whose next value is one. The value returned increases by
   * one each time until {@code Integer.MAX_VALUE}. After that an {@code IdException} is thrown.
   * This IdGenerator is threadsafe.
   */
  public static IdGenerator<Integer> newIntegerIdGenerator() {
    return newIntegerIdGenerator(1);
  }

  /**
   * Returns a {@code String} ID generator that passes ID requests to {@link UUID#randomUUID()},
   * thereby generating type-4 (pseudo-randomly generated) UUIDs.
   */
  public static IdGenerator<String> randomUuidStringGenerator() {
    return UUID_STRING_GENERATOR;
  }
}
