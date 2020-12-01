// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.api;

import android.view.View;
import androidx.test.espresso.UiController;
import com.google.common.annotations.Beta;
import java.util.concurrent.Future;
import javax.annotation.Nonnull;
import javax.annotation.Nullable;

/**
 * Responsible for performing an interaction on the given Flutter widget.
 *
 * <p>This is part of the Espresso-Flutter test framework public API - developers are free to write
 * their own {@code WidgetAction} implementation when necessary.
 */
@Beta
public interface WidgetAction extends FlutterAction<Void> {

  /**
   * Performs this action on the given Flutter widget.
   *
   * <p>If the given {@code targetWidget} is {@code null}, this action shall be performed on the
   * entire {@code FlutterView} in context.
   *
   * @param targetWidget the matcher that uniquely identifies a Flutter widget on the given {@code
   *     FlutterView}. {@code Null} if it's a global action on the {@code FlutterView} in context.
   * @param flutterView the Flutter view that this widget lives in.
   * @param flutterTestingProtocol the channel for talking to Flutter app directly.
   * @param androidUiController the interface for issuing UI operations to the Android system.
   * @return a {@code Future} representing pending completion of performing the action, or yields an
   *     exception if the action failed to perform.
   */
  @Override
  Future<Void> perform(
      @Nullable WidgetMatcher targetWidget,
      @Nonnull View flutterView,
      @Nonnull FlutterTestingProtocol flutterTestingProtocol,
      @Nonnull UiController androidUiController);
}
