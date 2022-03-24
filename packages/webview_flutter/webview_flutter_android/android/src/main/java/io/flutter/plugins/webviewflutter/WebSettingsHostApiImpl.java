// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Build;
import android.webkit.WebSettings;
import android.webkit.WebView;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import io.flutter.plugins.webviewflutter.GeneratedAndroidWebView.WebSettingsHostApi;


/**
 * Host api implementation for {@link WebSettings}.
 *
 * <p>Handles creating {@link WebSettings}s that intercommunicate with a paired Dart object.
 */
public class WebSettingsHostApiImpl implements WebSettingsHostApi {
  private final InstanceManager instanceManager;
  private final WebSettingsCreator webSettingsCreator;
  private static final int REQUEST_LOCATION = 100;

  /** Handles creating {@link WebSettings} for a {@link WebSettingsHostApiImpl}. */
  public static class WebSettingsCreator {
    /**
     * Creates a {@link WebSettings}.
     *
     * @param webView the {@link WebView} which the settings affect
     * @return the created {@link WebSettings}
     */
    public WebSettings createWebSettings(WebView webView) {
      return webView.getSettings();
    }
  }

  /**
   * Creates a host API that handles creating {@link WebSettings} and invoke its methods.
   *
   * @param instanceManager maintains instances stored to communicate with Dart objects
   * @param webSettingsCreator handles creating {@link WebSettings}s
   */
  public WebSettingsHostApiImpl(
      InstanceManager instanceManager, WebSettingsCreator webSettingsCreator) {
    this.instanceManager = instanceManager;
    this.webSettingsCreator = webSettingsCreator;
  }

  @Override
  public void create(Long instanceId, Long webViewInstanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(webViewInstanceId);
    instanceManager.addInstance(webSettingsCreator.createWebSettings(webView), instanceId);
  }

  @Override
  public void dispose(Long instanceId) {
    instanceManager.removeInstanceWithId(instanceId);
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

  @Override
  public void setAllowFileAccess(Long instanceId, Boolean enabled) {
    final WebSettings webSettings = (WebSettings) instanceManager.getInstance(instanceId);
    webSettings.setAllowFileAccess(enabled);
  }

  @Override
  public void setGeolocationEnabled(Long instanceId, Boolean enabled) {
    final WebSettings webSettings = (WebSettings) instanceManager.getInstance(instanceId);
    webSettings.setGeolocationEnabled(enabled);
    if (enabled && Build.VERSION.SDK_INT >= 23) {
      int checkPermission = ContextCompat.checkSelfPermission(WebViewFlutterPlugin.activity, Manifest.permission.ACCESS_COARSE_LOCATION);
      if (checkPermission != PackageManager.PERMISSION_GRANTED) {
        ActivityCompat.requestPermissions(WebViewFlutterPlugin.activity,
                new String[]{Manifest.permission.ACCESS_COARSE_LOCATION,Manifest.permission.ACCESS_FINE_LOCATION},
                REQUEST_LOCATION);
      }
    }
  }
}
