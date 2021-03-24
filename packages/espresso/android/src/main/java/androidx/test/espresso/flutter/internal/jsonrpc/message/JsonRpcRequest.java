// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.internal.jsonrpc.message;

import static com.google.common.base.Preconditions.checkArgument;
import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.base.Preconditions.checkState;
import static com.google.common.base.Strings.isNullOrEmpty;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.annotations.SerializedName;
import java.util.Objects;
import javax.annotation.Nullable;

/**
 * JSON-RPC 2.0 request object.
 *
 * <p>See https://www.jsonrpc.org/specification for detailed specification.
 */
public final class JsonRpcRequest {

  private static final Gson gson = new Gson();

  private static final String JSON_RPC_VERSION = "2.0";

  /** Specifying the version of the JSON-RPC protocol. Must be "2.0". */
  @SerializedName("jsonrpc")
  private final String version;

  /**
   * An identifier of the request. Could be String, a number, or null. In this implementation, we
   * always use String as the type. If null, this is a notification and no response is required.
   */
  @Nullable private final String id;

  /** A String containing the name of the method to be invoked. */
  private final String method;

  /** Parameter values to be used during the invocation of the method. */
  private JsonObject params;

  /**
   * Deserializes the given Json string to a {@code JsonRpcRequest} object.
   *
   * @param jsonString the string from which the object is to be deserialized.
   * @return the deserialized object.
   */
  public static JsonRpcRequest fromJson(String jsonString) {
    checkArgument(!isNullOrEmpty(jsonString), "Json string cannot be null or empty.");
    JsonRpcRequest request = gson.fromJson(jsonString, JsonRpcRequest.class);
    checkState(JSON_RPC_VERSION.equals(request.getVersion()), "JSON-RPC version must be 2.0.");
    checkState(
        !isNullOrEmpty(request.getMethod()), "JSON-RPC request must contain the method field.");
    return request;
  }

  /**
   * Constructs with the given method name. The JSON-RPC version will be defaulted to "2.0".
   *
   * @param method the method name of this request.
   */
  private JsonRpcRequest(String method) {
    this(null, method);
  }

  /**
   * Constructs with the given id and method name. The JSON-RPC version will be defaulted to "2.0".
   *
   * @param id the id of this request.
   * @param method the method name of this request.
   */
  private JsonRpcRequest(@Nullable String id, String method) {
    this.version = JSON_RPC_VERSION;
    this.id = id;
    this.method = checkNotNull(method, "JSON-RPC request method cannot be null.");
  }

  /**
   * Gets the JSON-RPC version.
   *
   * @return the JSON-RPC version. Should always be "2.0".
   */
  public String getVersion() {
    return version;
  }

  /**
   * Gets the id of this JSON-RPC request.
   *
   * @return the id of this request. Returns null if this is a notification request.
   */
  public String getId() {
    return id;
  }

  /**
   * Gets the method name of this JSON-RPC request.
   *
   * @return the method name.
   */
  public String getMethod() {
    return method;
  }

  /** Gets the params used in this request. */
  public JsonObject getParams() {
    return params;
  }

  /**
   * Serializes this object to its equivalent Json representation.
   *
   * @return the Json representation of this object.
   */
  public String toJson() {
    return gson.toJson(this);
  }

  /**
   * Equivalent to {@link #toJson()}.
   *
   * @return the Json representation of this object.
   */
  @Override
  public String toString() {
    return toJson();
  }

  @Override
  public boolean equals(Object obj) {
    if (obj instanceof JsonRpcRequest) {
      JsonRpcRequest objRequest = (JsonRpcRequest) obj;
      return Objects.equals(objRequest.id, this.id)
          && Objects.equals(objRequest.method, this.method)
          && Objects.equals(objRequest.params, this.params);
    } else {
      return false;
    }
  }

  @Override
  public int hashCode() {
    int hash = Objects.hashCode(id);
    hash = hash * 31 + Objects.hashCode(method);
    hash = hash * 31 + Objects.hashCode(params);
    return hash;
  }

  /** Builder for {@link JsonRpcRequest}. */
  public static class Builder {

    /** The request id. Could be null if the request is a notification. */
    @Nullable private String id;

    /** A String containing the name of the method to be invoked. */
    private String method;

    /** Parameter values to be used during the invocation of the method. */
    private JsonObject params = new JsonObject();

    /** Empty constructor. */
    public Builder() {}

    /**
     * Constructs an instance with the given method name.
     *
     * @param method the method name of this request builder.
     */
    public Builder(String method) {
      this.method = method;
    }

    /** Sets the id of this request builder. */
    public Builder setId(@Nullable String id) {
      this.id = id;
      return this;
    }

    /** Sets the method name of this request builder. */
    public Builder setMethod(String method) {
      this.method = method;
      return this;
    }

    /** Sets the params of this request builder. */
    public Builder setParams(JsonObject params) {
      this.params = params;
      return this;
    }

    /** Sugar method to add a {@code String} param to this request builder. */
    public Builder addParam(String tag, String value) {
      params.addProperty(tag, value);
      return this;
    }

    /** Sugar method to add an integer param to this request builder. */
    public Builder addParam(String tag, int value) {
      params.addProperty(tag, value);
      return this;
    }

    /** Sugar method to add a {@code boolean} param to this request builder. */
    public Builder addParam(String tag, boolean value) {
      params.addProperty(tag, value);
      return this;
    }

    /** Builds and returns a {@code JsonRpcRequest} instance out of this builder. */
    public JsonRpcRequest build() {
      JsonRpcRequest request = new JsonRpcRequest(id, method);
      if (params != null && params.size() != 0) {
        request.params = this.params;
      }
      return request;
    }
  }
}
