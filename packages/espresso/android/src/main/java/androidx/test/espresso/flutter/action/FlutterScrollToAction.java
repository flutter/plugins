// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.action;

import android.view.View;
import androidx.test.espresso.UiController;
import androidx.test.espresso.flutter.api.FlutterTestingProtocol;
import androidx.test.espresso.flutter.api.SyntheticAction;
import androidx.test.espresso.flutter.api.WidgetAction;
import androidx.test.espresso.flutter.api.WidgetMatcher;
import com.google.gson.annotations.Expose;
import java.util.concurrent.Future;
import javax.annotation.Nonnull;
import javax.annotation.Nullable;

/**
 * An action that scrolls the Scrollable ancestor of the widget until the widget is completely
 * visible.
 */
public final class FlutterScrollToAction implements WidgetAction {

  @Override
  public Future<Void> perform(
      @Nullable WidgetMatcher targetWidget,
      @Nonnull View flutterView,
      @Nonnull FlutterTestingProtocol flutterTestingProtocol,
      @Nonnull UiController androidUiController) {
    return flutterTestingProtocol.perform(targetWidget, new ScrollIntoViewAction());
  }

  @Override
  public String toString() {
    return "scrollTo";
  }

  static class ScrollIntoViewAction extends SyntheticAction {

    @Expose private final double alignment;

    public ScrollIntoViewAction() {
      this(0.0);
    }

    public ScrollIntoViewAction(double alignment) {
      super("scrollIntoView");
      this.alignment = alignment;
    }
  }
}
