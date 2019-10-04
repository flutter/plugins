package dev.flutter.plugins.urllauncher;

import android.os.Bundle;
import dev.flutter.plugins.urllauncher.UrlLauncher.LaunchStatus;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import java.util.Map;

/**
 * Translates incoming UrlLauncher MethodCalls into well formed Java function calls for {@link
 * UrlLauncher}.
 */
final class MethodCallHandlerImpl implements MethodCallHandler {
  private final UrlLauncher urlLauncher;

  /** Forwards all incoming MethodChannel calls to the given {@code urlLauncher}. */
  MethodCallHandlerImpl(UrlLauncher urlLauncher) {
    this.urlLauncher = urlLauncher;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    final String url = call.argument("url");
    switch (call.method) {
      case "canLaunch":
        onCanLaunch(result, url);
        break;
      case "launch":
        onLaunch(call, result, url);
        break;
      case "closeWebView":
        onCloseWebView(result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void onCanLaunch(Result result, String url) {
    result.success(urlLauncher.canLaunch(url));
  }

  private void onLaunch(MethodCall call, Result result, String url) {
    final boolean useWebView = call.argument("useWebView");
    final boolean enableJavaScript = call.argument("enableJavaScript");
    final boolean enableDomStorage = call.argument("enableDomStorage");
    final Map<String, String> headersMap = call.argument("headers");
    final Bundle headersBundle = extractBundle(headersMap);

    LaunchStatus launchStatus =
        urlLauncher.launch(url, headersBundle, useWebView, enableJavaScript, enableDomStorage);

    if (launchStatus == LaunchStatus.NO_ACTIVITY) {
      result.error("NO_ACTIVITY", "Launching a URL requires a foreground activity.", null);
    } else {
      result.success(true);
    }
  }

  private void onCloseWebView(Result result) {
    urlLauncher.closeWebView();
    result.success(null);
  }

  private static Bundle extractBundle(Map<String, String> headersMap) {
    final Bundle headersBundle = new Bundle();
    for (String key : headersMap.keySet()) {
      final String value = headersMap.get(key);
      headersBundle.putString(key, value);
    }
    return headersBundle;
  }
}
