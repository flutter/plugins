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
package androidx.test.espresso.flutter.internal.jsonrpc.message;

import static com.google.common.base.Preconditions.checkArgument;
import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.base.Preconditions.checkState;
import static com.google.common.base.Strings.isNullOrEmpty;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.annotations.SerializedName;
import java.util.Objects;

/**
 * JSON-RPC 2.0 response object.
 *
 * <p>See https://www.jsonrpc.org/specification for detailed specification.
 */
public final class JsonRpcResponse {

  private static final Gson gson = new Gson();

  private static final String JSON_RPC_VERSION = "2.0";

  /** Specifying the version of the JSON-RPC protocol. Must be "2.0". */
  @SerializedName("jsonrpc")
  private final String version;

  /**
   * Required. Must be the same as the value of the id in the corresponding JsonRpcRequest object.
   */
  private String id;

  /** The result of the JSON-RPC call. Required on success. */
  private JsonObject result;

  /** Error occurred in the JSON-RPC call. Required on error. */
  private ErrorObject error;

  /**
   * Deserializes the given Json string to a {@code JsonRpcResponse} object.
   *
   * @param jsonString the string from which the object is to be deserialized.
   * @return the deserialized object.
   */
  public static JsonRpcResponse fromJson(String jsonString) {
    checkArgument(!isNullOrEmpty(jsonString), "Json string cannot be null or empty.");
    JsonRpcResponse response = gson.fromJson(jsonString, JsonRpcResponse.class);
    checkState(!isNullOrEmpty(response.getId()));
    checkState(JSON_RPC_VERSION.equals(response.getVersion()), "JSON-RPC version must be 2.0.");
    return response;
  }

  /**
   * Constructs with the given id and. The JSON-RPC version will be defaulted to "2.0".
   *
   * @param id the id of this response. Should be the same as the corresponding request.
   */
  public JsonRpcResponse(String id) {
    this.version = JSON_RPC_VERSION;
    setId(id);
  }

  /**
   * Gets the JSON-RPC version.
   *
   * @return the JSON-RPC version. Should always be "2.0".
   */
  public String getVersion() {
    return version;
  }

  /** Gets the id of this JSON-RPC response. */
  public String getId() {
    return id;
  }

  /**
   * Sets the id of this JSON-RPC response.
   *
   * @param id the id to be set. Cannot be null.
   */
  public void setId(String id) {
    this.id = checkNotNull(id);
  }

  /** Gets the result of this JSON-RPC response. Should be present on success. */
  public JsonObject getResult() {
    return result;
  }

  /**
   * Sets the result of this JSON-RPC response.
   *
   * @param result
   */
  public void setResult(JsonObject result) {
    this.result = result;
  }

  /** Gets the error object of this JSON-RPC response. Should be present on error. */
  public ErrorObject getError() {
    return error;
  }

  /**
   * Sets the error object of this JSON-RPC response.
   *
   * @param error the error to be set.
   */
  public void setError(ErrorObject error) {
    this.error = error;
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
    if (obj instanceof JsonRpcResponse) {
      JsonRpcResponse objResponse = (JsonRpcResponse) obj;
      return Objects.equals(objResponse.id, this.id)
          && Objects.equals(objResponse.result, this.result)
          && Objects.equals(objResponse.error, this.error);
    } else {
      return false;
    }
  }

  @Override
  public int hashCode() {
    int hash = Objects.hashCode(id);
    hash = hash * 31 + Objects.hashCode(result);
    hash = hash * 31 + Objects.hashCode(error);
    return hash;
  }
}
