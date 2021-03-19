// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.action;

import android.view.View;
import androidx.test.espresso.UiController;
import androidx.test.espresso.flutter.api.FlutterTestingProtocol;
import androidx.test.espresso.flutter.api.WidgetAction;
import androidx.test.espresso.flutter.api.WidgetMatcher;
import java.util.concurrent.Future;
import javax.annotation.Nonnull;
import javax.annotation.Nullable;

/** An action that ensures Flutter is in an idle state. */
public final class WaitUntilIdleAction implements WidgetAction {

  @Override
  public Future<Void> perform(
      @Nullable WidgetMatcher targetWidget,
      @Nonnull View flutterView,
      @Nonnull FlutterTestingProtocol flutterTestingProtocol,
      @Nonnull UiController androidUiController) {
    return flutterTestingProtocol.waitUntilIdle();
  }

  @Override
  public String toString() {
    return "action that waits until Flutter's idle.";
  }
}
