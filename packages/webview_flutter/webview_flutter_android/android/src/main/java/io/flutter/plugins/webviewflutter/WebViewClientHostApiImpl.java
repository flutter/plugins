package io.flutter.plugins.webviewflutter;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.graphics.Bitmap;
import android.os.Build;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.webkit.WebResourceErrorCompat;
import androidx.webkit.WebViewClientCompat;

import io.flutter.plugins.webviewflutter.GeneratedAndroidWebView.WebViewClientFlutterApi;

class WebViewClientHostApiImpl implements GeneratedAndroidWebView.WebViewClientHostApi {
  private final InstanceManager instanceManager;
  private final WebViewClientProxy webViewClientProxy;
  private final WebViewClientFlutterApi webViewClientFlutterApi;
  
  @RequiresApi(api = Build.VERSION_CODES.M)
  static GeneratedAndroidWebView.WebResourceErrorData createWebResourceErrorData(WebResourceError error) {
    final GeneratedAndroidWebView.WebResourceErrorData errorData =
        new GeneratedAndroidWebView.WebResourceErrorData();
    errorData.setErrorCode((long) error.getErrorCode());
    errorData.setDescription(error.getDescription().toString());
    
    return errorData;
  }
  
  @SuppressLint("RequiresFeature")
  static GeneratedAndroidWebView.WebResourceErrorData createWebResourceErrorData(WebResourceErrorCompat error) {
    final GeneratedAndroidWebView.WebResourceErrorData errorData =
        new GeneratedAndroidWebView.WebResourceErrorData();
    errorData.setErrorCode((long) error.getErrorCode());
    errorData.setDescription(error.getDescription().toString());

    return errorData;
  }
  
  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  static GeneratedAndroidWebView.WebResourceRequestData createWebResourceRequestData(WebResourceRequest request) {
    final GeneratedAndroidWebView.WebResourceRequestData requestData =
        new GeneratedAndroidWebView.WebResourceRequestData();
    requestData.setUrl(request.getUrl().toString());
    requestData.setIsForMainFrame(request.isForMainFrame());
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
      requestData.setIsRedirect(request.isRedirect());
    }
    requestData.setHasGesture(request.hasGesture());
    requestData.setMethod(request.getMethod());
    requestData.setRequestHeaders(request.getRequestHeaders());
    
    return requestData;
  }

  static class WebViewClientProxy {
    WebViewClient createWebViewClient(Long instanceId, InstanceManager instanceManager, Boolean shouldOverrideUrlLoading, WebViewClientFlutterApi webViewClientFlutterApi) {
      if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        return new WebViewClient() {
          @Override
          public void onPageStarted(WebView view, String url, Bitmap favicon) {
            webViewClientFlutterApi.onPageStarted(
                instanceId, instanceManager.getInstanceId(view), url, reply -> {});
          }

          @Override
          public void onPageFinished(WebView view, String url) {
            webViewClientFlutterApi.onPageFinished(
                instanceId, instanceManager.getInstanceId(view), url, reply -> {});
          }

          @Override
          public void onReceivedError(
              WebView view, WebResourceRequest request, WebResourceError error) {
            webViewClientFlutterApi.onReceivedRequestError(
                instanceId,
                instanceManager.getInstanceId(view),
                createWebResourceRequestData(request),
                createWebResourceErrorData(error),
                reply -> {});
          }

          @Override
          public void onReceivedError(
              WebView view, int errorCode, String description, String failingUrl) {
            webViewClientFlutterApi.onReceivedError(
                instanceId,
                instanceManager.getInstanceId(view),
                (long) errorCode,
                description,
                failingUrl,
                reply -> {});
          }

          @Override
          public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
            webViewClientFlutterApi.requestLoading(
                instanceId,
                instanceManager.getInstanceId(view),
                createWebResourceRequestData(request),
                reply -> {});
            return shouldOverrideUrlLoading;
          }

          @Override
          public boolean shouldOverrideUrlLoading(WebView view, String url) {
            webViewClientFlutterApi.urlLoading(
                instanceId, instanceManager.getInstanceId(view), url, reply -> {});
            return shouldOverrideUrlLoading;
          }
        };
      } else {
        return new WebViewClientCompat() {
          @Override
          public void onPageStarted(WebView view, String url, Bitmap favicon) {
            webViewClientFlutterApi.onPageStarted(
                instanceId, instanceManager.getInstanceId(view), url, reply -> {});
          }

          @Override
          public void onPageFinished(WebView view, String url) {
            webViewClientFlutterApi.onPageFinished(
                instanceId, instanceManager.getInstanceId(view), url, reply -> {});
          }

          // This method is only called when the WebViewFeature.RECEIVE_WEB_RESOURCE_ERROR feature is
          // enabled. The deprecated method is called when a device doesn't support this.
          @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
          @SuppressLint("RequiresFeature")
          @Override
          public void onReceivedError(@NonNull WebView view, @NonNull WebResourceRequest request, @NonNull WebResourceErrorCompat error) {
            webViewClientFlutterApi.onReceivedRequestError(
                instanceId,
                instanceManager.getInstanceId(view),
                createWebResourceRequestData(request),
                createWebResourceErrorData(error),
                reply -> {});
          }

          @Override
          public void onReceivedError(
              WebView view, int errorCode, String description, String failingUrl) {
            webViewClientFlutterApi.onReceivedError(
                instanceId,
                instanceManager.getInstanceId(view),
                (long) errorCode,
                description,
                failingUrl,
                reply -> {});
          }

          @TargetApi(Build.VERSION_CODES.LOLLIPOP)
          @Override
          public boolean shouldOverrideUrlLoading(@NonNull WebView view, @NonNull WebResourceRequest request) {
            webViewClientFlutterApi.requestLoading(
                instanceId, instanceManager.getInstanceId(view), createWebResourceRequestData(request), reply -> {});
            return shouldOverrideUrlLoading;
          }

          @Override
          public boolean shouldOverrideUrlLoading(WebView view, String url) {
            webViewClientFlutterApi.urlLoading(
                instanceId, instanceManager.getInstanceId(view), url, reply -> {});
            return shouldOverrideUrlLoading;
          }
        };
      }
    }
  }

  WebViewClientHostApiImpl(
      InstanceManager instanceManager, WebViewClientProxy webViewClientProxy, WebViewClientFlutterApi webViewClientFlutterApi) {
    this.instanceManager = instanceManager;
    this.webViewClientProxy = webViewClientProxy;
    this.webViewClientFlutterApi = webViewClientFlutterApi;
  }

  @Override
  public void create(Long instanceId, Boolean shouldOverrideUrlLoading) {
    instanceManager.addInstance(
        webViewClientProxy.createWebViewClient(instanceId, instanceManager, shouldOverrideUrlLoading, webViewClientFlutterApi),
        instanceId
    );
  }

  @Override
  public void dispose(Long instanceId) {
    instanceManager.removeInstanceId(instanceId);
  }
}
