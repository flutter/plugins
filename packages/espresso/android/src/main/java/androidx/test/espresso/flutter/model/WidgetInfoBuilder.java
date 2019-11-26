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

import javax.annotation.Nonnull;
import javax.annotation.Nullable;

/**
 * Builder for {@link WidgetInfo}.
 *
 * <p>Internal only. Users of Espresso framework should rarely have the needs to build their own
 * {@link WidgetInfo} instance.
 */
public class WidgetInfoBuilder {

  @Nullable private String valueKey;
  private String runtimeType;
  @Nullable private String text;
  @Nullable private String tooltip;

  /** Empty constructor. */
  public WidgetInfoBuilder() {}

  /**
   * Constructs the builder with the given {@code runtimeType}.
   *
   * @param runtimeType the runtime type of the widget. Cannot be null.
   */
  public WidgetInfoBuilder(@Nonnull String runtimeType) {
    this.runtimeType = checkNotNull(runtimeType, "RuntimeType cannot be null.");
  }

  /**
   * Sets the value key of the widget.
   *
   * @param valueKey the value key of the widget that shall be set. Could be null.
   */
  public WidgetInfoBuilder setValueKey(@Nullable String valueKey) {
    this.valueKey = valueKey;
    return this;
  }

  /**
   * Sets the runtime type of the widget.
   *
   * @param runtimeType the runtime type of the widget that shall be set. Cannot be null.
   */
  public WidgetInfoBuilder setRuntimeType(@Nonnull String runtimeType) {
    this.runtimeType = checkNotNull(runtimeType, "RuntimeType cannot be null.");
    return this;
  }

  /**
   * Sets the text of the widget.
   *
   * @param text the text of the widget that shall be set. Can be null.
   */
  public WidgetInfoBuilder setText(@Nullable String text) {
    this.text = text;
    return this;
  }

  /**
   * Sets the tooltip of the widget.
   *
   * @param tooltip the tooltip of the widget that shall be set. Can be null.
   */
  public WidgetInfoBuilder setTooltip(@Nullable String tooltip) {
    this.tooltip = tooltip;
    return this;
  }

  /** Builds and returns the {@code WidgetInfo} instance. */
  public WidgetInfo build() {
    return new WidgetInfo(valueKey, runtimeType, text, tooltip);
  }
}
