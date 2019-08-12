package io.flutter.plugins.firebaseperformance;

import io.flutter.plugin.common.MethodCall;
import java.lang.Object;

public interface FlutterWrapper {
  Object onMethodCall(MethodCall call);

  class MethodNotImplemented {
  }
}
