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

/** Thrown if an ID cannot be generated. */
public final class IdException extends RuntimeException {

  private static final long serialVersionUID = 0L;

  public IdException() {
    super();
  }

  public IdException(String message) {
    super(message);
  }

  public IdException(String message, Throwable throwable) {
    super(message, throwable);
  }

  public IdException(Throwable throwable) {
    super(throwable);
  }
}
