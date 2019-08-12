package io.flutter.plugins.firebaseperformance;

import com.google.firebase.perf.metrics.HttpMetric;
import io.flutter.plugin.common.MethodCall;
import java.lang.Object;
import java.lang.Override;
import java.lang.String;

final class FlutterHttpMetric implements FlutterWrapper {
  private final String handle;

  public final HttpMetric httpmetric;

  FlutterHttpMetric(String handle, HttpMetric httpmetric) {
    this.handle = handle;
    this.httpmetric = httpmetric;
    FirebasePerformancePlugin.addInvokerWrapper(handle, this);
  }

  @Override
  public Object onMethodCall(MethodCall call) {
    switch(call.method) {
      case "HttpMetric#getAttribute":
        return getAttribute(call);
      case "HttpMetric#getAttributes":
        return getAttributes();
      case "HttpMetric#putAttribute":
        return putAttribute(call);
      case "HttpMetric#removeAttribute":
        return removeAttribute(call);
      case "HttpMetric#start":
        return start();
      case "HttpMetric#stop":
        return stop();
      case "HttpMetric#setHttpResponseCode":
        return setHttpResponseCode(call);
      case "HttpMetric#setRequestPayloadSize":
        return setRequestPayloadSize(call);
      case "HttpMetric#setResponseContentType":
        return setResponseContentType(call);
      case "HttpMetric#setResponsePayloadSize":
        return setResponsePayloadSize(call);
      default:
        return new FlutterWrapper.MethodNotImplemented();
    }
  }

  private Object getAttribute(final MethodCall call) {
    final String attribute = call.argument("attribute");
    return httpmetric.getAttribute(attribute);
  }

  private Object getAttributes() {
    return httpmetric.getAttributes();
  }

  private Object putAttribute(final MethodCall call) {
    final String attribute = call.argument("attribute");
    final String value = call.argument("value");
    httpmetric.putAttribute(attribute, value);
    return null;
  }

  private Object removeAttribute(final MethodCall call) {
    final String attribute = call.argument("attribute");
    httpmetric.removeAttribute(attribute);
    return null;
  }

  private Object start() {
    httpmetric.start();
    if (!FirebasePerformancePlugin.allocated(handle)) {
      FirebasePerformancePlugin.addWrapper(handle, this);
    }
    return null;
  }

  private Object stop() {
    httpmetric.stop();
    FirebasePerformancePlugin.removeWrapper(handle);
    return null;
  }

  private Object setHttpResponseCode(final MethodCall call) {
    final Integer responseCode = call.argument("responseCode");
    httpmetric.setHttpResponseCode(responseCode);
    return null;
  }

  private Object setRequestPayloadSize(final MethodCall call) {
    final Integer bytes = call.argument("bytes");
    httpmetric.setRequestPayloadSize(bytes);
    return null;
  }

  private Object setResponseContentType(final MethodCall call) {
    final String contentType = call.argument("contentType");
    httpmetric.setResponseContentType(contentType);
    return null;
  }

  private Object setResponsePayloadSize(final MethodCall call) {
    final Integer bytes = call.argument("bytes");
    httpmetric.setResponsePayloadSize(bytes);
    return null;
  }
}
