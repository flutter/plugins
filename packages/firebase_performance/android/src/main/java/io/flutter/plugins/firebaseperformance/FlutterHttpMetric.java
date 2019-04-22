// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseperformance;

import com.google.firebase.perf.FirebasePerformance;
import com.google.firebase.perf.metrics.HttpMetric;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.util.Map;

@SuppressWarnings("ConstantConditions")
public class FlutterHttpMetric implements MethodChannel.MethodCallHandler {
  private final HttpMetric httpMetric;

  FlutterHttpMetric(
      FirebasePerformance performance,
      BinaryMessenger messenger,
      Object arguments,
      MethodChannel.Result result) {
    @SuppressWarnings("unchecked")
    final Map<String, Object> args = (Map<String, Object>) arguments;

    final String channelName = (String) args.get("channelName");
    final String url = (String) args.get("url");
    final String httpMethod = (String) args.get("httpMethod");

    this.httpMetric = performance.newHttpMetric(url, httpMethod);

    final MethodChannel channel = new MethodChannel(messenger, channelName);
    channel.setMethodCallHandler(this);

    result.success(null);
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
      case "HttpMetric#start":
        start(result);
        break;
      case "HttpMetric#stop":
        stop(call.arguments, result);
        break;
      case "PerformanceAttributes#putAttribute":
        putAttribute(call.arguments, result);
        break;
      case "PerformanceAttributes#removeAttribute":
        removeAttribute(call.arguments, result);
        break;
      case "PerformanceAttributes#getAttributes":
        getAttributes(result);
        break;
      default:
        result.notImplemented();
    }
  }

  private void start(MethodChannel.Result result) {
    httpMetric.start();
    result.success(null);
  }

  private void stop(Object arguments, MethodChannel.Result result) {
    @SuppressWarnings("unchecked")
    final Map<String, Object> args = (Map<String, Object>) arguments;

    final Integer httpResponseCode = (Integer) args.get("httpResponseCode");
    final Number requestPayloadSize = (Number) args.get("requestPayloadSize");
    final String responseContentType = (String) args.get("responseContentType");
    final Number responsePayloadSize = (Number) args.get("responsePayloadSize");

    if (requestPayloadSize != null) {
      httpMetric.setRequestPayloadSize(requestPayloadSize.longValue());
    }
    if (responsePayloadSize != null) {
      httpMetric.setResponsePayloadSize(responsePayloadSize.longValue());
    }

    if (httpResponseCode != null) httpMetric.setHttpResponseCode(httpResponseCode);
    if (responseContentType != null) httpMetric.setResponseContentType(responseContentType);

    httpMetric.stop();
    result.success(null);
  }

  private void putAttribute(Object arguments, MethodChannel.Result result) {
    @SuppressWarnings("unchecked")
    final Map<String, Object> args = (Map<String, Object>) arguments;

    final String attribute = (String) args.get("attribute");
    final String value = (String) args.get("value");

    httpMetric.putAttribute(attribute, value);

    result.success(null);
  }

  private void removeAttribute(Object arguments, MethodChannel.Result result) {
    @SuppressWarnings("unchecked")
    final Map<String, Object> args = (Map<String, Object>) arguments;

    final String attribute = (String) args.get("attribute");
    httpMetric.removeAttribute(attribute);

    result.success(null);
  }

  private void getAttributes(MethodChannel.Result result) {
    result.success(httpMetric.getAttributes());
  }
}
