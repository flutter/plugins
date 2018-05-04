// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseperformance;

import android.util.SparseArray;
import com.google.firebase.perf.FirebasePerformance;
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
}
