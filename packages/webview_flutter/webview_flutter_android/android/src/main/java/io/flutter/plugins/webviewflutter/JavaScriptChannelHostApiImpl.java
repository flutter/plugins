package io.flutter.plugins.webviewflutter;

import android.os.Handler;
import android.os.Looper;
import io.flutter.plugins.webviewflutter.GeneratedAndroidWebView.JavaScriptChannelFlutterApi;

class JavaScriptChannelHostApiImpl implements GeneratedAndroidWebView.JavaScriptChannelHostApi {
  private final InstanceManager instanceManager;
  private final JavaScriptChannelProxy javaScriptChannelProxy;
  private final JavaScriptChannelFlutterApi javaScriptChannelFlutterApi;
  private final Handler platformThreadHandler;

  static class JavaScriptChannelProxy {
    JavaScriptChannel createJavaScriptChannel(
        Long instanceId,
        JavaScriptChannelFlutterApi javaScriptChannelFlutterApi,
        String channelName,
        Handler platformThreadHandler) {
      return new JavaScriptChannel(null, channelName, platformThreadHandler) {
        @Override
        public void postMessage(String message) {
          Runnable postMessageRunnable =
              () -> javaScriptChannelFlutterApi.postMessage(instanceId, message, reply -> {});
          if (platformThreadHandler.getLooper() == Looper.myLooper()) {
            postMessageRunnable.run();
          } else {
            platformThreadHandler.post(postMessageRunnable);
          }
        }
      };
    }
  }

  JavaScriptChannelHostApiImpl(
      InstanceManager instanceManager,
      JavaScriptChannelProxy javaScriptChannelProxy,
      JavaScriptChannelFlutterApi javaScriptChannelFlutterApi,
      Handler platformThreadHandler) {
    this.instanceManager = instanceManager;
    this.javaScriptChannelProxy = javaScriptChannelProxy;
    this.javaScriptChannelFlutterApi = javaScriptChannelFlutterApi;
    this.platformThreadHandler = platformThreadHandler;
  }

  @Override
  public void create(Long instanceId, String channelName) {
    final JavaScriptChannel javaScriptChannel =
        javaScriptChannelProxy.createJavaScriptChannel(
            instanceId, javaScriptChannelFlutterApi, channelName, platformThreadHandler);
    instanceManager.addInstance(javaScriptChannel, instanceId);
  }

  @Override
  public void dispose(Long instanceId) {
    instanceManager.removeInstanceId(instanceId);
  }
}
