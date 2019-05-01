// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseperformance;

import com.google.firebase.perf.FirebasePerformance;
import com.google.firebase.perf.metrics.HttpMetric;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

@SuppressWarnings("ConstantConditions")
public class FlutterHttpMetric implements MethodChannel.MethodCallHandler {
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

  private final HttpMetric httpMetric;
  private final MethodChannel channel;

  FlutterHttpMetric(
      FirebasePerformance performance,
      BinaryMessenger messenger,
      MethodCall call,
      MethodChannel.Result result) {
    final String channelName = call.argument("channelName");
    final String url = call.argument("url");
    final String httpMethod = call.argument("httpMethod");

    this.httpMetric = performance.newHttpMetric(url, parseHttpMethod(httpMethod));

    this.channel = new MethodChannel(messenger, channelName);
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
        stop(result);
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

  private void stop(MethodChannel.Result result) {
    httpMetric.stop();
    channel.setMethodCallHandler(null);
    result.success(null);
  }

  private void setHttpResponseCode(MethodCall call, MethodChannel.Result result) {
    final Integer httpResponseCode = call.argument("httpResponseCode");
    httpMetric.setHttpResponseCode(httpResponseCode);
    result.success(null);
  }

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

  private void setResponsePayloadSize(MethodCall call, MethodChannel.Result result) {
    final Number payloadSize = call.argument("responsePayloadSize");
    httpMetric.setResponsePayloadSize(payloadSize.longValue());
    result.success(null);
  }

  private void putAttribute(MethodCall call, MethodChannel.Result result) {
    final String attribute = call.argument("attribute");
    final String value = call.argument("value");

    httpMetric.putAttribute(attribute, value);

    result.success(null);
  }

  private void removeAttribute(MethodCall call, MethodChannel.Result result) {
    final String attribute = call.argument("attribute");
    httpMetric.removeAttribute(attribute);

    result.success(null);
  }

  private void getAttributes(MethodChannel.Result result) {
    result.success(httpMetric.getAttributes());
  }
}
