package io.flutter.plugins.webviewflutter;

import android.os.Build;
import android.os.Build.VERSION_CODES;
import android.webkit.CookieManager;
import android.webkit.WebSettings;
import android.webkit.WebView;
import io.flutter.util.Preconditions;

public final class Incognito {

  private Incognito() {
    // Utility cache. Do not instantiate.
  }

  public static void makeWebViewIncognito(WebView webView) {
    Preconditions.checkNotNull(webView);
    clearAndDisableAppCache(webView);
    clearAndDisableCookies();
    clearHistory(webView);
  }

  private static void clearAndDisableCookies() {
    CookieManager cookieManager = CookieManager.getInstance();
    if (Build.VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
      cookieManager.removeAllCookies(null);
    } else {
      cookieManager.removeAllCookie();
    }
    cookieManager.setAcceptCookie(false);
  }

  private static void clearAndDisableAppCache(WebView webView) {
    webView.clearCache(true);
    webView.getSettings().setCacheMode(WebSettings.LOAD_NO_CACHE);
    webView.getSettings().setAppCacheEnabled(false);
  }

  /**
   * Tells this WebView to clear its internal back/forward list. Not the global history.
   */
  private static void clearHistory(WebView webView) {
    webView.clearHistory();
  }

}
