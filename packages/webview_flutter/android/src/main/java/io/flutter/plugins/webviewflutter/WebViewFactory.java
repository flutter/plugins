package io.flutter.plugins.webviewflutter;

import android.content.Context;
import android.util.Log;
import android.view.View;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class WebViewFactory implements PlatformViewFactory {
    final BinaryMessenger messenger;

    public WebViewFactory(BinaryMessenger messenger) {
        this.messenger = messenger;
    }

    @Override
    public PlatformView create(Context context, int id) {
        MethodChannel methodChannel = new MethodChannel(messenger, "webview_flutter/" + id);
        return new SimplePlatformView(context, methodChannel);
    }

    private static class SimplePlatformView implements PlatformView, MethodChannel.MethodCallHandler {
        SimplePlatformView(Context context, MethodChannel methodChannel) {
            this.webView = new WebView(context);

            webView.setWebViewClient(new WebViewClient());
            webView.getSettings().setJavaScriptEnabled(true);

            methodChannel.setMethodCallHandler(this);
        }

        private WebView webView;

        @Override
        public View getView() {
            return webView;
        }

        @Override
        public void dispose() {
            webView = null;
        }

        @Override
        public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
            switch(methodCall.method) {
                case "loadUrl":
                    String url = (String) methodCall.arguments;
                    webView.loadUrl(url);
                    return;
            }
            result.notImplemented();
        }
    }
}
