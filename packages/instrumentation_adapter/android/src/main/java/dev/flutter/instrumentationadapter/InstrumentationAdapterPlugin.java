package dev.flutter.plugins.instrumentationadapter;

import android.util.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.concurrent.CompletableFuture;
import java.util.Map;

/** InstrumentationAdapterPlugin */
public class InstrumentationAdapterPlugin implements MethodCallHandler {

  public static CompletableFuture<Map<String, String>> testResults = new CompletableFuture<>();

  private static final String CHANNEL = "dev.flutter/InstrumentationAdapterFlutterBinding";

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL);
     channel.setMethodCallHandler(new InstrumentationAdapterPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("allTestsFinished")) {
      Map<String, String> results = call.argument("results");
      testResults.complete(results);
      result.success(null);
    } else {
      result.notImplemented();
    }
  }
}
