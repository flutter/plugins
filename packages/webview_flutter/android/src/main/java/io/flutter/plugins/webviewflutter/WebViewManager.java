package io.flutter.plugins.webviewflutter;

import java.util.Collections;
import java.util.Date;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.List;

public final class WebViewManager {
    private static WebViewManager INSTANCE;

    private int maxCachedTabs = 0;
    private Hashtable<String, WebViewData> cache = new Hashtable<String, WebViewData>();

    private WebViewManager() {
    }

    public static WebViewManager getInstance() {
        if(INSTANCE == null) {
            INSTANCE = new WebViewManager();
        }

        return INSTANCE;
    }

    public void updateMaxCachedTabs(int maxCachedTabs) {
        this.maxCachedTabs = maxCachedTabs;
    }

    public InputAwareWebView webViewForId(String webViewId) {
        WebViewData data = cache.get(webViewId);
        if (data != null) {
            data.updateDate();
            return data.webView;
        }
        return null;
    }

    public void cacheWebView(InputAwareWebView webView, String webViewId) {
        WebViewData data = new WebViewData(webView, webViewId);
        cache.put(webViewId, data);
        removeOldTabsIfNeeded();
    }

    public void clearAll() {
        for (WebViewData data: cache.values()) {
            data.webView.dispose();
            data.webView.destroy();
        }
        cache.clear();
    }

    public void removeOldTabsIfNeeded() {
        // Cache not supported
        if (maxCachedTabs <= 0) {
            clearAll();
            return;
        }

        // Sort cache elements in descending order
        Enumeration<WebViewData> elements = cache.elements();
        List<WebViewData> list = Collections.list(elements);
        Collections.sort(list);

        // Remove old tabs if cache contains more tabs than `maxCachedTabs`
        if (list.size() > maxCachedTabs) {
            for (int i = maxCachedTabs; i < list.size(); i++) {
                WebViewData data = list.get(i);
                data.webView.dispose();
                data.webView.destroy();
                cache.remove(data.webViewId);
            }
        }
    }

    private class WebViewData implements Comparable<WebViewData> {
        private InputAwareWebView webView;
        private Date cachedDate;
        private String webViewId;

        WebViewData(InputAwareWebView webView, String webViewId) {
            this.webView = webView;
            this.webViewId = webViewId;
            cachedDate = new Date();
        }

        void updateDate() {
            cachedDate = new Date();
        }

        @Override
        public int compareTo(WebViewData webViewData) {
            return webViewData.cachedDate.compareTo(cachedDate);
        }
    }
}

