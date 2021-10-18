package io.flutter.plugins.webviewflutter;

import android.graphics.Bitmap;
import android.os.Build;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import androidx.annotation.RequiresApi;

import io.flutter.plugins.webviewflutter.GeneratedAndroidWebView.WebViewClientFlutterApi;

public class WebViewClientHostApiImpl implements GeneratedAndroidWebView.WebViewClientHostApi {
  private final InstanceManager instanceManager;
  private final WebViewClientFlutterApi webViewClientFlutterApi;

  WebViewClientHostApiImpl(InstanceManager instanceManager, WebViewClientFlutterApi webViewClientFlutterApi) {
    this.instanceManager = instanceManager;
    this.webViewClientFlutterApi = webViewClientFlutterApi;
  }

  @Override
  public void create(Long instanceId, Boolean shouldOverrideUrlLoading) {
    final WebViewClient webViewClient = new WebViewClient() {
      @Override
      public void onPageStarted(WebView view, String url, Bitmap favicon) {
        webViewClientFlutterApi.onPageStarted(instanceId, instanceManager.getInstanceId(view), url, reply -> { });
      }

      @Override
      public void onPageFinished(WebView view, String url) {
        webViewClientFlutterApi.onPageFinished(instanceId, instanceManager.getInstanceId(view), url, reply -> { });
      }

      @RequiresApi(api = Build.VERSION_CODES.M)
      @Override
      public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
        final GeneratedAndroidWebView.WebResourceRequestData requestData = new GeneratedAndroidWebView.WebResourceRequestData();
        requestData.setUrl(request.getUrl().toString());
        requestData.setIsForMainFrame(request.isForMainFrame());
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
          requestData.setIsRedirect(request.isRedirect());
        }
        requestData.setHasGesture(request.hasGesture());
        requestData.setMethod(request.getMethod());
        requestData.setRequestHeaders(request.getRequestHeaders());

        final GeneratedAndroidWebView.WebResourceErrorData errorData = new GeneratedAndroidWebView.WebResourceErrorData();
        errorData.setErrorCode((long) error.getErrorCode());
        errorData.setDescription(error.getDescription().toString());

        webViewClientFlutterApi.onReceivedRequestError(instanceId,
            instanceManager.getInstanceId(view),
            requestData,
            errorData, reply -> { });
      }

      @Override
      public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
        webViewClientFlutterApi.onReceivedError(instanceId,
            instanceManager.getInstanceId(view),
            (long) errorCode, description,
            failingUrl, reply -> { });
      }

      @RequiresApi(api = Build.VERSION_CODES.M)
      @Override
      public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
        final GeneratedAndroidWebView.WebResourceRequestData requestData = new GeneratedAndroidWebView.WebResourceRequestData();
        requestData.setUrl(request.getUrl().toString());
        requestData.setIsForMainFrame(request.isForMainFrame());
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
          requestData.setIsRedirect(request.isRedirect());
        }
        requestData.setHasGesture(request.hasGesture());
        requestData.setMethod(request.getMethod());
        requestData.setRequestHeaders(request.getRequestHeaders());

        webViewClientFlutterApi.requestLoading(instanceId,
            instanceManager.getInstanceId(view),
            requestData, reply -> {});
        return shouldOverrideUrlLoading;
      }

      @Override
      public boolean shouldOverrideUrlLoading(WebView view, String url) {
        webViewClientFlutterApi.urlLoading(instanceId,
            instanceManager.getInstanceId(view),
            url,
            reply -> {});
        return shouldOverrideUrlLoading;
      }
    };
    instanceManager.addInstance(webViewClient, instanceId);
  }

  @Override
  public void dispose(Long instanceId) {
    instanceManager.removeInstanceId(instanceId);
  }
}
