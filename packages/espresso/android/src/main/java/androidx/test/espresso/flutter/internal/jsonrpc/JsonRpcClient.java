// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.internal.jsonrpc;

import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.base.Strings.isNullOrEmpty;
import static com.google.common.util.concurrent.Futures.immediateFailedFuture;
import static com.google.common.util.concurrent.Futures.immediateFuture;

import android.util.Log;
import androidx.test.espresso.flutter.internal.jsonrpc.message.JsonRpcRequest;
import androidx.test.espresso.flutter.internal.jsonrpc.message.JsonRpcResponse;
import com.google.common.collect.Maps;
import com.google.common.util.concurrent.ListenableFuture;
import com.google.common.util.concurrent.SettableFuture;
import java.net.ConnectException;
import java.net.URI;
import java.util.concurrent.ConcurrentMap;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.WebSocket;
import okhttp3.WebSocketListener;

/**
 * A client that can be used to talk to a WebSocket-based JSON-RPC server.
 *
 * <p>One {@code JsonRpcClient} instance is not supposed to be shared between multiple threads.
 * Always create a new instance of {@code JsonRpcClient} for connecting to a new JSON-RPC URI, but
 * try to reuse the {@link OkHttpClient} instance, which is thread-safe and maintains a thread pool
 * in handling requests and responses.
 */
public class JsonRpcClient {

  private static final String TAG = JsonRpcClient.class.getSimpleName();
  private static final int NORMAL_CLOSURE_STATUS = 1000;

  private final URI webSocketUri;
  private final ConcurrentMap<String, SettableFuture<JsonRpcResponse>> responseFutures;
  private WebSocket webSocketConn;

  /** {@code client} can be shared between multiple {@code JsonRpcClient}s. */
  public JsonRpcClient(OkHttpClient client, URI webSocketUri) {
    this.webSocketUri = checkNotNull(webSocketUri, "WebSocket URL can't be null.");
    responseFutures = Maps.newConcurrentMap();
    connect(checkNotNull(client, "OkHttpClient can't be null."), webSocketUri);
  }

  private void connect(OkHttpClient client, URI webSocketUri) {
    Request request = new Request.Builder().url(webSocketUri.toString()).build();
    WebSocketListener webSocketListener = new WebSocketListenerImpl();
    webSocketConn = client.newWebSocket(request, webSocketListener);
  }

  /** Closes the web socket connection. Non-blocking, and will return immediately. */
  public void disconnect() {
    if (webSocketConn != null) {
      webSocketConn.close(NORMAL_CLOSURE_STATUS, "Client request closing. All requests handled.");
    }
  }

  /**
   * Sends a JSON-RPC request and returns a {@link ListenableFuture} with which the client could
   * wait on response. If the {@code request} is a JSON-RPC notification, this method returns
   * immediately with a {@code null} response.
   *
   * @param request the JSON-RPC request to be sent.
   * @return a {@code ListenableFuture} representing pending completion of the request, or yields an
   *     {@code ExecutionException}, which wraps a {@code ConnectException} if failed to send the
   *     request.
   */
  public ListenableFuture<JsonRpcResponse> request(JsonRpcRequest request) {
    checkNotNull(request, "JSON-RPC request shouldn't be null.");
    if (Log.isLoggable(TAG, Log.DEBUG)) {
      Log.d(
          TAG,
          String.format("JSON-RPC Request sent to uri %s: %s.", webSocketUri, request.toJson()));
    }
    if (webSocketConn == null) {
      ConnectException e =
          new ConnectException("WebSocket connection was not initiated correctly.");
      return immediateFailedFuture(e);
    }
    synchronized (responseFutures) {
      // Holding the lock of responseFutures for send-and-add operations, so that we could make sure
      // to add its ListenableFuture to the responseFutures map before the thread of
      // {@code WebSocketListenerImpl#onMessage} method queries the map.
      boolean succeeded = webSocketConn.send(request.toJson());
      if (!succeeded) {
        ConnectException e = new ConnectException("Failed to send request: " + request);
        return immediateFailedFuture(e);
      }
      if (isNullOrEmpty(request.getId())) {
        // Request id is null or empty. This is a notification request, so returns immediately.
        return immediateFuture(null);
      } else {
        SettableFuture<JsonRpcResponse> responseFuture = SettableFuture.create();
        responseFutures.put(request.getId(), responseFuture);
        return responseFuture;
      }
    }
  }

  /** A callback listener that handles incoming web socket messages. */
  private class WebSocketListenerImpl extends WebSocketListener {
    @Override
    public void onMessage(WebSocket webSocket, String response) {
      if (Log.isLoggable(TAG, Log.DEBUG)) {
        Log.d(TAG, String.format("JSON-RPC response received: %s.", response));
      }
      JsonRpcResponse responseObj = JsonRpcResponse.fromJson(response);
      synchronized (responseFutures) {
        if (isNullOrEmpty(responseObj.getId())
            || !responseFutures.containsKey(responseObj.getId())) {
          Log.w(
              TAG,
              String.format(
                  "Received a message with empty or unknown ID: %s. Drop the message.",
                  responseObj.getId()));
          return;
        }
        SettableFuture<JsonRpcResponse> responseFuture =
            responseFutures.remove(responseObj.getId());
        responseFuture.set(responseObj);
      }
    }

    @Override
    public void onClosing(WebSocket webSocket, int code, String reason) {
      Log.d(
          TAG,
          String.format(
              "Server requested connection close with code %d, reason: %s", code, reason));
      webSocket.close(NORMAL_CLOSURE_STATUS, "Server requested closing connection.");
    }

    @Override
    public void onFailure(WebSocket webSocket, Throwable t, Response response) {
      Log.w(TAG, String.format("Failed to deliver message with error: %s.", t.getMessage()));
      throw new RuntimeException("WebSocket request failure.", t);
    }
  }
}
