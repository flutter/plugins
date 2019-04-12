// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.core;

import android.content.Context;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import java.lang.String;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class FirebaseCorePlugin implements MethodCallHandler {

  private final Context context;

  public static void registerWith(PluginRegistry.Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_core");
    channel.setMethodCallHandler(new FirebaseCorePlugin(registrar.context()));
  }

  private FirebaseCorePlugin(Context context) {
    this.context = context;
  }

  private Map asMap(FirebaseApp app) {
    Map<String, Object> appMap = new HashMap<>();
    appMap.put("name", app.getName());
    FirebaseOptions options = app.getOptions();
    Map<String, String> optionsMap = new HashMap<>();
    optionsMap.put("googleAppID", options.getApplicationId());
    optionsMap.put("GCMSenderID", options.getGcmSenderId());
    optionsMap.put("APIKey", options.getApiKey());
    optionsMap.put("databaseURL", options.getDatabaseUrl());
    optionsMap.put("storageBucket", options.getStorageBucket());
    optionsMap.put("projectID", options.getProjectId());
    appMap.put("options", optionsMap);
    return appMap;
  }

  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    switch (call.method) {
      case "FirebaseApp#configure":
        {
          Map<String, Object> arguments = call.arguments();
          String name = (String) arguments.get("name");
          @SuppressWarnings("unchecked")
          Map<String, String> optionsMap = (Map<String, String>) arguments.get("options");
          FirebaseOptions options =
              new FirebaseOptions.Builder()
                  .setApiKey(optionsMap.get("APIKey"))
                  .setApplicationId(optionsMap.get("googleAppID"))
                  .setDatabaseUrl(optionsMap.get("databaseURL"))
                  .setGcmSenderId(optionsMap.get("GCMSenderID"))
                  .setProjectId(optionsMap.get("projectID"))
                  .setStorageBucket(optionsMap.get("storageBucket"))
                  .build();
          FirebaseApp.initializeApp(context, options, name);
          result.success(null);
          break;
        }
      case "FirebaseApp#allApps":
        {
          List<Map<String, Object>> apps = new ArrayList<>();
          for (FirebaseApp app : FirebaseApp.getApps(context)) {
            apps.add(asMap(app));
          }
          result.success(apps);
          break;
        }
      case "FirebaseApp#appNamed":
        {
          String name = (String) call.arguments();
          try {
            FirebaseApp app = FirebaseApp.getInstance(name);
            result.success(asMap(app));
          } catch (IllegalStateException ex) {
            // App doesn't exist, so successfully return null.
            result.success(null);
          }
          break;
        }
      default:
        {
          result.notImplemented();
          break;
        }
    }
  }
}
