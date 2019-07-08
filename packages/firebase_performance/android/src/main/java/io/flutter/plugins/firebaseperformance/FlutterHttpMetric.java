// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseperformance;

import com.google.firebase.perf.metrics.HttpMetric;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class FlutterHttpMetric implements MethodChannel.MethodCallHandler {
  private final HttpMetric httpMetric;

  FlutterHttpMetric(final HttpMetric metric) {
    this.httpMetric = metric;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
      case "HttpMetric#start":
        start(result);
        break;
      case "HttpMetric#stop":
        stop(call, result);
        break;
      case "HttpMetric#httpResponseCode":
        setHttpResponseCode(call, result);
        break;
      case "HttpMetric#requestPayloadSize":
        setRequestPayloadSize(call, result);
        break;
      case "HttpMetric#responseContentType":
        setResponseContentType(call, result);
        break;
      case "HttpMetric#responsePayloadSize":
        setResponsePayloadSize(call, result);
        break;
      case "PerformanceAttributes#putAttribute":
        putAttribute(call, result);
        break;
      case "PerformanceAttributes#removeAttribute":
        removeAttribute(call, result);
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

  @SuppressWarnings("ConstantConditions")
  private void stop(MethodCall call, MethodChannel.Result result) {
    httpMetric.stop();

    final Integer handle = call.argument("handle");
    FirebasePerformancePlugin.removeHandler(handle);

    result.success(null);
  }

  @SuppressWarnings("ConstantConditions")
  private void setHttpResponseCode(MethodCall call, MethodChannel.Result result) {
    final Integer httpResponseCode = call.argument("httpResponseCode");
    httpMetric.setHttpResponseCode(httpResponseCode);
    result.success(null);
  }

  @SuppressWarnings("ConstantConditions")
  private void setRequestPayloadSize(MethodCall call, MethodChannel.Result result) {
    final Number payloadSize = call.argument("requestPayloadSize");
    httpMetric.setRequestPayloadSize(payloadSize.longValue());
    result.success(null);
  }

  private void setResponseContentType(MethodCall call, MethodChannel.Result result) {
    final String contentType = call.argument("responseContentType");
    httpMetric.setResponseContentType(contentType);
    result.success(null);
  }

  @SuppressWarnings("ConstantConditions")
  private void setResponsePayloadSize(MethodCall call, MethodChannel.Result result) {
    final Number payloadSize = call.argument("responsePayloadSize");
    httpMetric.setResponsePayloadSize(payloadSize.longValue());
    result.success(null);
  }

  @SuppressWarnings("ConstantConditions")
  private void putAttribute(MethodCall call, MethodChannel.Result result) {
    final String name = call.argument("name");
    final String value = call.argument("value");

    httpMetric.putAttribute(name, value);

    result.success(null);
  }

  @SuppressWarnings("ConstantConditions")
  private void removeAttribute(MethodCall call, MethodChannel.Result result) {
    final String name = call.argument("name");
    httpMetric.removeAttribute(name);

    result.success(null);
  }

  private void getAttributes(MethodChannel.Result result) {
    result.success(httpMetric.getAttributes());
  }
}
