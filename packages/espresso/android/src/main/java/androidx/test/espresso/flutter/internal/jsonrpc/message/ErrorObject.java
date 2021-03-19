// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.internal.jsonrpc.message;

import com.google.gson.JsonObject;
import java.util.Objects;

/**
 * A class for holding the error object in {@code JsonRpcResponse}.
 *
 * <p>See https://www.jsonrpc.org/specification#error_object for detailed specification.
 */
public class ErrorObject {
  private final int code;
  private final String message;
  private final JsonObject data;

  public ErrorObject(int code, String message) {
    this(code, message, null);
  }

  public ErrorObject(int code, String message, JsonObject data) {
    this.code = code;
    this.message = message;
    this.data = data;
  }

  /** Gets the error code. */
  public int getCode() {
    return code;
  }

  /** Gets the error message. */
  public String getMessage() {
    return message;
  }

  /** Gets the additional information about the error. Could be null. */
  public JsonObject getData() {
    return data;
  }

  @Override
  public boolean equals(Object obj) {
    if (obj instanceof ErrorObject) {
      ErrorObject errorObject = (ErrorObject) obj;
      return errorObject.code == this.code
          && Objects.equals(errorObject.message, this.message)
          && Objects.equals(errorObject.data, this.data);
    } else {
      return false;
    }
  }

  @Override
  public int hashCode() {
    int hash = code;
    hash = hash * 31 + Objects.hashCode(message);
    hash = hash * 31 + Objects.hashCode(data);
    return hash;
  }
}
