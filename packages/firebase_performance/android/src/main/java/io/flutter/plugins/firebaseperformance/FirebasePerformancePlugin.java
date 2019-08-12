package io.flutter.plugins.firebaseperformance;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.lang.Boolean;
import java.lang.IllegalArgumentException;
import java.lang.Object;
import java.lang.Override;
import java.lang.String;
import java.util.ArrayList;
import java.util.HashMap;

public final class FirebasePerformancePlugin implements MethodCallHandler, FlutterWrapper {
  private static final String CHANNEL_NAME = "io.flutter.plugins/firebase_performance";

  private static final HashMap<String, FlutterWrapper> wrappers = new HashMap<>();

  private static final HashMap<String, FlutterWrapper> invokerWrappers = new HashMap<>();

  private static Registrar registrar;

  private static MethodChannel channel;

  public static void registerWith(Registrar registrar) {
    FirebasePerformancePlugin.registrar = registrar;
    channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
    channel.setMethodCallHandler(new FirebasePerformancePlugin());
  }

  static void addWrapper(final String handle, final FlutterWrapper wrapper) {
    if (wrappers.get(handle) != null) {
      final String message = String.format("Object for handle already exists: %s", handle);
      throw new IllegalArgumentException(message);
    }
    wrappers.put(handle, wrapper);
  }

  static void addInvokerWrapper(final String handle, final FlutterWrapper wrapper) {
    if (invokerWrappers.get(handle) != null) {
      final String message = String.format("Object for handle already exists: %s", handle);
      throw new IllegalArgumentException(message);
    }
    invokerWrappers.put(handle, wrapper);
  }

  static void removeWrapper(String handle) {
    wrappers.remove(handle);
  }

  static Boolean allocated(final String handle) {
    return wrappers.containsKey(handle);
  }

  static FlutterWrapper getWrapper(String handle) {
    final FlutterWrapper wrapper = wrappers.get(handle);
    if (wrapper != null) return wrapper;
    return invokerWrappers.get(handle);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    invokerWrappers.clear();
    final Object value = onMethodCall(call);
    if (value instanceof FlutterWrapper.MethodNotImplemented) {
      result.notImplemented();
      return;
    }
    result.success(value);
    invokerWrappers.clear();
  }

  @Override
  public Object onMethodCall(MethodCall call) {
    switch(call.method) {
      case "Invoke":
        Object value = null;
        final ArrayList<HashMap<String, Object>> allMethodCallData = (ArrayList<HashMap<String, Object>>) call.arguments;
        for(HashMap<String, Object> methodCallData : allMethodCallData) {
          final String method = (String) methodCallData.get("method");;
          final HashMap<String, Object> arguments = (HashMap<String, Object>) methodCallData.get("arguments");
          final MethodCall methodCall = new MethodCall(method, arguments);
          value = onMethodCall(methodCall);
          if (value instanceof FlutterWrapper.MethodNotImplemented) {
            return new FlutterWrapper.MethodNotImplemented();
          }
        }
        return value;
      case "FirebasePerformance#getInstance":
        return FlutterFirebasePerformance.onStaticMethodCall(call);
      case "FirebasePerformance#startTrace":
        return FlutterFirebasePerformance.onStaticMethodCall(call);
      default:
        final String handle = call.argument("handle");
        if (handle == null) {
          return new FlutterWrapper.MethodNotImplemented();
        }
        final FlutterWrapper wrapper = getWrapper(handle);
        if (wrapper == null) {
          return new FlutterWrapper.MethodNotImplemented();
        }
        return wrapper.onMethodCall(call);
    }
  }
}
