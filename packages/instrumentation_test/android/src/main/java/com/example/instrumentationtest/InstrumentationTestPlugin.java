package com.example.instrumentationtest;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** InstrumentationTestPlugin */
public class InstrumentationTestPlugin implements MethodCallHandler {

  private static final String CHANNEL = "dev.flutter/InstrumentationTestFlutterBinding";

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL);
    channel.setMethodCallHandler(new InstrumentationTestPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
      if (call.method.equals("testFinished")) {
          Map<String, String> results = call.argument("results");
          FlutterRunner.completeTestResults(results);
          result.success(null);
      } else {
          result.notImplemented();
      }
  }
}
