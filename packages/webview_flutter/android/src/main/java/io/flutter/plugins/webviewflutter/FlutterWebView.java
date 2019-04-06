// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.annotation.TargetApi;
import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.view.View;
import android.webkit.WebStorage;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.webkit.WebChromeClient;
import android.webkit.GeolocationPermissions;
import android.app.AlertDialog;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.content.DialogInterface;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.platform.PlatformView;

import java.util.List;
import java.util.Map;

import android.support.v4.content.ContextCompat;
import android.support.v4.app.ActivityCompat;


public class FlutterWebView implements PlatformView, MethodCallHandler {
 private static final String JS_CHANNEL_NAMES_FIELD = "javascriptChannelNames";
 private final WebView webView;
 private final MethodChannel methodChannel;
 private final FlutterWebViewClient flutterWebViewClient;
 private final Handler platformThreadHandler;
 private final Activity activity;

 @SuppressWarnings("unchecked")
 FlutterWebView(Context context, BinaryMessenger messenger, int id, Map < String, Object > params, Activity mainActivity) {
  webView = new WebView(context);
  platformThreadHandler = new Handler(context.getMainLooper());
  activity = mainActivity;
  // Allow local storage.
  webView.getSettings().setDomStorageEnabled(true);

  methodChannel = new MethodChannel(messenger, "plugins.flutter.io/webview_" + id);
  methodChannel.setMethodCallHandler(this);

  flutterWebViewClient = new FlutterWebViewClient(methodChannel);
  applySettings((Map < String, Object > ) params.get("settings"));

  if (params.containsKey(JS_CHANNEL_NAMES_FIELD)) {
   registerJavaScriptChannelNames((List < String > ) params.get(JS_CHANNEL_NAMES_FIELD));
  }

  if (params.containsKey("initialUrl")) {
   String url = (String) params.get("initialUrl");
   webView.loadUrl(url);
  }
 }

 @Override
 public View getView() {
  return webView;
 }

 @Override
 public void onMethodCall(MethodCall methodCall, Result result) {
  switch (methodCall.method) {
   case "loadUrl":
    loadUrl(methodCall, result);
    break;
   case "updateSettings":
    updateSettings(methodCall, result);
    break;
   case "canGoBack":
    canGoBack(methodCall, result);
    break;
   case "canGoForward":
    canGoForward(methodCall, result);
    break;
   case "goBack":
    goBack(methodCall, result);
    break;
   case "goForward":
    goForward(methodCall, result);
    break;
   case "reload":
    reload(methodCall, result);
    break;
   case "currentUrl":
    currentUrl(methodCall, result);
    break;
   case "evaluateJavascript":
    evaluateJavaScript(methodCall, result);
    break;
   case "addJavascriptChannels":
    addJavaScriptChannels(methodCall, result);
    break;
   case "removeJavascriptChannels":
    removeJavaScriptChannels(methodCall, result);
    break;
   case "clearCache":
    clearCache(result);
    break;
   default:
    result.notImplemented();
  }
 }

 private void loadUrl(MethodCall methodCall, Result result) {
  String url = (String) methodCall.arguments;
  webView.loadUrl(url);
  result.success(null);
 }

 private void updateGeolocationMode(int mode) {

  switch (mode) {
   case 0: // disabled
    // webView.getSettings().setJavaScriptEnabled(false);
    break;
   case 1: // unrestricted
    webView.getSettings().setJavaScriptEnabled(true); // Need JS for Geolocation
    webView.setWebChromeClient(new WebChromeClient() {
     public void onGeolocationPermissionsShowPrompt(final String origin, final GeolocationPermissions.Callback callback) {
      // Use the Builder class for convenient dialog construction
      AlertDialog.Builder builder = new AlertDialog.Builder(activity);
      // builder.setMessage(R.string.dialog_prompt_geolocation)
      builder.setMessage("This apps wants to access your location") // Need option for custom app name
       .setPositiveButton("Allow", new DialogInterface.OnClickListener() {
        public void onClick(DialogInterface dialog, int id) {
         // FIRE ZE MISSILES!
         callback.invoke(origin, true, true); // Always allow, maybe prompt user with a checkbox?
        }
       })
       .setNegativeButton("Deny", new DialogInterface.OnClickListener() {
        public void onClick(DialogInterface dialog, int id) {
         // User refuses permission, callback does not latch (third param)so it will ask again next time
         callback.invoke(origin, true, false);
        }
       });
      if (ContextCompat.checkSelfPermission(activity, Manifest.permission.FINE_LOCATION) != PackageManager.PERMISSION_GRANTED ||
       ContextCompat.checkSelfPermission(activity, Manifest.permission.COARSE) != PackageManager.PERMISSION_GRANTED) {
       ActivityCompat.requestPermissions(activity,
        new String[] {
         Manifest.permission.FINE_LOCATION
        },
        MY_PERMISSIONS_REQUEST_FINE_LOCATION);
       // Create the AlertDialog object and return it
       builder.create().show();

      } else {
       // Create the AlertDialog object and return it
       builder.create().show();

      }

     }
    });
    // webView.getSettings().setGeolocationDatabasePath( context.getFilesDir().getPath() ); // Set this to assets folder?
    break;
   default:
    throw new IllegalArgumentException("Trying to set unknown Geolocation mode: " + mode);
  }
 }

 private void canGoBack(MethodCall methodCall, Result result) {
  result.success(webView.canGoBack());
 }

 private void canGoForward(MethodCall methodCall, Result result) {
  result.success(webView.canGoForward());
 }

 private void goBack(MethodCall methodCall, Result result) {
  if (webView.canGoBack()) {
   webView.goBack();
  }
  result.success(null);
 }

 private void goForward(MethodCall methodCall, Result result) {
  if (webView.canGoForward()) {
   webView.goForward();
  }
  result.success(null);
 }

 private void reload(MethodCall methodCall, Result result) {
  webView.reload();
  result.success(null);
 }

 private void currentUrl(MethodCall methodCall, Result result) {
  result.success(webView.getUrl());
 }

 @SuppressWarnings("unchecked")
 private void updateSettings(MethodCall methodCall, Result result) {
  applySettings((Map < String, Object > ) methodCall.arguments);
  result.success(null);
 }

 @TargetApi(Build.VERSION_CODES.KITKAT)
 private void evaluateJavaScript(MethodCall methodCall, final Result result) {
  String jsString = (String) methodCall.arguments;
  if (jsString == null) {
   throw new UnsupportedOperationException("JavaScript string cannot be null");
  }
  webView.evaluateJavascript(
   jsString,
   new android.webkit.ValueCallback < String > () {
    @Override
    public void onReceiveValue(String value) {
     result.success(value);
    }
   });
 }

 @SuppressWarnings("unchecked")
 private void addJavaScriptChannels(MethodCall methodCall, Result result) {
  List < String > channelNames = (List < String > ) methodCall.arguments;
  registerJavaScriptChannelNames(channelNames);
  result.success(null);
 }

 @SuppressWarnings("unchecked")
 private void removeJavaScriptChannels(MethodCall methodCall, Result result) {
  List < String > channelNames = (List < String > ) methodCall.arguments;
  for (String channelName: channelNames) {
   webView.removeJavascriptInterface(channelName);
  }
  result.success(null);
 }

 private void clearCache(Result result) {
  webView.clearCache(true);
  WebStorage.getInstance().deleteAllData();
  result.success(null);
 }

 private void applySettings(Map < String, Object > settings) {
  for (String key: settings.keySet()) {
   switch (key) {
    case "jsMode":
     updateJsMode((Integer) settings.get(key));
     break;
    case "geolocationMode":
     updateGeolocationMode((Integer) settings.get(key));
     break;

    case "hasNavigationDelegate":
     final boolean hasNavigationDelegate = (boolean) settings.get(key);

     final WebViewClient webViewClient =
      flutterWebViewClient.createWebViewClient(hasNavigationDelegate);

     webView.setWebViewClient(webViewClient);
     break;
    default:
     throw new IllegalArgumentException("Unknown WebView setting: " + key);
   }
  }
 }

 private void updateJsMode(int mode) {
  switch (mode) {
   case 0: // disabled
    webView.getSettings().setJavaScriptEnabled(false);
    break;
   case 1: // unrestricted
    webView.getSettings().setJavaScriptEnabled(true);
    break;
   default:
    throw new IllegalArgumentException("Trying to set unknown JavaScript mode: " + mode);
  }
 }

 private void registerJavaScriptChannelNames(List < String > channelNames) {
  for (String channelName: channelNames) {
   webView.addJavascriptInterface(
    new JavaScriptChannel(methodChannel, channelName, platformThreadHandler), channelName);
  }
 }

 @Override
 public void dispose() {
  methodChannel.setMethodCallHandler(null);
 }
}