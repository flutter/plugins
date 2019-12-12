package io.flutter.plugins.shared_preferences_macos;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** SharedPreferencesMacosPlugin */
public class SharedPreferencesMacosPlugin implements FlutterPlugin, MethodCallHandler {
  @Override
  public void onAttachedToEngine(FlutterPluginBinding flutterPluginBinding) {}

  public static void registerWith(Registrar registrar) {}

  @Override
  public void onMethodCall(MethodCall call, Result result) {}

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {}
}
