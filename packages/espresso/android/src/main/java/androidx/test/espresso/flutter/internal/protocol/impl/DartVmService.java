// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.internal.protocol.impl;

import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.base.Preconditions.checkState;
import static com.google.common.util.concurrent.Futures.transform;
import static com.google.common.util.concurrent.MoreExecutors.directExecutor;

import android.graphics.Rect;
import android.util.Log;
import androidx.test.espresso.flutter.api.FlutterTestingProtocol;
import androidx.test.espresso.flutter.api.SyntheticAction;
import androidx.test.espresso.flutter.api.WidgetMatcher;
import androidx.test.espresso.flutter.internal.idgenerator.IdGenerator;
import androidx.test.espresso.flutter.internal.jsonrpc.JsonRpcClient;
import androidx.test.espresso.flutter.internal.jsonrpc.message.JsonRpcRequest;
import androidx.test.espresso.flutter.internal.jsonrpc.message.JsonRpcResponse;
import androidx.test.espresso.flutter.internal.protocol.impl.GetOffsetAction.OffsetType;
import androidx.test.espresso.flutter.model.WidgetInfo;
import com.google.common.annotations.VisibleForTesting;
import com.google.common.base.Function;
import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.ListenableFuture;
import com.google.common.util.concurrent.ListeningExecutorService;
import com.google.common.util.concurrent.MoreExecutors;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Future;
import javax.annotation.Nonnull;
import javax.annotation.Nullable;

/**
 * An implementation of the Espresso-Flutter testing protocol by using the testing APIs exposed by
 * Dart VM service protocol.
 *
 * @see <a href="https://github.com/dart-lang/sdk/blob/master/runtime/vm/service/service.md">Dart VM
 *     Service Protocol</a>.
 */
public final class DartVmService implements FlutterTestingProtocol {

  private static final String TAG = DartVmService.class.getSimpleName();

  private static final Gson gson =
      new GsonBuilder().excludeFieldsWithoutExposeAnnotation().create();

  /** Prefix to be attached to the JSON-RPC message id. */
  private static final String MESSAGE_ID_PREFIX = "message-";

  /** The JSON-RPC method for testing extension APIs. */
  private static final String TESTING_EXTENSION_METHOD = "ext.flutter.driver";
  /** The JSON-RPC method for retrieving Dart isolate info. */
  private static final String GET_ISOLATE_METHOD = "getIsolate";
  /** The JSON-RPC method for retrieving Dart VM info. */
  private static final String GET_VM_METHOD = "getVM";

  /** Json property name for the Dart VM isolate id. */
  private static final String ISOLATE_ID_TAG = "isolateId";

  private final JsonRpcClient client;
  private final IdGenerator<Integer> messageIdGenerator;
  private final String isolateId;
  private final ListeningExecutorService taskExecutor;

  /**
   * Constructs a {@code DartVmService} instance that can be used to talk to the testing protocol
   * exposed by Dart VM service extension protocol. It uses the given {@code isolateId} in all the
   * JSON-RPC requests. It waits until the service extension protocol is in a usable state before
   * returning.
   *
   * @param isolateId the Dart isolate ID to be used in the JSON-RPC requests sent to Dart VM
   *     service protocol.
   * @param jsonRpcClient a JSON-RPC web socket connection to send requests to the Dart VM service
   *     protocol.
   * @param messageIdGenerator an ID generator for generating the JSON-RPC request IDs.
   * @param taskExecutor an executor for running async tasks.
   */
  public DartVmService(
      String isolateId,
      JsonRpcClient jsonRpcClient,
      IdGenerator<Integer> messageIdGenerator,
      ExecutorService taskExecutor) {
    this.isolateId =
        checkNotNull(
            isolateId, "The ID of the Dart isolate that draws the Flutter UI shouldn't be null.");
    this.client =
        checkNotNull(
            jsonRpcClient,
            "The JsonRpcClient used to talk to Dart VM service protocol shouldn't be null.");
    this.messageIdGenerator =
        checkNotNull(
            messageIdGenerator, "The id generator for generating request IDs shouldn't be null.");
    this.taskExecutor = MoreExecutors.listeningDecorator(checkNotNull(taskExecutor));
  }

  /**
   * {@inheritDoc}
   *
   * <p>This method ensures the Dart VM service is ready for use by checking:
   *
   * <ul>
   *   <li>Dart VM Observatory is up and running.
   *   <li>The Flutter testing API is registered with the running Dart VM service protocol.
   * </ul>
   */
  @Override
  @SuppressWarnings("unchecked")
  public Future<Void> connect() {
    return (Future<Void>) taskExecutor.submit(new IsDartVmServiceReady(isolateId, this));
  }

  @Override
  public Future<Void> perform(
      @Nullable final WidgetMatcher widgetMatcher, final SyntheticAction action) {
    // Assumes all the actions require a response.
    ListenableFuture<JsonRpcResponse> responseFuture =
        client.request(getActionRequest(widgetMatcher, action));
    Function<JsonRpcResponse, Void> resultTransformFunc =
        new Function<JsonRpcResponse, Void>() {
          public Void apply(JsonRpcResponse response) {
            if (response.getError() == null) {
              return null;
            } else {
              // TODO(https://github.com/android/android-test/issues/251): Update error case handling
              // like
              // AmbiguousWidgetMatcherException, NoMatchingWidgetException after nailing down the
              // design with
              // Flutter team.
              throw new RuntimeException(
                  String.format(
                      "Error occurred when performing the given action %s on widget matched %s",
                      action, widgetMatcher));
            }
          }
        };
    return transform(responseFuture, resultTransformFunc, directExecutor());
  }

  @Override
  public Future<WidgetInfo> matchWidget(@Nonnull WidgetMatcher widgetMatcher) {
    JsonRpcRequest request = getActionRequest(widgetMatcher, new GetWidgetDiagnosticsAction());
    ListenableFuture<JsonRpcResponse> jsonResponseFuture = client.request(request);

    Function<JsonRpcResponse, WidgetInfo> widgetInfoTransformer =
        new Function<JsonRpcResponse, WidgetInfo>() {
          public WidgetInfo apply(JsonRpcResponse jsonResponse) {
            GetWidgetDiagnosticsResponse widgetDiagnostics =
                GetWidgetDiagnosticsResponse.fromJsonRpcResponse(jsonResponse);
            return WidgetInfoFactory.createWidgetInfo(widgetDiagnostics);
          }
        };
    return transform(jsonResponseFuture, widgetInfoTransformer, directExecutor());
  }

  @Override
  public Future<Rect> getLocalRect(@Nonnull WidgetMatcher widgetMatcher) {
    ListenableFuture<JsonRpcResponse> topLeftFuture =
        client.request(getActionRequest(widgetMatcher, new GetOffsetAction(OffsetType.TOP_LEFT)));
    ListenableFuture<JsonRpcResponse> bottomRightFuture =
        client.request(
            getActionRequest(widgetMatcher, new GetOffsetAction(OffsetType.BOTTOM_RIGHT)));
    ListenableFuture<List<JsonRpcResponse>> responses =
        Futures.allAsList(topLeftFuture, bottomRightFuture);
    Function<List<JsonRpcResponse>, Rect> rectTransformer =
        new Function<List<JsonRpcResponse>, Rect>() {
          public Rect apply(List<JsonRpcResponse> jsonResponses) {
            GetOffsetResponse topLeft = GetOffsetResponse.fromJsonRpcResponse(jsonResponses.get(0));
            GetOffsetResponse bottomRight =
                GetOffsetResponse.fromJsonRpcResponse(jsonResponses.get(1));
            checkState(
                topLeft.getX() >= 0 && topLeft.getY() >= 0,
                String.format(
                    "The relative coordinates [%.1f, %.1f] of a widget's top left vertex cannot be"
                        + " negative (negative means it's off the outer Flutter view)!",
                    topLeft.getX(), topLeft.getY()));
            checkState(
                bottomRight.getX() >= 0 && bottomRight.getY() >= 0,
                String.format(
                    "The relative coordinates [%.1f, %.1f] of a widget's bottom right vertex cannot"
                        + " be negative (negative means it's off the outer Flutter view)!",
                    bottomRight.getX(), bottomRight.getY()));
            checkState(
                topLeft.getX() <= bottomRight.getX() && topLeft.getY() <= bottomRight.getY(),
                String.format(
                    "The coordinates of the bottom right vertex [%.1f, %.1f] are not actually to the"
                        + " bottom right of the top left vertex [%.1f, %.1f]!",
                    topLeft.getX(), topLeft.getY(), bottomRight.getX(), bottomRight.getY()));
            return new Rect(
                (int) topLeft.getX(),
                (int) topLeft.getY(),
                (int) bottomRight.getX(),
                (int) bottomRight.getY());
          }
        };
    return transform(responses, rectTransformer, directExecutor());
  }

  @Override
  public Future<Void> waitUntilIdle() {
    return perform(
        null,
        new WaitForConditionAction(
            new NoPendingPlatformMessagesCondition(),
            new NoTransientCallbacksCondition(),
            new NoPendingFrameCondition()));
  }

  @Override
  public void close() {
    if (client != null) {
      client.disconnect();
    }
  }

  /** Queries the Dart isolate information. */
  public ListenableFuture<JsonRpcResponse> getIsolateInfo() {
    JsonRpcRequest getIsolateReq =
        new JsonRpcRequest.Builder(GET_ISOLATE_METHOD)
            .setId(getNextMessageId())
            .addParam(ISOLATE_ID_TAG, isolateId)
            .build();
    return client.request(getIsolateReq);
  }

  /** Queries the Dart VM information. */
  public ListenableFuture<GetVmResponse> getVmInfo() {
    JsonRpcRequest getVmReq =
        new JsonRpcRequest.Builder(GET_VM_METHOD).setId(getNextMessageId()).build();
    ListenableFuture<JsonRpcResponse> jsonGetVmResp = client.request(getVmReq);
    Function<JsonRpcResponse, GetVmResponse> jsonToResponse =
        new Function<JsonRpcResponse, GetVmResponse>() {
          public GetVmResponse apply(JsonRpcResponse jsonResp) {
            return GetVmResponse.fromJsonRpcResponse(jsonResp);
          }
        };
    return transform(jsonGetVmResp, jsonToResponse, directExecutor());
  }

  /** Gets the next usable message id. */
  private String getNextMessageId() {
    return MESSAGE_ID_PREFIX + messageIdGenerator.next();
  }

  /** Constructs a {@code JsonRpcRequest} based on the given matcher and action. */
  private JsonRpcRequest getActionRequest(WidgetMatcher widgetMatcher, SyntheticAction action) {
    checkNotNull(action, "Action cannot be null.");
    // Assumes all the actions require a response.
    return new JsonRpcRequest.Builder(TESTING_EXTENSION_METHOD)
        .setId(getNextMessageId())
        .setParams(constructParams(isolateId, widgetMatcher, action))
        .build();
  }

  /** Constructs the JSON-RPC request params. */
  private static JsonObject constructParams(
      String isolateId, WidgetMatcher widgetMatcher, SyntheticAction action) {
    JsonObject paramObject = new JsonObject();
    paramObject.addProperty(ISOLATE_ID_TAG, isolateId);
    if (widgetMatcher != null) {
      paramObject = merge(paramObject, (JsonObject) gson.toJsonTree(widgetMatcher));
    }
    paramObject = merge(paramObject, (JsonObject) gson.toJsonTree(action));
    return paramObject;
  }

  /**
   * Returns a merged {@code JsonObject} of the two given {@code JsonObject}s, or an empty {@code
   * JsonObject} if both of the objects to be merged are null.
   */
  private static JsonObject merge(@Nullable JsonObject obj1, @Nullable JsonObject obj2) {
    JsonObject result = new JsonObject();
    mergeTo(result, obj1);
    mergeTo(result, obj2);
    return result;
  }

  private static void mergeTo(JsonObject obj, @Nullable JsonObject toBeMerged) {
    if (toBeMerged != null) {
      for (Map.Entry<String, JsonElement> entry : toBeMerged.entrySet()) {
        obj.add(entry.getKey(), entry.getValue());
      }
    }
  }

  /** A {@link Runnable} that waits until the Dart VM testing extension is ready for use. */
  static class IsDartVmServiceReady implements Runnable {

    /** Maximum number of retries for checking extension APIs' availability. */
    private static final int EXTENSION_API_CHECKING_RETRIES = 5;

    /** Json param name for retrieving all the available extension APIs. */
    private static final String EXTENSION_RPCS_TAG = "extensionRPCs";

    private final String isolateId;
    private final DartVmService dartVmService;

    IsDartVmServiceReady(String isolateId, DartVmService dartVmService) {
      this.isolateId = checkNotNull(isolateId);
      this.dartVmService = checkNotNull(dartVmService);
    }

    @Override
    public void run() {
      waitForTestingApiRegistered();
    }

    /**
     * Blocks until the Flutter testing/driver API is registered with the running Dart VM service
     * protocol by querying whether it's listed in the isolate's 'extensionRPCs'.
     */
    @VisibleForTesting
    void waitForTestingApiRegistered() {
      int retries = EXTENSION_API_CHECKING_RETRIES;
      boolean isApiRegistered = false;
      do {
        retries--;
        try {
          JsonRpcResponse isolateResp = dartVmService.getIsolateInfo().get();
          isApiRegistered = isTestingApiRegistered(isolateResp);
        } catch (ExecutionException e) {
          Log.d(
              TAG,
              "Error occurred during retrieving Dart isolate information. Retry.",
              e.getCause());
          continue;
        } catch (InterruptedException e) {
          Log.d(
              TAG,
              "InterruptedException occurred during retrieving Dart isolate information. Retry.",
              e);
          Thread.currentThread().interrupt(); // Restores the interrupted status.
          continue;
        }
      } while (!isApiRegistered && retries > 0);

      if (!isApiRegistered) {
        throw new FlutterProtocolException(
            String.format("Flutter testing APIs not registered with Dart isolate %s.", isolateId));
      }
    }

    @VisibleForTesting
    boolean isTestingApiRegistered(JsonRpcResponse isolateInfoResp) {
      if (isolateInfoResp == null
          || isolateInfoResp.getError() != null
          || isolateInfoResp.getResult() == null) {
        Log.w(
            TAG,
            String.format(
                "Error occurred in JSON-RPC response when querying isolate info for %s: %s.",
                isolateId, isolateInfoResp.getError()));
        return false;
      }
      Iterator<JsonElement> extensions =
          isolateInfoResp.getResult().get(EXTENSION_RPCS_TAG).getAsJsonArray().iterator();
      while (extensions.hasNext()) {
        String extensionApi = extensions.next().getAsString();
        if (TESTING_EXTENSION_METHOD.equals(extensionApi)) {
          Log.d(
              TAG,
              String.format("Flutter testing API registered with Dart isolate %s.", isolateId));
          return true;
        }
      }
      return false;
    }
  }
}
