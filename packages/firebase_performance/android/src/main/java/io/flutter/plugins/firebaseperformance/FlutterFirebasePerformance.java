package io.flutter.plugins.firebaseperformance;

import com.google.firebase.perf.FirebasePerformance;
import com.google.firebase.perf.metrics.HttpMetric;
import com.google.firebase.perf.metrics.Trace;
import io.flutter.plugin.common.MethodCall;
import java.lang.Object;
import java.lang.Override;
import java.lang.String;

final class FlutterFirebasePerformance implements FlutterWrapper {
  private final String handle;

  public final FirebasePerformance firebaseperformance;

  FlutterFirebasePerformance(String handle, FirebasePerformance firebaseperformance) {
    this.handle = handle;
    this.firebaseperformance = firebaseperformance;
    FirebasePerformancePlugin.addInvokerWrapper(handle, this);
  }

  static Object onStaticMethodCall(MethodCall call) {
    switch(call.method) {
      case "FirebasePerformance#getInstance":
        return getInstance(call);
      case "FirebasePerformance#startTrace":
        return startTrace(call);
      default:
        return new FlutterWrapper.MethodNotImplemented();
    }
  }

  @Override
  public Object onMethodCall(MethodCall call) {
    switch(call.method) {
      case "FirebasePerformance#isPerformanceCollectionEnabled":
        return isPerformanceCollectionEnabled();
      case "FirebasePerformance#newHttpMetric":
        return newHttpMetric(call);
      case "FirebasePerformance#newTrace":
        return newTrace(call);
      case "FirebasePerformance#setPerformanceCollectionEnabled":
        return setPerformanceCollectionEnabled(call);
      default:
        return new FlutterWrapper.MethodNotImplemented();
    }
  }

  private static Object getInstance(final MethodCall call) {
    final String handle = call.argument("__createdObjectHandle");
    final FirebasePerformance value = FirebasePerformance.getInstance();
    new FlutterFirebasePerformance(handle, value);
    return null;
  }

  private Object isPerformanceCollectionEnabled() {
    return firebaseperformance.isPerformanceCollectionEnabled();
  }

  private Object newHttpMetric(final MethodCall call) {
    final String url = call.argument("url");
    final String httpMethod = call.argument("httpMethod");
    final String handle = call.argument("__createdObjectHandle");
    final HttpMetric value = firebaseperformance.newHttpMetric(url, httpMethod);
    new FlutterHttpMetric(handle, value);
    return null;
  }

  private Object newTrace(final MethodCall call) {
    final String traceName = call.argument("traceName");
    final String handle = call.argument("__createdObjectHandle");
    final Trace value = firebaseperformance.newTrace(traceName);
    new FlutterTrace(handle, value);
    return null;
  }

  private Object setPerformanceCollectionEnabled(final MethodCall call) {
    final Boolean enable = call.argument("enable");
    firebaseperformance.setPerformanceCollectionEnabled(enable);
    return null;
  }

  private static Object startTrace(final MethodCall call) {
    final String traceName = call.argument("traceName");
    final String handle = call.argument("__createdObjectHandle");
    final Trace value = FirebasePerformance.startTrace(traceName);
    new FlutterTrace(handle, value);
    return null;
  }
}
