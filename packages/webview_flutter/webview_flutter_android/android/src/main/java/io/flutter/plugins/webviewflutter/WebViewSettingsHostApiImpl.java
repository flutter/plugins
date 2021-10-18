package io.flutter.plugins.webviewflutter;

import android.webkit.WebSettings;
import android.webkit.WebView;

class WebViewSettingsHostApiImpl implements GeneratedAndroidWebView.WebSettingsHostApi {
  private final InstanceManager instanceManager;

  WebViewSettingsHostApiImpl(InstanceManager instanceManager) {
    this.instanceManager = instanceManager;
  }

  @Override
  public void create(Long instanceId, Long webViewInstanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(webViewInstanceId);
    instanceManager.addInstance(webView.getSettings(), instanceId);
  }

  @Override
  public void dispose(Long instanceId) {
    instanceManager.removeInstanceId(instanceId);
  }

  @Override
  public void setDomStorageEnabled(Long instanceId, Boolean flag) {
    final WebSettings webSettings = (WebSettings) instanceManager.getInstance(instanceId);
    webSettings.setDomStorageEnabled(flag);
  }

  @Override
  public void setJavaScriptCanOpenWindowsAutomatically(Long instanceId, Boolean flag) {
    final WebSettings webSettings = (WebSettings) instanceManager.getInstance(instanceId);
    webSettings.setJavaScriptCanOpenWindowsAutomatically(flag);
  }

  @Override
  public void setSupportMultipleWindows(Long instanceId, Boolean support) {
    final WebSettings webSettings = (WebSettings) instanceManager.getInstance(instanceId);
    webSettings.setSupportMultipleWindows(support);
  }

  @Override
  public void setJavaScriptEnabled(Long instanceId, Boolean flag) {
    final WebSettings webSettings = (WebSettings) instanceManager.getInstance(instanceId);
    webSettings.setJavaScriptEnabled(flag);
  }

  @Override
  public void setUserAgentString(Long instanceId, String userAgentString) {
    final WebSettings webSettings = (WebSettings) instanceManager.getInstance(instanceId);
    webSettings.setUserAgentString(userAgentString);
  }

  @Override
  public void setMediaPlaybackRequiresUserGesture(Long instanceId, Boolean require) {
    final WebSettings webSettings = (WebSettings) instanceManager.getInstance(instanceId);
    webSettings.setMediaPlaybackRequiresUserGesture(require);
  }

  @Override
  public void setSupportZoom(Long instanceId, Boolean support) {
    final WebSettings webSettings = (WebSettings) instanceManager.getInstance(instanceId);
    webSettings.setSupportZoom(support);
  }

  @Override
  public void setLoadWithOverviewMode(Long instanceId, Boolean overview) {
    final WebSettings webSettings = (WebSettings) instanceManager.getInstance(instanceId);
    webSettings.setLoadWithOverviewMode(overview);
  }

  @Override
  public void setUseWideViewPort(Long instanceId, Boolean use) {
    final WebSettings webSettings = (WebSettings) instanceManager.getInstance(instanceId);
    webSettings.setUseWideViewPort(use);
  }

  @Override
  public void setDisplayZoomControls(Long instanceId, Boolean enabled) {
    final WebSettings webSettings = (WebSettings) instanceManager.getInstance(instanceId);
    webSettings.setDisplayZoomControls(enabled);
  }

  @Override
  public void setBuiltInZoomControls(Long instanceId, Boolean enabled) {
    final WebSettings webSettings = (WebSettings) instanceManager.getInstance(instanceId);
    webSettings.setBuiltInZoomControls(enabled);
  }
}
