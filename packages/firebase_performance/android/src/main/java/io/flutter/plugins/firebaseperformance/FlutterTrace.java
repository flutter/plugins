// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseperformance;

import com.google.firebase.perf.metrics.Trace;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class FlutterTrace implements MethodChannel.MethodCallHandler {
  private final Trace trace;

  FlutterTrace(final Trace trace) {
    this.trace = trace;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
      case "Trace#start":
        start(result);
        break;
      case "Trace#stop":
        stop(call, result);
        break;
      case "Trace#setMetric":
        setMetric(call, result);
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

  @SuppressWarnings("ConstantConditions")
  private void stop(MethodCall call, MethodChannel.Result result) {
    trace.stop();

    final Integer handle = call.argument("handle");
    FirebasePerformancePlugin.removeHandler(handle);

    result.success(null);
  }

  @SuppressWarnings("ConstantConditions")
  private void setMetric(MethodCall call, MethodChannel.Result result) {
    final String name = call.argument("name");
    final Number value = call.argument("value");
    trace.putMetric(name, value.longValue());

    result.success(null);
  }

  @SuppressWarnings("ConstantConditions")
  private void incrementMetric(MethodCall call, MethodChannel.Result result) {
    final String name = call.argument("name");
    final Number value = call.argument("value");
    trace.incrementMetric(name, value.longValue());

    result.success(null);
  }

  @SuppressWarnings("ConstantConditions")
  private void getMetric(MethodCall call, MethodChannel.Result result) {
    final String name = call.argument("name");

    result.success(trace.getLongMetric(name));
  }

  @SuppressWarnings("ConstantConditions")
  private void putAttribute(MethodCall call, MethodChannel.Result result) {
    final String name = call.argument("name");
    final String value = call.argument("value");

    trace.putAttribute(name, value);

    result.success(null);
  }

  @SuppressWarnings("ConstantConditions")
  private void removeAttribute(MethodCall call, MethodChannel.Result result) {
    final String name = call.argument("name");
    trace.removeAttribute(name);

    result.success(null);
  }

  private void getAttributes(MethodChannel.Result result) {
    result.success(trace.getAttributes());
  }
}
