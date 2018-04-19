package io.flutter.plugins.firebaseperformance;

import com.google.firebase.perf.FirebasePerformance;

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
}
