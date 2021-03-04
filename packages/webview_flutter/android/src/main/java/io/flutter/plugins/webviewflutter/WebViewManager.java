package io.flutter.plugins.webviewflutter;

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

    public InputAwareWebView webViewForId(String webViewId) {
        return cache.get(webViewId);
    }

    public void cacheWebView(InputAwareWebView webView, String webViewId) {
        cache.put(webViewId, webView);
    }

    public void clearAll() {
        cache.evictAll();
    }

    private class WebViewCache extends LruCache<java.lang.String, InputAwareWebView> {

        WebViewCache() {
            super(10);
        }

        @Override
        protected void entryRemoved(boolean evicted, @NonNull String key, @NonNull InputAwareWebView oldValue, @Nullable InputAwareWebView newValue) {
            oldValue.dispose();
            oldValue.destroy();
        }
    }
}

