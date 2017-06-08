package io.flutter.plugins.callback;

import java.util.HashMap;
import java.util.Map;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * Android implementation of the CallbackPlugin.
 */
public class CallbackPlugin implements MethodCallHandler {
  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    CallbackPlugin plugin = new CallbackPlugin();
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "callback");
    channel.setMethodCallHandler(plugin);
    registrar.publish(plugin);
  }

  private final Map<String, Runnable> callbacks = new HashMap<>();

  public void registerCallback(String id, Runnable callback) {
    callbacks.put(id, callback);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("call")) {
      final String id = call.argument("callbackId");
      Runnable runnable = callbacks.get(id);
      if (runnable == null) {
        result.error("UNKNOWN_CALLBACK", "Callback " + id + " not registered",
            null);
        return;
      }
      runnable.run();
      result.success(null);
    } else {
      result.error("UNKNOWN_METHOD", "Unknown share method called", null);
    }
  }
}
