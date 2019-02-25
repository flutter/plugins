package io.flutter.plugins.webviewflutter;

import android.util.Log;
import android.webkit.HttpAuthHandler;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;

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
    public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
        super.onReceivedError(view, request, error);
        Log.d(TAG, "onReceivedError: received error." + error);
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
