package dev.flutter.plugins.deviceinfo;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.deviceinfo.MethodCallHandlerImpl;

/**
 * Entry point of the plugin. It sets up the {@link io.flutter.plugin.common.MethodChannel.MethodCallHandler}
 * during {@link #onAttachedToEngine(FlutterPluginBinding)}.
 */
public class DeviceInfoPlugin implements FlutterPlugin {

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        final MethodChannel channel =
                new MethodChannel(binding.getFlutterEngine().getDartExecutor(), "plugins.flutter.io/device_info");

        final MethodCallHandlerImpl handler = new MethodCallHandlerImpl(binding.getApplicationContext().getContentResolver());
        channel.setMethodCallHandler(handler);
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {

    }
}
