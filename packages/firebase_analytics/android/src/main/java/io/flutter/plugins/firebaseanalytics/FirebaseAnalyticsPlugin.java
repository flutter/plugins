// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseanalytics;

import android.app.Activity;
import android.os.Bundle;
import com.google.firebase.FirebaseApp;
import com.google.firebase.analytics.FirebaseAnalytics;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import java.util.Map;

/** Flutter plugin for Firebase Analytics. */
public class FirebaseAnalyticsPlugin implements MethodCallHandler {
  private final PluginRegistry.Registrar registrar;
  private final FirebaseAnalytics firebaseAnalytics;

  public static void registerWith(PluginRegistry.Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_analytics");
    channel.setMethodCallHandler(new FirebaseAnalyticsPlugin(registrar));
  }

  private FirebaseAnalyticsPlugin(PluginRegistry.Registrar registrar) {
    this.registrar = registrar;
    FirebaseApp.initializeApp(registrar.context());
    this.firebaseAnalytics = FirebaseAnalytics.getInstance(registrar.context());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "logEvent":
        handleLogEvent(call, result);
        break;
      case "setUserId":
        handleSetUserId(call, result);
        break;
      case "setCurrentScreen":
        handleSetCurrentScreen(call, result);
        break;
      case "setAnalyticsCollectionEnabled":
        handleSetAnalyticsCollectionEnabled(call, result);
        break;
      case "setMinimumSessionDuration":
        handleSetMinimumSessionDuration(call, result);
        break;
      case "setSessionTimeoutDuration":
        handleSetSessionTimeoutDuration(call, result);
        break;
      case "setUserProperty":
        handleSetUserProperty(call, result);
        break;
      case "resetAnalyticsData":
        handleResetAnalyticsData(call, result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void handleLogEvent(MethodCall call, Result result) {
    @SuppressWarnings("unchecked")
    Map<String, Object> arguments = (Map<String, Object>) call.arguments;
    final String eventName = (String) arguments.get("name");

    @SuppressWarnings("unchecked")
    final Bundle parameterBundle =
        createBundleFromMap((Map<String, Object>) arguments.get("parameters"));
    firebaseAnalytics.logEvent(eventName, parameterBundle);
    result.success(null);
  }

  private void handleSetUserId(MethodCall call, Result result) {
    final String id = (String) call.arguments;
    firebaseAnalytics.setUserId(id);
    result.success(null);
  }

  private void handleSetCurrentScreen(MethodCall call, Result result) {
    @SuppressWarnings("unchecked")
    Activity activity = registrar.activity();
    if (activity == null) {
      result.error("no_activity", "handleSetCurrentScreen requires a foreground activity", null);
      return;
    }
    Map<String, Object> arguments = (Map<String, Object>) call.arguments;
    final String screenName = (String) arguments.get("screenName");
    final String screenClassOverride = (String) arguments.get("screenClassOverride");

    firebaseAnalytics.setCurrentScreen(activity, screenName, screenClassOverride);
    result.success(null);
  }

  private void handleSetAnalyticsCollectionEnabled(MethodCall call, Result result) {
    final Boolean enabled = (Boolean) call.arguments;
    firebaseAnalytics.setAnalyticsCollectionEnabled(enabled);
    result.success(null);
  }

  private void handleSetMinimumSessionDuration(MethodCall call, Result result) {
    final Integer milliseconds = (Integer) call.arguments;
    firebaseAnalytics.setMinimumSessionDuration(milliseconds);
    result.success(null);
  }

  private void handleSetSessionTimeoutDuration(MethodCall call, Result result) {
    final Integer milliseconds = (Integer) call.arguments;
    firebaseAnalytics.setSessionTimeoutDuration(milliseconds);
    result.success(null);
  }

  private void handleSetUserProperty(MethodCall call, Result result) {
    @SuppressWarnings("unchecked")
    Map<String, Object> arguments = (Map<String, Object>) call.arguments;
    final String name = (String) arguments.get("name");
    final String value = (String) arguments.get("value");

    firebaseAnalytics.setUserProperty(name, value);
    result.success(null);
  }

  private void handleResetAnalyticsData(MethodCall call, Result result) {
    firebaseAnalytics.resetAnalyticsData();
    result.success(null);
  }

  private static Bundle createBundleFromMap(Map<String, Object> map) {
    if (map == null) {
      return null;
    }

    Bundle bundle = new Bundle();
    for (Map.Entry<String, Object> jsonParam : map.entrySet()) {
      final Object value = jsonParam.getValue();
      final String key = jsonParam.getKey();
      if (value instanceof String) {
        bundle.putString(key, (String) value);
      } else if (value instanceof Integer) {
        bundle.putInt(key, (Integer) value);
      } else if (value instanceof Long) {
        bundle.putLong(key, (Long) value);
      } else if (value instanceof Double) {
        bundle.putDouble(key, (Double) value);
      } else if (value instanceof Boolean) {
        bundle.putBoolean(key, (Boolean) value);
      } else {
        throw new IllegalArgumentException(
            "Unsupported value type: " + value.getClass().getCanonicalName());
      }
    }
    return bundle;
  }
}
