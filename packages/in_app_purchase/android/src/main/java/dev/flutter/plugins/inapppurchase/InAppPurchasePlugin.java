package dev.flutter.plugins.inapppurchase;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.inapppurchase.BillingClientFactoryImpl;
import io.flutter.plugins.inapppurchase.MethodChannelHandler;

public class InAppPurchasePlugin implements FlutterPlugin, ActivityAware {

    private MethodChannelHandler methodChannelHandler;

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        final MethodChannel methodChannel =
                new MethodChannel(
                        binding.getFlutterEngine().getDartExecutor(), "plugins.flutter.io/in_app_purchase");
        methodChannelHandler = new MethodChannelHandler(null, binding.getApplicationContext(), methodChannel, new BillingClientFactoryImpl());
        methodChannel.setMethodCallHandler(methodChannelHandler);
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        methodChannelHandler.setActivity(binding.getActivity());
    }

    @Override
    public void onDetachedFromActivity() {
        methodChannelHandler.setActivity(null);
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }
}
