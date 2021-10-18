package io.flutter.plugins.webviewflutter;

import android.webkit.DownloadListener;

public class DownloadListenerHostApiImpl
    implements GeneratedAndroidWebView.DownloadListenerHostApi {
  private final InstanceManager instanceManager;
  private final GeneratedAndroidWebView.DownloadListenerFlutterApi downloadListenerFlutterApi;

  DownloadListenerHostApiImpl(
      InstanceManager instanceManager,
      GeneratedAndroidWebView.DownloadListenerFlutterApi downloadListenerFlutterApi) {
    this.instanceManager = instanceManager;
    this.downloadListenerFlutterApi = downloadListenerFlutterApi;
  }

  @Override
  public void create(Long instanceId) {
    final DownloadListener downloadListener =
        (url, userAgent, contentDisposition, mimetype, contentLength) ->
            downloadListenerFlutterApi.onDownloadStart(
                instanceId,
                url,
                userAgent,
                contentDisposition,
                mimetype,
                contentLength,
                reply -> {});
    instanceManager.addInstance(downloadListener, instanceId);
  }

  @Override
  public void dispose(Long instanceId) {
    instanceManager.removeInstanceId(instanceId);
  }
}
