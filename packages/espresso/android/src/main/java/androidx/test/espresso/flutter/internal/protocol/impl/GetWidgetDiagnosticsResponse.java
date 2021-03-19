// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.internal.protocol.impl;

import static com.google.common.base.Preconditions.checkNotNull;

import android.util.Log;
import androidx.test.espresso.flutter.internal.jsonrpc.message.JsonRpcResponse;
import com.google.common.annotations.VisibleForTesting;
import com.google.common.base.Ascii;
import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;
import java.util.List;
import java.util.Objects;

/** Represents a response of the {@code GetWidgetDiagnosticsAction}. */
final class GetWidgetDiagnosticsResponse {

  private static final String TAG = GetWidgetDiagnosticsResponse.class.getSimpleName();
  private static final Gson gson = new Gson();

  @Expose private boolean isError;

  @Expose
  @SerializedName("response")
  private DiagnosticNodeInfo widgetInfo;

  private GetWidgetDiagnosticsResponse() {}

  /**
   * Builds the {@code GetWidgetDiagnosticsResponse} out of the JSON-RPC response.
   *
   * @param jsonRpcResponse the JSON-RPC response. Cannot be {@code null}.
   * @return a {@code GetWidgetDiagnosticsResponse} instance that's parsed out from the JSON-RPC
   *     response.
   */
  public static GetWidgetDiagnosticsResponse fromJsonRpcResponse(JsonRpcResponse jsonRpcResponse) {
    checkNotNull(jsonRpcResponse, "The JSON-RPC response cannot be null.");
    if (jsonRpcResponse.getResult() == null) {
      throw new FlutterProtocolException(
          String.format(
              "Error occurred during retrieving widget's diagnostics info. Response received: %s.",
              jsonRpcResponse));
    }
    try {
      return gson.fromJson(jsonRpcResponse.getResult(), GetWidgetDiagnosticsResponse.class);
    } catch (JsonSyntaxException e) {
      throw new FlutterProtocolException(
          String.format(
              "Error occurred during retrieving widget's diagnostics info. Response received: %s.",
              jsonRpcResponse),
          e);
    }
  }

  /** Returns whether this is an error response. */
  public boolean isError() {
    return isError;
  }

  /** Returns the runtime type of this widget, or {@code null} if the type info is not available. */
  public String getRuntimeType() {
    if (widgetInfo == null) {
      Log.w(TAG, "Widget info is null.");
      return null;
    } else {
      return widgetInfo.runtimeType;
    }
  }

  /**
   * Gets the widget property by its name, or null if the property doesn't exist.
   *
   * @param propertyName the property name. Cannot be {@code null}.
   */
  public WidgetProperty getPropertyByName(String propertyName) {
    checkNotNull(propertyName, "Widget property name cannot be null.");
    if (widgetInfo == null) {
      Log.w(TAG, "Widget info is null.");
      return null;
    }
    return widgetInfo.getPropertyByName(propertyName);
  }

  /**
   * Returns the description of this widget, or {@code null} if the diagnostics info is not
   * available.
   */
  public String getDescription() {
    if (widgetInfo == null) {
      Log.w(TAG, "Widget info is null.");
      return null;
    }
    return widgetInfo.description;
  }

  /**
   * Returns whether this widget has children, or {@code false} if the diagnostics info is not
   * available.
   */
  public boolean isHasChildren() {
    if (widgetInfo == null) {
      Log.w(TAG, "Widget info is null.");
      return false;
    }
    return widgetInfo.hasChildren;
  }

  @Override
  public String toString() {
    return gson.toJson(this);
  }

  /** A data structure that holds a widget's diagnostics info. */
  static class DiagnosticNodeInfo {

    @Expose
    @SerializedName("widgetRuntimeType")
    private String runtimeType;

    @Expose private List<WidgetProperty> properties;
    @Expose private String description;
    @Expose private boolean hasChildren;

    WidgetProperty getPropertyByName(String propertyName) {
      checkNotNull(propertyName, "Widget property name cannot be null.");
      if (properties == null) {
        Log.w(TAG, "Widget property list is null.");
        return null;
      }
      for (WidgetProperty property : properties) {
        if (Ascii.equalsIgnoreCase(propertyName, property.getName())) {
          return property;
        }
      }
      return null;
    }
  }

  /** Represents a widget property. */
  static class WidgetProperty {
    @Expose private final String name;
    @Expose private final String value;
    @Expose private final String description;

    @VisibleForTesting
    WidgetProperty(String name, String value, String description) {
      this.name = name;
      this.value = value;
      this.description = description;
    }

    /** Returns the name of this widget property. */
    public String getName() {
      return name;
    }

    /** Returns the value of this widget property. */
    public String getValue() {
      return value;
    }

    /** Returns the description of this widget property. */
    public String getDescription() {
      return description;
    }

    @Override
    public boolean equals(Object obj) {
      if (!(obj instanceof WidgetProperty)) {
        return false;
      } else {
        WidgetProperty widgetProperty = (WidgetProperty) obj;
        return Objects.equals(this.name, widgetProperty.name)
            && Objects.equals(this.value, widgetProperty.value)
            && Objects.equals(this.description, widgetProperty.description);
      }
    }

    @Override
    public int hashCode() {
      return Objects.hash(name, value, description);
    }
  }
}
