package io.flutter.plugins.webviewflutter;

import android.webkit.DownloadListener;

class DownloadListenerHostApiImpl
    implements GeneratedAndroidWebView.DownloadListenerHostApi {
  private final InstanceManager instanceManager;
  private final DownloadListenerProxy downloadListenerProxy;
  private final GeneratedAndroidWebView.DownloadListenerFlutterApi downloadListenerFlutterApi;

  static class DownloadListenerProxy {
    DownloadListener createDownloadListener(Long instanceId, GeneratedAndroidWebView.DownloadListenerFlutterApi downloadListenerFlutterApi) {
      return (url, userAgent, contentDisposition, mimetype, contentLength) ->
          downloadListenerFlutterApi.onDownloadStart(
              instanceId,
              url,
              userAgent,
              contentDisposition,
              mimetype,
              contentLength,
              reply -> {});
    }
  }
  
  DownloadListenerHostApiImpl(
      InstanceManager instanceManager,
      DownloadListenerProxy downloadListenerProxy,
      GeneratedAndroidWebView.DownloadListenerFlutterApi downloadListenerFlutterApi) {
    this.instanceManager = instanceManager;
    this.downloadListenerProxy = downloadListenerProxy;
    this.downloadListenerFlutterApi = downloadListenerFlutterApi;
  }

  @Override
  public void create(Long instanceId) {
    instanceManager.addInstance(downloadListenerProxy.createDownloadListener(instanceId, downloadListenerFlutterApi), instanceId);
  }

  @Override
  public void dispose(Long instanceId) {
    instanceManager.removeInstanceId(instanceId);
  }
}
