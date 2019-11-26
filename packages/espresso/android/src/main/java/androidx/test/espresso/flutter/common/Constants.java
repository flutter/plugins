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
package androidx.test.espresso.flutter.common;

import java.util.concurrent.TimeUnit;

/** A utility class to hold various constants used by the Espresso-Flutter library. */
public final class Constants {

  // Do not initialize.
  private Constants() {}

  /** Default timeout for actions and asserts like {@code WidgetAction}. */
  public static final Duration DEFAULT_INTERACTION_TIMEOUT = new Duration(10, TimeUnit.SECONDS);
}
