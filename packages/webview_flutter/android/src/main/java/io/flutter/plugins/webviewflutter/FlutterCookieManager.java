package io.flutter.plugins.webviewflutter;

import android.os.Build;
import android.os.Build.VERSION_CODES;
import android.webkit.CookieManager;
import android.webkit.ValueCallback;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class FlutterCookieManager implements MethodCallHandler {

  private FlutterCookieManager() {
    // Do not instantiate.
  }

  static void registerWith(BinaryMessenger messenger) {
    MethodChannel methodChannel = new MethodChannel(messenger, "plugins.flutter.io/cookie_manager");
    FlutterCookieManager cookieManager = new FlutterCookieManager();
    methodChannel.setMethodCallHandler(cookieManager);
  }

  @Override
  public void onMethodCall(MethodCall methodCall, Result result) {
    switch (methodCall.method) {
      case "clearCookies":
        clearCookies(result);
        break;
      default:
        result.notImplemented();
    }
  }

  private static void clearCookies(final Result result) {
    CookieManager cookieManager = CookieManager.getInstance();
    if (Build.VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
      cookieManager.removeAllCookies(new ValueCallback<Boolean>() {
        @Override
        public void onReceiveValue(Boolean value) {
          result.success(null);
        }
      });
    } else {
      cookieManager.removeAllCookie();
      result.success(null);
    }
  }

}
