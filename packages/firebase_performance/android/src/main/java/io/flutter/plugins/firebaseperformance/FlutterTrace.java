// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseperformance;

import com.google.firebase.perf.FirebasePerformance;
import com.google.firebase.perf.metrics.Trace;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

@SuppressWarnings("ConstantConditions")
public class FlutterTrace implements MethodChannel.MethodCallHandler {
  private final Trace trace;

  FlutterTrace(
      FirebasePerformance performance,
      BinaryMessenger messenger,
      MethodCall call,
      MethodChannel.Result result) {
    final String traceName = call.argument("traceName");
    final String channelName = call.argument("channelName");

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
        putMetric(call, result);
        break;
      case "Trace#incrementMetric":
        incrementMetric(call, result);
        break;
      case "Trace#getMetric":
        getMetric(call, result);
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
    trace.start();
    result.success(null);
  }

  private void stop(MethodChannel.Result result) {
    trace.stop();
    result.success(null);
  }

  private void putMetric(MethodCall call, MethodChannel.Result result) {
    final String name = call.argument("name");
    final Number value = call.argument("value");
    trace.putMetric(name, value.longValue());

    result.success(null);
  }

  private void incrementMetric(MethodCall call, MethodChannel.Result result) {
    final String name = call.argument("name");
    final Number value = call.argument("value");
    trace.incrementMetric(name, value.longValue());

    result.success(null);
  }

  private void getMetric(MethodCall call, MethodChannel.Result result) {
    final String name = call.argument("name");

    result.success(trace.getLongMetric(name));
  }

  private void putAttribute(MethodCall call, MethodChannel.Result result) {
    final String attribute = call.argument("attribute");
    final String value = call.argument("value");

    trace.putAttribute(attribute, value);

    result.success(null);
  }

  private void removeAttribute(MethodCall call, MethodChannel.Result result) {
    final String attribute = call.argument("attribute");
    trace.removeAttribute(attribute);

    result.success(null);
  }

  private void getAttributes(MethodChannel.Result result) {
    result.success(trace.getAttributes());
  }
}
