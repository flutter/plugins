// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.internal.protocol.impl;

import static com.google.common.base.Preconditions.checkNotNull;

import androidx.test.espresso.flutter.internal.jsonrpc.message.JsonRpcResponse;
import androidx.test.espresso.flutter.internal.protocol.impl.GetOffsetAction.OffsetType;
import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.google.gson.annotations.Expose;

/**
 * Represents the {@code result} section in a {@code JsonRpcResponse} that's the response of a
 * {@code GetOffsetAction}.
 */
final class GetOffsetResponse {

  private static final Gson gson = new Gson();

  @Expose private boolean isError;
  @Expose private Coordinates response;
  @Expose private String type;

  private GetOffsetResponse() {}

  /**
   * Builds the {@code GetOffsetResponse} out of the JSON-RPC response.
   *
   * @param jsonRpcResponse the JSON-RPC response. Cannot be {@code null}.
   * @return a {@code GetOffsetResponse} instance that's parsed out from the JSON-RPC response.
   */
  public static GetOffsetResponse fromJsonRpcResponse(JsonRpcResponse jsonRpcResponse) {
    checkNotNull(jsonRpcResponse, "The JSON-RPC response cannot be null.");
    if (jsonRpcResponse.getResult() == null) {
      throw new FlutterProtocolException(
          String.format(
              "Error occurred during retrieving a Flutter widget's geometry info. Response"
                  + " received: %s.",
              jsonRpcResponse));
    }
    try {
      return gson.fromJson(jsonRpcResponse.getResult(), GetOffsetResponse.class);
    } catch (JsonSyntaxException e) {
      throw new FlutterProtocolException(
          String.format(
              "Error occurred during retrieving a Flutter widget's geometry info. Response"
                  + " received: %s.",
              jsonRpcResponse),
          e);
    }
  }

  /** Returns whether this is an error response. */
  public boolean isError() {
    return isError;
  }

  /** Returns the vertex position. */
  public OffsetType getType() {
    return OffsetType.fromString(type);
  }

  /** Returns the X-Coordinate. */
  public float getX() {
    if (response == null) {
      throw new FlutterProtocolException(
          String.format(
              "Error occurred during retrieving a Flutter widget's geometry info. Response"
                  + " received: %s",
              this));
    } else {
      return response.dx;
    }
  }

  /** Returns the Y-Coordinate. */
  public float getY() {
    if (response == null) {
      throw new FlutterProtocolException(
          String.format(
              "Error occurred during retrieving a Flutter widget's geometry info. Response"
                  + " received: %s",
              this));
    } else {
      return response.dy;
    }
  }

  @Override
  public String toString() {
    return gson.toJson(this);
  }

  static class Coordinates {

    @Expose private float dx;
    @Expose private float dy;

    Coordinates() {}

    Coordinates(float dx, float dy) {
      this.dx = dx;
      this.dy = dy;
    }
  }

  static class Builder {
    private boolean isError;
    private Coordinates coordinate;
    private OffsetType type;

    public Builder() {}

    public Builder setIsError(boolean isError) {
      this.isError = isError;
      return this;
    }

    public Builder setCoordinates(float dx, float dy) {
      this.coordinate = new Coordinates(dx, dy);
      return this;
    }

    public Builder setType(OffsetType type) {
      this.type = checkNotNull(type);
      return this;
    }

    public GetOffsetResponse build() {
      GetOffsetResponse response = new GetOffsetResponse();
      response.isError = this.isError;
      response.response = this.coordinate;
      response.type = checkNotNull(type).toString();
      return response;
    }
  }
}
