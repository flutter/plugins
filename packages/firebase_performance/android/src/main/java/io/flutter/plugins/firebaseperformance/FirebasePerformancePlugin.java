// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseperformance;

import android.util.SparseArray;
import com.google.firebase.perf.FirebasePerformance;
import com.google.firebase.perf.metrics.HttpMetric;
import com.google.firebase.perf.metrics.Trace;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.Map;

/** FirebasePerformancePlugin */
public class FirebasePerformancePlugin implements MethodCallHandler {
  private FirebasePerformance firebasePerformance;

  private final SparseArray<Trace> traces = new SparseArray<>();
  private final SparseArray<HttpMetric> httpMetrics = new SparseArray<>();

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_performance");
    channel.setMethodCallHandler(new FirebasePerformancePlugin());
  }

  private FirebasePerformancePlugin() {
    firebasePerformance = FirebasePerformance.getInstance();
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "FirebasePerformance#isPerformanceCollectionEnabled":
        result.success(firebasePerformance.isPerformanceCollectionEnabled());
        break;
      case "FirebasePerformance#setPerformanceCollectionEnabled":
        final boolean enabled = (boolean) call.arguments;
        firebasePerformance.setPerformanceCollectionEnabled(enabled);
        result.success(null);
        break;
      case "Trace#start":
        handleTraceStart(call, result);
        break;
      case "Trace#stop":
        handleTraceStop(call, result);
        break;
      case "HttpMetric#start":
        handleHttpMetricStart(call, result);
        break;
      case "HttpMetric#stop":
        handleHttpMetricStop(call, result);
        break;
      default:
        result.notImplemented();
    }
  }

  private void handleTraceStart(MethodCall call, Result result) {
    Map<String, Object> arguments = call.arguments();

    int handle = (int) arguments.get("handle");
    String name = (String) arguments.get("name");

    Trace trace = firebasePerformance.newTrace(name);

    traces.put(handle, trace);

    trace.start();
    result.success(null);
  }

  private void handleTraceStop(MethodCall call, Result result) {
    Map<String, Object> arguments = call.arguments();

    int handle = (int) arguments.get("handle");
    Trace trace = traces.get(handle);

    @SuppressWarnings("unchecked")
    Map<String, Integer> counters = (Map<String, Integer>) arguments.get("counters");
    for (Map.Entry<String, Integer> entry : counters.entrySet()) {
      trace.incrementCounter(entry.getKey(), entry.getValue());
    }

    @SuppressWarnings("unchecked")
    Map<String, String> attributes = (Map<String, String>) arguments.get("attributes");
    for (Map.Entry<String, String> entry : attributes.entrySet()) {
      trace.putAttribute(entry.getKey(), entry.getValue());
    }

    trace.stop();
    traces.remove(handle);
    result.success(null);
  }

  private void handleHttpMetricStart(MethodCall call, Result result) {
    Map<String, Object> arguments = call.arguments();

    int handle = (int) arguments.get("handle");
    String url = (String) arguments.get("url");

    int httpMethod = (int) arguments.get("httpMethod");
    String httpMethodStr;
    switch (httpMethod) {
      case 0:
        httpMethodStr = FirebasePerformance.HttpMethod.CONNECT;
        break;
      case 1:
        httpMethodStr = FirebasePerformance.HttpMethod.DELETE;
        break;
      case 2:
        httpMethodStr = FirebasePerformance.HttpMethod.GET;
        break;
      case 3:
        httpMethodStr = FirebasePerformance.HttpMethod.HEAD;
        break;
      case 4:
        httpMethodStr = FirebasePerformance.HttpMethod.OPTIONS;
        break;
      case 5:
        httpMethodStr = FirebasePerformance.HttpMethod.PATCH;
        break;
      case 6:
        httpMethodStr = FirebasePerformance.HttpMethod.POST;
        break;
      case 7:
        httpMethodStr = FirebasePerformance.HttpMethod.PUT;
        break;
      case 8:
        httpMethodStr = FirebasePerformance.HttpMethod.TRACE;
        break;
      default:
        httpMethodStr = null;
        break;
    }

    HttpMetric metric = firebasePerformance.newHttpMetric(url, httpMethodStr);

    httpMetrics.put(handle, metric);

    metric.start();
    result.success(null);
  }

  private void handleHttpMetricStop(MethodCall call, Result result) {
    Map<String, Object> arguments = call.arguments();

    int handle = (int) arguments.get("handle");
    HttpMetric metric = httpMetrics.get(handle);

    Object httpResponseCode = arguments.get("httpResponseCode");
    Object requestPayloadSize = arguments.get("requestPayloadSize");
    Object responseContentType = arguments.get("responseContentType");
    Object responsePayloadSize = arguments.get("responsePayloadSize");

    if (requestPayloadSize != null) {
      if (requestPayloadSize instanceof Integer) {
        metric.setRequestPayloadSize((int) requestPayloadSize);
      } else {
        metric.setRequestPayloadSize((long) requestPayloadSize);
      }
    }

    if (httpResponseCode != null) metric.setHttpResponseCode((int) httpResponseCode);
    if (responseContentType != null) metric.setResponseContentType((String) responseContentType);
    if (responsePayloadSize != null) {
      if (responsePayloadSize instanceof Integer) {
        metric.setResponsePayloadSize((int) responsePayloadSize);
      } else {
        metric.setResponsePayloadSize((long) responsePayloadSize);
      }
    }

    @SuppressWarnings("unchecked")
    Map<String, String> attributes = (Map<String, String>) arguments.get("attributes");
    for (Map.Entry<String, String> entry : attributes.entrySet()) {
      metric.putAttribute(entry.getKey(), entry.getValue());
    }

    metric.stop();
    httpMetrics.remove(handle);
    result.success(null);
  }
}
