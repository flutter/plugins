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
