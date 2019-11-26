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
package androidx.test.espresso.flutter.model;

import static com.google.common.base.Preconditions.checkNotNull;

import com.google.common.annotations.Beta;
import java.util.Objects;
import javax.annotation.Nonnull;
import javax.annotation.Nullable;

/**
 * Represents a Flutter widget, containing all the properties that are accessible in Espresso.
 *
 * <p>Note, this class should typically be decoded from the Flutter testing protocol. Users of
 * Espresso testing framework should rarely have the needs to build their own {@link WidgetInfo}
 * instance.
 *
 * <p>Also, the current implementation is hard-coded and potentially only works with a limited set
 * of {@code WidgetMatchers}. Later, we might consider codegen of representations for Flutter
 * widgets for extensibility.
 */
@Beta
public class WidgetInfo {

  /** A String representation of a Flutter widget's ValueKey. */
  @Nullable private final String valueKey;
  /** A String representation of the runtime type of the widget. */
  private final String runtimeType;
  /** The widget's text property. */
  @Nullable private final String text;
  /** The widget's tooltip property. */
  @Nullable private final String tooltip;

  WidgetInfo(
      @Nullable String valueKey,
      String runtimeType,
      @Nullable String text,
      @Nullable String tooltip) {
    this.valueKey = valueKey;
    this.runtimeType = checkNotNull(runtimeType, "RuntimeType cannot be null.");
    this.text = text;
    this.tooltip = tooltip;
  }

  /** Returns a String representation of the Flutter widget's ValueKey. Could be null. */
  @Nullable
  public String getValueKey() {
    return valueKey;
  }

  /** Returns a String representation of the runtime type of the Flutter widget. */
  @Nonnull
  public String getType() {
    return runtimeType;
  }

  /** Returns the widget's 'text' property. Will be null for widgets without a 'text' property. */
  @Nullable
  public String getText() {
    return text;
  }

  /**
   * Returns the widget's 'tooltip' property. Will be null for widgets without a 'tooltip' property.
   */
  @Nullable
  public String getTooltip() {
    return tooltip;
  }

  @Override
  public boolean equals(Object obj) {
    if (obj instanceof WidgetInfo) {
      WidgetInfo widget = (WidgetInfo) obj;
      return Objects.equals(widget.valueKey, this.valueKey)
          && Objects.equals(widget.runtimeType, this.runtimeType)
          && Objects.equals(widget.text, this.text)
          && Objects.equals(widget.tooltip, this.tooltip);
    } else {
      return false;
    }
  }

  @Override
  public int hashCode() {
    return Objects.hash(valueKey, runtimeType, text, tooltip);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("Widget [");
    sb.append("runtimeType=").append(runtimeType).append(",");
    if (valueKey != null) {
      sb.append("valueKey=").append(valueKey).append(",");
    }
    if (text != null) {
      sb.append("text=").append(text).append(",");
    }
    if (tooltip != null) {
      sb.append("tooltip=").append(tooltip).append(",");
    }
    sb.append("]");
    return sb.toString();
  }
}
