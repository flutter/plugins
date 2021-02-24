// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.internal.protocol.impl;

import static com.google.common.base.Preconditions.checkNotNull;

import android.util.Log;
import androidx.test.espresso.flutter.model.WidgetInfo;
import androidx.test.espresso.flutter.model.WidgetInfoBuilder;

/** A factory that creates {@link WidgetInfo} instances. */
final class WidgetInfoFactory {

  private static final String TAG = WidgetInfoFactory.class.getSimpleName();

  private enum WidgetRuntimeType {
    TEXT("Text"),
    RICH_TEXT("RichText"),
    UNKNOWN("Unknown");

    private WidgetRuntimeType(String typeString) {
      this.type = typeString;
    }

    private final String type;

    @Override
    public String toString() {
      return type;
    }

    public static WidgetRuntimeType getType(String typeString) {
      for (WidgetRuntimeType widgetType : WidgetRuntimeType.values()) {
        if (widgetType.type.equals(typeString)) {
          return widgetType;
        }
      }
      return UNKNOWN;
    }
  }

  /**
   * Creates a {@code WidgetInfo} instance based on the given diagnostics info.
   *
   * <p>The current implementation is ugly. As the widget's properties are serialized out as JSON
   * strings, we have to inspect the content based on the widget type.
   *
   * @throws FlutterProtocolException when the given {@code widgetDiagnostics} is invalid.
   */
  public static WidgetInfo createWidgetInfo(GetWidgetDiagnosticsResponse widgetDiagnostics) {
    checkNotNull(widgetDiagnostics, "The widget diagnostics instance is null.");
    WidgetInfoBuilder widgetInfo = new WidgetInfoBuilder();
    if (widgetDiagnostics.getRuntimeType() == null) {
      throw new FlutterProtocolException(
          String.format(
              "The widget diagnostics info must contain the runtime type of the widget. Illegal"
                  + " widget diagnostics info: %s.",
              widgetDiagnostics));
    }
    widgetInfo.setRuntimeType(widgetDiagnostics.getRuntimeType());

    // Ugly, but let's figure out a better way as this evolves.
    switch (WidgetRuntimeType.getType(widgetDiagnostics.getRuntimeType())) {
      case TEXT:
        // Flutter Text Widget's "data" field stores the text info.
        if (widgetDiagnostics.getPropertyByName("data") != null) {
          String text = widgetDiagnostics.getPropertyByName("data").getValue();
          widgetInfo.setText(text);
        }
        break;
      case RICH_TEXT:
        if (widgetDiagnostics.getPropertyByName("text") != null) {
          String richText = widgetDiagnostics.getPropertyByName("text").getValue();
          widgetInfo.setText(richText);
        }
        break;
      default:
        // Let's be silent when we know little about the widget's type.
        // The widget's fields will be mostly empty but it can be used for checking the existence
        // of the widget.
        Log.i(
            TAG,
            String.format(
                "Unknown widget type: %s. Widget diagnostics info: %s.",
                widgetDiagnostics.getRuntimeType(), widgetDiagnostics));
    }
    return widgetInfo.build();
  }
}
