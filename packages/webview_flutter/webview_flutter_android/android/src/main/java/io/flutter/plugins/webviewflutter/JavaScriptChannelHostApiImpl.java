package io.flutter.plugins.webviewflutter;

import android.os.Handler;
import io.flutter.plugins.webviewflutter.GeneratedAndroidWebView.JavaScriptChannelFlutterApi;

class JavaScriptChannelHostApiImpl
    implements GeneratedAndroidWebView.JavaScriptChannelHostApi {
  private final InstanceManager instanceManager;
  private final JavaScriptChannelFlutterApi javaScriptChannelFlutterApi;
  private final Handler platformThreadHandler;

  JavaScriptChannelHostApiImpl(
      InstanceManager instanceManager,
      JavaScriptChannelFlutterApi javaScriptChannelFlutterApi,
      Handler platformThreadHandler) {
    this.instanceManager = instanceManager;
    this.javaScriptChannelFlutterApi = javaScriptChannelFlutterApi;
    this.platformThreadHandler = platformThreadHandler;
  }

  @Override
  public void create(Long instanceId, String channelName) {
    final JavaScriptChannel javaScriptChannel =
        new JavaScriptChannel(null, channelName, platformThreadHandler) {
          @Override
          public void postMessage(String message) {
            javaScriptChannelFlutterApi.postMessage(instanceId, message, reply -> {});
          }
        };
    instanceManager.addInstance(javaScriptChannel, instanceId);
  }

  @Override
  public void dispose(Long instanceId) {
    instanceManager.removeInstanceId(instanceId);
  }
}
