package io.flutter.ios_platform_images;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class IosPlatformImagesPlugin implements MethodCallHandler {
  public static void registerWith(Registrar registrar) {
    MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/ios_platform_images");
    final IosPlatformImagesPlugin instance = new IosPlatformImagesPlugin();
    channel.setMethodCallHandler(instance);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    result.error("AndroidNotSupported", "This plugin is for iOS only.", null);
  }
}
