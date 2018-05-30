package io.flutter.plugins.firebase.functions.firebasefunctions;

import android.support.annotation.NonNull;
import android.util.Log;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.functions.FirebaseFunctions;
import com.google.firebase.functions.FirebaseFunctionsException;
import com.google.firebase.functions.HttpsCallableReference;
import com.google.firebase.functions.HttpsCallableResult;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FirebaseFunctionsPlugin
 */
public class FirebaseFunctionsPlugin implements MethodCallHandler {
  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "firebase_functions");
    channel.setMethodCallHandler(new FirebaseFunctionsPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    switch(call.method) {
        case "FirebaseFunctions#call":
            String functionName = call.argument("functionName");
            HttpsCallableReference httpsCallableReference = FirebaseFunctions.getInstance().getHttpsCallable(functionName);
            Map<String, Object> parameters = call.argument("parameters");
            httpsCallableReference.call(parameters)
                    .addOnCompleteListener(new OnCompleteListener<HttpsCallableResult>() {
                        @Override
                        public void onComplete(@NonNull Task<HttpsCallableResult> task) {
                            if (task.isSuccessful()) {
                                result.success(task.getResult().getData());
                            } else {
                                if (task.getException() instanceof FirebaseFunctionsException) {
                                    FirebaseFunctionsException exception = (FirebaseFunctionsException) task.getException();
                                    Map<String, Object> exceptionMap = new HashMap<>();
                                    exceptionMap.put("code", exception.getCode().name());
                                    exceptionMap.put("message", exception.getMessage());
                                    exceptionMap.put("details", exception.getDetails());
                                    result.error("functionsError", "Firebase function failed with exception.", exceptionMap);
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
