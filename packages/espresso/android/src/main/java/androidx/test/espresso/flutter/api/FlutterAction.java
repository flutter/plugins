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
package androidx.test.espresso.flutter.api;

import android.view.View;
import androidx.test.espresso.UiController;
import java.util.concurrent.Future;
import javax.annotation.Nonnull;
import javax.annotation.Nullable;

/**
 * Represents a Flutter widget action.
 *
 * <p>This interface is part of Espresso-Flutter testing framework. Users should usually expect no
 * return value for an action and use the {@code WidgetAction} for customizing an action on a
 * Flutter widget.
 *
 * @param <R> The type of the action result.
 */
public interface FlutterAction<R> {

  /** Performs an action on the given Flutter widget and gets its return value. */
  Future<R> perform(
      @Nullable WidgetMatcher targetWidget,
      @Nonnull View flutterView,
      @Nonnull FlutterTestingProtocol flutterTestingProtocol,
      @Nonnull UiController androidUiController);
}
