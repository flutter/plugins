// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.action;

import androidx.test.espresso.flutter.api.WidgetAction;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import javax.annotation.Nonnull;

/** A collection of actions that can be performed on {@code FlutterView}s or Flutter widgets. */
public final class FlutterActions {

  private static final ExecutorService taskExecutor = Executors.newCachedThreadPool();

  // Do not initialize.
  private FlutterActions() {}

  /**
   * Returns a click action that can be performed on a Flutter widget.
   *
   * <p>The current implementation simply clicks at the center of the widget (with no visibility
   * checks yet). Internally, it calculates the coordinates to click on screen based on the position
   * of the matched Flutter widget and also its outer Flutter view, and injects gesture events to
   * the Android system to mimic a human's click.
   *
   * <p>Try {@link #syntheticClick()} only when this action cannot handle your case properly, e.g.
   * Flutter's internal state (only accessible within Flutter) affects how the action should
   * performed.
   */
  public static WidgetAction click() {
    return new ClickAction(taskExecutor);
  }

  /**
   * Returns a synthetic click action that can be performed on a Flutter widget.
   *
   * <p>Note, this is not a real click gesture event issued from Android system. Espresso delegates
   * to Flutter engine to perform the action.
   *
   * <p>Always prefer {@link #click()} as it exercises the entire Flutter stack and your Flutter app
   * by directly injecting key events to the Android system. Uses this {@link #syntheticClick()}
   * only when there are special cases that {@link #click()} cannot handle properly.
   */
  public static WidgetAction syntheticClick() {
    return new SyntheticClickAction();
  }

  /**
   * Returns an action that focuses on the widget (by clicking on it) and types the provided string
   * into the widget. Appending a \n to the end of the string translates to a ENTER key event. Note:
   * this method performs a tap on the widget before typing to force the widget into focus, if the
   * widget already contains text this tap may place the cursor at an arbitrary position within the
   * text.
   *
   * <p>The Flutter widget must support input methods.
   *
   * @param stringToBeTyped the text String that shall be input to the matched widget. Cannot be
   *     {@code null}.
   */
  public static WidgetAction typeText(@Nonnull String stringToBeTyped) {
    return new FlutterTypeTextAction(stringToBeTyped, taskExecutor);
  }

  /**
   * Returns an action that scrolls to the widget.
   *
   * <p>The widget must be a descendant of a scrollable widget like SingleChildScrollView.
   */
  public static WidgetAction scrollTo() {
    return new FlutterScrollToAction();
  }
}
