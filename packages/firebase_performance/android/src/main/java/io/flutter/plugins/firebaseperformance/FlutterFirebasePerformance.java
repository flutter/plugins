// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseperformance;

import com.google.firebase.perf.FirebasePerformance;
import com.google.firebase.perf.metrics.HttpMetric;
import com.google.firebase.perf.metrics.Trace;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class FlutterFirebasePerformance implements MethodChannel.MethodCallHandler {
  private static String parseHttpMethod(String httpMethod) {
    switch (httpMethod) {
      case "HttpMethod.Connect":
        return FirebasePerformance.HttpMethod.CONNECT;
      case "HttpMethod.Delete":
        return FirebasePerformance.HttpMethod.DELETE;
      case "HttpMethod.Get":
        return FirebasePerformance.HttpMethod.GET;
      case "HttpMethod.Head":
        return FirebasePerformance.HttpMethod.HEAD;
      case "HttpMethod.Options":
        return FirebasePerformance.HttpMethod.OPTIONS;
      case "HttpMethod.Patch":
        return FirebasePerformance.HttpMethod.PATCH;
      case "HttpMethod.Post":
        return FirebasePerformance.HttpMethod.POST;
      case "HttpMethod.Put":
        return FirebasePerformance.HttpMethod.PUT;
      case "HttpMethod.Trace":
        return FirebasePerformance.HttpMethod.TRACE;
      default:
        throw new IllegalArgumentException(String.format("No HttpMethod for: %s", httpMethod));
    }
  }

  private final FirebasePerformance performance;

  @SuppressWarnings("ConstantConditions")
  static void getInstance(MethodCall call, MethodChannel.Result result) {
    final Integer handle = call.argument("handle");
    FirebasePerformancePlugin.addHandler(handle, new FlutterFirebasePerformance());
    result.success(null);
  }

  private FlutterFirebasePerformance() {
    this.performance = FirebasePerformance.getInstance();
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
      case "FirebasePerformance#isPerformanceCollectionEnabled":
        isPerformanceCollectionEnabled(result);
        break;
      case "FirebasePerformance#setPerformanceCollectionEnabled":
        setPerformanceCollectionEnabled(call, result);
        break;
      case "FirebasePerformance#newTrace":
        newTrace(call, result);
        break;
      case "FirebasePerformance#newHttpMetric":
        newHttpMetric(call, result);
        break;
      default:
        result.notImplemented();
    }
  }

  private void isPerformanceCollectionEnabled(MethodChannel.Result result) {
    result.success(performance.isPerformanceCollectionEnabled());
  }

  @SuppressWarnings("ConstantConditions")
  private void setPerformanceCollectionEnabled(MethodCall call, MethodChannel.Result result) {
    final Boolean enable = call.argument("enable");
    performance.setPerformanceCollectionEnabled(enable);

    result.success(null);
  }

  @SuppressWarnings("ConstantConditions")
  private void newTrace(MethodCall call, MethodChannel.Result result) {
    final String name = call.argument("name");
    final Trace trace = performance.newTrace(name);

    final Integer handle = call.argument("traceHandle");
    FirebasePerformancePlugin.addHandler(handle, new FlutterTrace(trace));

    result.success(null);
  }

  @SuppressWarnings("ConstantConditions")
  private void newHttpMetric(MethodCall call, MethodChannel.Result result) {
    final String url = call.argument("url");
    final String httpMethod = call.argument("httpMethod");

    final HttpMetric metric = performance.newHttpMetric(url, parseHttpMethod(httpMethod));

    final Integer handle = call.argument("httpMetricHandle");
    FirebasePerformancePlugin.addHandler(handle, new FlutterHttpMetric(metric));

    result.success(null);
  }
}
