// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseperformance;

import com.google.firebase.perf.FirebasePerformance;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class FlutterFirebasePerformance implements MethodChannel.MethodCallHandler {
  private final BinaryMessenger binaryMessenger;
  private final FirebasePerformance performance;

  static FlutterFirebasePerformance getInstance(BinaryMessenger messenger) {
    return new FlutterFirebasePerformance(messenger);
  }

  private FlutterFirebasePerformance(BinaryMessenger messenger) {
    this.binaryMessenger = messenger;
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

  private void setPerformanceCollectionEnabled(MethodCall call, MethodChannel.Result result) {
    final boolean enabled = (Boolean) call.arguments;
    performance.setPerformanceCollectionEnabled(enabled);
    result.success(null);
  }

  private void newTrace(MethodCall call, MethodChannel.Result result) {
    new FlutterTrace(performance, binaryMessenger, call, result);
  }

  private void newHttpMetric(MethodCall call, MethodChannel.Result result) {
    new FlutterHttpMetric(performance, binaryMessenger, call, result);
  }
}
