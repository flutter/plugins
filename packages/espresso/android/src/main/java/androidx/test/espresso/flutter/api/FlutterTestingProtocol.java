// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.api;

import android.graphics.Rect;
import androidx.test.espresso.flutter.model.WidgetInfo;
import com.google.common.annotations.Beta;
import java.util.concurrent.Future;
import javax.annotation.Nonnull;
import javax.annotation.Nullable;

/** Defines the testing protocol/semantics between Espresso and Flutter. */
@Beta
public interface FlutterTestingProtocol {

  /** Returns a future that waits until the Flutter testing protocol is in a usable state. */
  public Future<Void> connect();

  /**
   * Performs a synthetic action on the Flutter widget that matches the given {@code widgetMatcher}.
   *
   * <p>If failed to perform the given {@code action}, returns a {@code Future} containing an {@code
   * ExecutionException} that wraps the following exception:
   *
   * <ul>
   *   <li>{@code AmbiguousWidgetMatcherException} if the given {@code widgetMatcher} matched
   *       multiple widgets in the hierarchy when only one widget was expected.
   *   <li>{@code NoMatchingWidgetException} if the given {@code widgetMatcher} did not match any
   *       widget in the Flutter UI hierarchy.
   *   <li>{@code ConnectException} if connection error occurred.
   * </ul>
   *
   * @param widgetMatcher the matcher to match a Flutter widget. If {@code null}, {@code action} is
   *     not performed on a specific widget.
   * @param action the action to be performed on the widget.
   * @return a {@code Future} representing pending completion of performing the action, or yields an
   *     exception if the action was failed to perform.
   */
  Future<Void> perform(@Nullable WidgetMatcher widgetMatcher, @Nonnull SyntheticAction action);

  /**
   * Returns a Java representation of the Flutter widget that matches the given widget matcher.
   *
   * <p>If failed to find a matching widget, returns a {@code Future} containing an {@code
   * ExecutionException} that wraps the following exception:
   *
   * <ul>
   *   <li>{@code AmbiguousWidgetMatcherException} if the given {@code widgetMatcher} matched
   *       multiple widgets in the hierarchy when only one widget was expected.
   *   <li>{@code NoMatchingWidgetException} if the given {@code widgetMatcher} did not match any
   *       widget in the Flutter UI hierarchy.
   *   <li>{@code ConnectException} if connection error occurred.
   * </ul>
   *
   * @param widgetMatcher the matcher to match a Flutter widget. Cannot be {@code null}.
   * @return a {@code Future} representing pending completion of the matching operation.
   */
  Future<WidgetInfo> matchWidget(@Nonnull WidgetMatcher widgetMatcher);

  /**
   * Returns the local (as relative to its outer Flutter View) rectangle area of a widget that
   * matches the given widget matcher.
   *
   * @param widgetMatcher the matcher to match a Flutter widget. Cannot be {@code null}.
   * @return a rectangle area where the matched widget lives, in the unit of dp (Density-independent
   *     Pixel).
   */
  Future<Rect> getLocalRect(@Nonnull WidgetMatcher widgetMatcher);

  /** Waits until the Flutter frame is in a stable state. */
  Future<Void> waitUntilIdle();

  /** Releases all the resources associated with this testing protocol connection. */
  void close();
}
