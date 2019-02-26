package io.flutter.plugins.webviewflutter;

import android.graphics.Bitmap;
import android.os.Build;
import android.util.Log;
import android.webkit.HttpAuthHandler;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class FlutterWebViewClient extends WebViewClient {

    private final static String TAG = "FlutterWebViewClient";

    private final MethodChannel methodChannel;

    public FlutterWebViewClient(MethodChannel methodChannel) {
        this.methodChannel = methodChannel;
    }

    @Override
    public void onLoadResource(WebView view, String url) {
        Log.d(TAG, "onLoadResource: loading " + url);
    }

    @Override
    public void onPageFinished(WebView view, String url) {
        super.onPageFinished(view, url);
        Log.d(TAG, "onPageFinished: " + url);
        this.methodChannel.invokeMethod("onPageFinished", Collections.singletonMap("url", url));
    }

    @Override
    public void onPageStarted(WebView view, String url, Bitmap favicon) {
        super.onPageStarted(view, url, favicon);
        this.methodChannel.invokeMethod("onPageStarted", Collections.singletonMap("url", url));
    }

    @Override
    public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
        super.onReceivedError(view, request, error);
        Log.d(TAG, "onReceivedError: received error." + error);
        Map<String, String> map = new HashMap<>();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            map.put("url", request.getUrl().toString());
            map.put("description", error.getDescription().toString());
        } else {
            map.put("description", error.toString());
        }
        this.methodChannel.invokeMethod("onReceivedError", map);
    }

    @Override
    public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
        Log.d(TAG, "shouldOverrideUrlLoading: " + request);
        return super.shouldOverrideUrlLoading(view, request);
    }

    @Override
    public void onReceivedHttpAuthRequest(WebView view, final HttpAuthHandler handler, String host, String realm) {
        HashMap<String, String> arguments = new HashMap<>();
        arguments.put("host", host);
        arguments.put("realm", realm);
        methodChannel.invokeMethod("onReceivedHttpAuthRequest", arguments, new MethodChannel.Result() {
            @Override
            public void success(Object o) {
                if (o instanceof Map) {
                    Map<?, ?> map = (Map<?, ?>) o;
                    Object username = map.get("username");
                    Object password = map.get("password");
                    if (username != null && password != null) {
                        handler.proceed(username.toString(), password.toString());
                        return;
                    }
                }
                handler.cancel();
            }

            @Override
            public void error(String s, String s1, Object o) {
                handler.cancel();
            }

            @Override
            public void notImplemented() {
                handler.cancel();
            }
        });

    }
}
