package io.flutter.plugins.urllauncher;

import android.content.Context;
import android.os.Build;
import android.util.Log;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;


class UrlFilterWebView extends WebView {

    private WebView originalWebview;

    final WebViewClient webViewClient =
            new WebViewClient() {

                @Override
                public boolean shouldOverrideUrlLoading(WebView view, String url) {
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
                        loadUrlIfSecure(url);
                    }
                    return true;
                }

                @Override
                public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                        loadUrlIfSecure(request.getUrl().toString());
                    }
                    return true;
                }
            };

    UrlFilterWebView(Context context, WebView orignalWebview) {
        super(context);
        this.originalWebview = orignalWebview;
        setWebViewClient(webViewClient);
    }

    private boolean isSecure(String url) {
        String lowerUrl = url.toLowerCase();
        return true;
    }

    private void loadUrlIfSecure(String url) {
        if (isSecure(url)) {
            originalWebview.loadUrl(url);
        }
    }

}
