// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.cloudfunctions.cloudfunctions;

import androidx.annotation.NonNull;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.FirebaseApp;
import com.google.firebase.functions.FirebaseFunctions;
import com.google.firebase.functions.FirebaseFunctionsException;
import com.google.firebase.functions.HttpsCallableReference;
import com.google.firebase.functions.HttpsCallableResult;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.HashMap;
import java.util.Map;

/** CloudFunctionsPlugin */
public class CloudFunctionsPlugin implements MethodCallHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "cloud_functions");
    channel.setMethodCallHandler(new CloudFunctionsPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    switch (call.method) {
      case "CloudFunctions#call":
        String functionName = call.argument("functionName");
        Map<String, Object> parameters = call.argument("parameters");
        String appName = call.argument("app");
        FirebaseApp app = FirebaseApp.getInstance(appName);
        String region = call.argument("region");
        FirebaseFunctions functions;
        if (region != null) {
          functions = FirebaseFunctions.getInstance(app, region);
        } else {
          functions = FirebaseFunctions.getInstance(app);
        }
        HttpsCallableReference httpsCallableReference = functions.getHttpsCallable(functionName);
        httpsCallableReference
            .call(parameters)
            .addOnCompleteListener(
                new OnCompleteListener<HttpsCallableResult>() {
                  @Override
                  public void onComplete(@NonNull Task<HttpsCallableResult> task) {
                    if (task.isSuccessful()) {
                      result.success(task.getResult().getData());
                    } else {
                      if (task.getException() instanceof FirebaseFunctionsException) {
                        FirebaseFunctionsException exception =
                            (FirebaseFunctionsException) task.getException();
                        Map<String, Object> exceptionMap = new HashMap<>();
                        exceptionMap.put("code", exception.getCode().name());
                        exceptionMap.put("message", exception.getMessage());
                        exceptionMap.put("details", exception.getDetails());
                        result.error(
                            "functionsError",
                            "Cloud function failed with exception.",
                            exceptionMap);
                      } else {
                        Exception exception = task.getException();
                        result.error(null, exception.getMessage(), null);
                      }
                    }
                  }
                });
        break;
      default:
        result.notImplemented();
    }
  }
}
