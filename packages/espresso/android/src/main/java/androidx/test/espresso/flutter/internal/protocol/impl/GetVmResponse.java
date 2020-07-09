// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.internal.protocol.impl;

import static com.google.common.base.Preconditions.checkNotNull;

import androidx.test.espresso.flutter.internal.jsonrpc.message.JsonRpcResponse;
import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.google.gson.annotations.Expose;
import java.util.List;
import java.util.Objects;

/**
 * Represents a response of a <a
 * href="https://github.com/dart-lang/sdk/blob/master/runtime/vm/service/service.md#getvm">getVM()</a>
 * request.
 */
public class GetVmResponse {

  private static final Gson gson = new Gson();

  @Expose private List<Isolate> isolates;

  private GetVmResponse() {}

  /**
   * Builds the {@code GetVmResponse} out of the JSON-RPC response.
   *
   * @param jsonRpcResponse the JSON-RPC response. Cannot be {@code null}.
   * @return a {@code GetVmResponse} instance that's parsed out from the JSON-RPC response.
   */
  public static GetVmResponse fromJsonRpcResponse(JsonRpcResponse jsonRpcResponse) {
    checkNotNull(jsonRpcResponse, "The JSON-RPC response cannot be null.");
    if (jsonRpcResponse.getResult() == null) {
      throw new FlutterProtocolException(
          String.format(
              "Error occurred during retrieving Dart VM info. Response received: %s.",
              jsonRpcResponse));
    }
    try {
      return gson.fromJson(jsonRpcResponse.getResult(), GetVmResponse.class);
    } catch (JsonSyntaxException e) {
      throw new FlutterProtocolException(
          String.format(
              "Error occurred during retrieving Dart VM info. Response received: %s.",
              jsonRpcResponse),
          e);
    }
  }

  /** Returns the number of isolates living in the Dart VM. */
  public int getIsolateNum() {
    return isolates == null ? 0 : isolates.size();
  }

  /** Returns the Dart isolate listed at the given index. */
  public Isolate getIsolate(int index) {
    if (isolates == null) {
      return null;
    } else if (index < 0 || index >= isolates.size()) {
      throw new IllegalArgumentException(
          String.format(
              "Illegal Dart isolate index: %d. Should be in the range [%d, %d]",
              index, 0, isolates.size() - 1));
    } else {
      return isolates.get(index);
    }
  }

  @Override
  public String toString() {
    return gson.toJson(this);
  }

  /** Represents a Dart isolate. */
  static class Isolate {

    @Expose private String id;
    @Expose private boolean runnable;
    @Expose private List<String> extensionRpcList;

    Isolate() {}

    Isolate(String id, boolean runnable) {
      this.id = id;
      this.runnable = runnable;
    }

    /** Gets the Dart isolate ID. */
    public String getId() {
      return id;
    }

    /**
     * Checks whether the Dart isolate is in a runnable state. True if it's runnable, false
     * otherwise.
     */
    public boolean isRunnable() {
      return runnable;
    }

    /** Gets the list of extension RPCs registered at this Dart isolate. Could be {@code null}. */
    public List<String> getExtensionRpcList() {
      return extensionRpcList;
    }

    @Override
    public boolean equals(Object obj) {
      if (obj instanceof Isolate) {
        Isolate isolate = (Isolate) obj;
        return Objects.equals(isolate.id, this.id)
            && Objects.equals(isolate.runnable, this.runnable)
            && Objects.equals(isolate.extensionRpcList, this.extensionRpcList);
      } else {
        return false;
      }
    }

    @Override
    public int hashCode() {
      return Objects.hash(id, runnable, extensionRpcList);
    }
  }
}
