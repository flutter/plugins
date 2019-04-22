// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseperformance;

import com.google.firebase.perf.FirebasePerformance;
import com.google.firebase.perf.metrics.Trace;
import java.util.Map;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class FlutterTrace implements MethodChannel.MethodCallHandler {
  private final Trace trace;

  FlutterTrace(
      FirebasePerformance performance,
      BinaryMessenger messenger,
      Object arguments,
      MethodChannel.Result result) {
    @SuppressWarnings("unchecked")
    final Map<String, Object> args = (Map<String, Object>) arguments;

    final String traceName = (String) args.get("traceName");
    final String channelName = (String) args.get("channelName");

    this.trace = performance.newTrace(traceName);

    final MethodChannel channel = new MethodChannel(messenger, channelName);
    channel.setMethodCallHandler(this);

    result.success(null);
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
      case "Trace#start":
        start(result);
        break;
      case "Trace#stop":
        stop(result);
        break;
      case "Trace#putMetric":
        putMetric(call.arguments, result);
        break;
      case "Trace#incrementMetric":
        incrementMetric(call.arguments, result);
        break;
      case "Trace#getMetric":
        getMetric(call.arguments, result);
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
    trace.start();
    result.success(null);
  }

  private void stop(MethodChannel.Result result) {
    trace.stop();
    result.success(null);
  }

  private void putMetric(Object arguments, MethodChannel.Result result) {
    @SuppressWarnings("unchecked")
    final Map<String, Object> args = (Map<String, Object>) arguments;

    final String name = (String) args.get("name");
    final Number value = (Number) args.get("value");
    trace.putMetric(name, value.longValue());

    result.success(null);
  }

  private void incrementMetric(Object arguments, MethodChannel.Result result) {
    @SuppressWarnings("unchecked")
    final Map<String, Object> args = (Map<String, Object>) arguments;

    final String name = (String) args.get("name");
    final Number value = (Number) args.get("value");
    trace.incrementMetric(name, value.longValue());

    result.success(null);
  }

  private void getMetric(Object arguments, MethodChannel.Result result) {
    @SuppressWarnings("unchecked")
    final Map<String, Object> args = (Map<String, Object>) arguments;

    final String name = (String) args.get("name");

    result.success(trace.getLongMetric(name));
  }

  private void putAttribute(Object arguments, MethodChannel.Result result) {
    @SuppressWarnings("unchecked")
    final Map<String, Object> args = (Map<String, Object>) arguments;

    final String attribute = (String) args.get("attribute");
    final String value = (String) args.get("value");

    trace.putAttribute(attribute, value);

    result.success(null);
  }

  private void removeAttribute(Object arguments, MethodChannel.Result result) {
    @SuppressWarnings("unchecked")
    final Map<String, Object> args = (Map<String, Object>) arguments;

    final String attribute = (String) args.get("attribute");
    trace.removeAttribute(attribute);

    result.success(null);
  }

  private void getAttributes(MethodChannel.Result result) {
    result.success(trace.getAttributes());
  }
}
