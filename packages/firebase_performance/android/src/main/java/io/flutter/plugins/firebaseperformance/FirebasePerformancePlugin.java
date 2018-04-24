package io.flutter.plugins.firebaseperformance;

import android.util.SparseArray;

import com.google.firebase.perf.FirebasePerformance;
import com.google.firebase.perf.metrics.Trace;

import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FirebasePerformancePlugin
 */
public class FirebasePerformancePlugin implements MethodCallHandler {
  private FirebasePerformance firebasePerformance;

  // Handles are ints used as indexes into the sparse array of active traces
  private int nextHandleTrace = 0;
  private final SparseArray<Trace> traces = new SparseArray<>();

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_performance");
    channel.setMethodCallHandler(new FirebasePerformancePlugin());
  }

  private FirebasePerformancePlugin() {
    firebasePerformance = FirebasePerformance.getInstance();
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "FirebasePerformance#isPerformanceCollectionEnabled":
        handleIsPerformanceCollectionEnabled(call, result);
        break;
      case "FirebasePerformance#setPerformanceCollectionEnabled":
        handleSetPerformanceCollectionEnabled(call, result);
        break;
      case "FirebasePerformance#newTrace":
        newTrace(call, result);
        break;
      case "Trace#start":
        traceStart(call, result);
        break;
      case "Trace#stop":
        traceStop(call, result);
        break;
      default:
        result.notImplemented();
    }
  }

  private void handleIsPerformanceCollectionEnabled(MethodCall call, Result result) {
    result.success(firebasePerformance.isPerformanceCollectionEnabled());
  }

  private void handleSetPerformanceCollectionEnabled(MethodCall call, Result result) {
    final boolean enabled = (boolean) call.arguments;
    firebasePerformance.setPerformanceCollectionEnabled(enabled);
    result.success(null);
  }

  private void newTrace(MethodCall call, Result result) {
    String name = (String) call.arguments;
    traces.put(nextHandleTrace, firebasePerformance.newTrace(name));

    result.success(nextHandleTrace++);
  }

  private void traceStart(MethodCall call, Result result) {
    int id = (int) call.arguments;
    Trace trace = traces.get(id);

    if (trace != null) {
      trace.start();
    }

    result.success(null);
  }

  private void traceStop(MethodCall call, Result result) {
    Map<String, Object> arguments = call.arguments();

    int id = (int) arguments.get("id");
    Trace trace = traces.get(id);

    if (trace == null) {
      result.success(null);
      return;
    }

    @SuppressWarnings("unchecked")
    Map<String, Integer> counters = (Map<String, Integer>) arguments.get("counters");
    for(Map.Entry<String, Integer> entry : counters.entrySet()) {
      trace.incrementCounter(entry.getKey(), entry.getValue());
    }

    @SuppressWarnings("unchecked")
    Map<String, String> attributes = (Map<String, String>) arguments.get("attributes");
    for(Map.Entry<String, String> entry : attributes.entrySet()) {
      trace.putAttribute(entry.getKey(), entry.getValue());
    }

    trace.stop();
    traces.remove(id);
    result.success(null);
  }
}
