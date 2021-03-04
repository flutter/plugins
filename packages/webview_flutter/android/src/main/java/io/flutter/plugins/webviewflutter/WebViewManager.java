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
        return cache.get(webViewId).webView;
    }

    public void cacheWebView(InputAwareWebView webView, String webViewId) {
        WebViewData data = new WebViewData(webView);
        cache.put(webViewId, data);
    }

    public void clearAll() {
        cache.evictAll();
    }

    private class WebViewData {
        private InputAwareWebView webView;

        WebViewData(InputAwareWebView webView) {
            this.webView = webView;
        }
    }

    private class WebViewCache extends LruCache<java.lang.String, WebViewManager.WebViewData> {

        WebViewCache() {
            super(10);
        }

        @Override
        protected void entryRemoved(boolean evicted, @NonNull String key, @NonNull WebViewData oldValue, @Nullable WebViewData newValue) {
            super.entryRemoved(evicted, key, oldValue, newValue);

            oldValue.webView.dispose();
            oldValue.webView.destroy();
            oldValue.webView = null;
        }
    }
}

