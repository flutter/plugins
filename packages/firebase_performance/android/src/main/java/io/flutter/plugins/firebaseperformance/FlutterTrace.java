package io.flutter.plugins.firebaseperformance;

import com.google.firebase.perf.metrics.Trace;
import io.flutter.plugin.common.MethodCall;
import java.lang.Object;
import java.lang.Override;
import java.lang.String;

final class FlutterTrace implements FlutterWrapper {
  private final String handle;

  public final Trace trace;

  FlutterTrace(String handle, Trace trace) {
    this.handle = handle;
    this.trace = trace;
    FirebasePerformancePlugin.addInvokerWrapper(handle, this);
  }

  @Override
  public Object onMethodCall(MethodCall call) {
    switch(call.method) {
      case "Trace#describeContents":
        return describeContents();
      case "Trace#getAttribute":
        return getAttribute(call);
      case "Trace#getAttributes":
        return getAttributes();
      case "Trace#getLongMetric":
        return getLongMetric(call);
      case "Trace#incrementMetric":
        return incrementMetric(call);
      case "Trace#putAttribute":
        return putAttribute(call);
      case "Trace#putMetric":
        return putMetric(call);
      case "Trace#removeAttribute":
        return removeAttribute(call);
      case "Trace#start":
        return start();
      case "Trace#stop":
        return stop();
      default:
        return new FlutterWrapper.MethodNotImplemented();
    }
  }

  private Object describeContents() {
    return trace.describeContents();
  }

  private Object getAttribute(final MethodCall call) {
    final String attribute = call.argument("attribute");
    return trace.getAttribute(attribute);
  }

  private Object getAttributes() {
    return trace.getAttributes();
  }

  private Object getLongMetric(final MethodCall call) {
    final String metricName = call.argument("metricName");
    return trace.getLongMetric(metricName);
  }

  private Object incrementMetric(final MethodCall call) {
    final String metricName = call.argument("metricName");
    final Integer incrementBy = call.argument("incrementBy");
    trace.incrementMetric(metricName, incrementBy);
    return null;
  }

  private Object putAttribute(final MethodCall call) {
    final String attribute = call.argument("attribute");
    final String value = call.argument("value");
    trace.putAttribute(attribute, value);
    return null;
  }

  private Object putMetric(final MethodCall call) {
    final String metricName = call.argument("metricName");
    final Integer value = call.argument("value");
    trace.putMetric(metricName, value);
    return null;
  }

  private Object removeAttribute(final MethodCall call) {
    final String attribute = call.argument("attribute");
    trace.removeAttribute(attribute);
    return null;
  }

  private Object start() {
    trace.start();
    if (!FirebasePerformancePlugin.allocated(handle)) {
      FirebasePerformancePlugin.addWrapper(handle, this);
    }
    return null;
  }

  private Object stop() {
    trace.stop();
    FirebasePerformancePlugin.removeWrapper(handle);
    return null;
  }
}
