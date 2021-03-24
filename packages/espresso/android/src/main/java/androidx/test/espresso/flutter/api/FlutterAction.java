// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
