// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.action;

import android.view.View;
import androidx.test.annotation.Beta;
import androidx.test.espresso.UiController;
import androidx.test.espresso.flutter.api.FlutterTestingProtocol;
import androidx.test.espresso.flutter.api.SyntheticAction;
import androidx.test.espresso.flutter.api.WidgetAction;
import androidx.test.espresso.flutter.api.WidgetMatcher;
import java.util.concurrent.Future;
import javax.annotation.Nonnull;
import javax.annotation.Nullable;

/**
 * A synthetic click on a Flutter widget.
 *
 * <p>Note, this is not a real click gesture event issued from Android system. Espresso delegates to
 * Flutter engine to perform the {@link SyntheticClick} action.
 */
@Beta
public final class SyntheticClickAction implements WidgetAction {

  @Override
  public Future<Void> perform(
      @Nullable WidgetMatcher targetWidget,
      @Nonnull View flutterView,
      @Nonnull FlutterTestingProtocol flutterTestingProtocol,
      @Nonnull UiController androidUiController) {
    return flutterTestingProtocol.perform(targetWidget, new SyntheticClick());
  }

  @Override
  public String toString() {
    return "click";
  }

  static class SyntheticClick extends SyntheticAction {

    public SyntheticClick() {
      super("tap");
    }
  }
}
