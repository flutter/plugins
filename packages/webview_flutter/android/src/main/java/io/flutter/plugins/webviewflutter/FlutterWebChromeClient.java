package io.flutter.plugins.webviewflutter;

import android.webkit.WebChromeClient;
import android.webkit.WebView;

import io.flutter.plugin.common.MethodChannel;

public class FlutterWebChromeClient extends WebChromeClient {
    private MethodChannel channel;

    public FlutterWebChromeClient(MethodChannel channel) {
        this.channel = channel;
    }

    @Override
    public void onProgressChanged(WebView view, int newProgress) {
        super.onProgressChanged(view, newProgress);
        channel.invokeMethod("onProgressChanged", newProgress);
    }
}
