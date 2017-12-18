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
    channel.setMethodCallHandler(new FirebaseCorePlugin(registrar.activity()));
  }

  private FirebaseCorePlugin(Context context) {
    this.context = context;
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
                  .setDatabaseUrl(optionsMap.get("databaseUrl"))
                  .setGcmSenderId(optionsMap.get("GCMSenderID"))
                  .setProjectId(optionsMap.get("projectId"))
                  .setStorageBucket(optionsMap.get("storageBucket"))
                  .build();
          if (name != null) {
            FirebaseApp.initializeApp(context, options, name);
          } else {
            FirebaseApp.initializeApp(context, options);
          }
          result.success(null);
          break;
        }
      case "FirebaseApp#allApps":
        {
          List<Map<String, Object>> apps = new ArrayList<>();
          Map<String, Object> appMap = new HashMap<>();
          for (FirebaseApp app : FirebaseApp.getApps(context)) {
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
            apps.add(appMap);
          }
          result.success(apps);
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
