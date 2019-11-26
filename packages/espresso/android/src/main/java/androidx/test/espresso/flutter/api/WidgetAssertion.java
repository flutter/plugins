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
import androidx.test.espresso.flutter.model.WidgetInfo;
import com.google.common.annotations.Beta;

/**
 * Similar to a {@code ViewAssertion}, a {@link WidgetAssertion} is responsible for performing an
 * assertion on a Flutter widget.
 */
@Beta
public interface WidgetAssertion {

  /**
   * Checks the state of the Flutter widget.
   *
   * @param flutterView the Flutter view that this widget lives in.
   * @param widgetInfo the instance that represents a Flutter widget.
   */
  void check(View flutterView, WidgetInfo widgetInfo);
}
