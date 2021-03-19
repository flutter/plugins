// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.action;

import android.view.View;
import androidx.test.espresso.UiController;
import androidx.test.espresso.flutter.api.FlutterAction;
import androidx.test.espresso.flutter.api.FlutterTestingProtocol;
import androidx.test.espresso.flutter.api.WidgetMatcher;
import androidx.test.espresso.flutter.model.WidgetInfo;
import java.util.concurrent.Future;
import javax.annotation.Nonnull;
import javax.annotation.Nullable;

/** A {@link FlutterAction} that retrieves the {@code WidgetInfo} of the matched Flutter widget. */
public final class WidgetInfoFetcher implements FlutterAction<WidgetInfo> {

  @Override
  public Future<WidgetInfo> perform(
      @Nullable WidgetMatcher targetWidget,
      @Nonnull View flutterView,
      @Nonnull FlutterTestingProtocol flutterTestingProtocol,
      @Nonnull UiController androidUiController) {
    return flutterTestingProtocol.matchWidget(targetWidget);
  }
}
