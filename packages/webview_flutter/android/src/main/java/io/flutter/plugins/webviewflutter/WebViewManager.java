package io.flutter.plugins.webviewflutter;

import android.webkit.WebView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.collection.LruCache;

public enum WebViewManager {
    INSTANCE;

    private WebViewCache cache = new WebViewCache();

    public WebViewManager getInstance() {
        return INSTANCE;
    }

    public void updateMaxCachedTabs(int maxCachedTabs) {
        cache.resize(maxCachedTabs);
    }

    public WebView webViewForId(String webViewId) {
        return cache.get(webViewId);
    }

    public void cacheWebView(WebView webView, String webViewId) {
        cache.put(webViewId, webView);
    }

    public void clearAll() {
        cache.evictAll();
    }

    private class WebViewCache extends LruCache<java.lang.String, WebView> {

        WebViewCache() {
            super(10);
        }

        @Override
        protected void entryRemoved(boolean evicted, @NonNull String key, @NonNull WebView oldValue, @Nullable WebView newValue) {
            if (oldValue instanceof InputAwareWebView) {
                ((InputAwareWebView) oldValue).dispose();
            }
            oldValue.destroy();
        }
    }
}

