package io.flutter.plugins.firebase.crashlytics.firebasecrashlytics;

import android.util.Log;
import com.crashlytics.android.Crashlytics;
import io.fabric.sdk.android.Fabric;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/** FirebaseCrashlyticsPlugin */
public class FirebaseCrashlyticsPlugin implements MethodCallHandler {

  public static final String TAG = "CrashlyticsPlugin";

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_crashlytics");
    channel.setMethodCallHandler(new FirebaseCrashlyticsPlugin());

    if (!Fabric.isInitialized()) {
      Fabric.with(registrar.context(), new Crashlytics());
    }
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("Crashlytics#onError")) {
      // Add logs.
      List<String> logs = call.argument("logs");
      for (String log : logs) {
        Crashlytics.log(log);
      }

      // Set keys.
      List<Map<String, Object>> keys = call.argument("keys");
      for (Map<String, Object> key : keys) {
        switch ((String) key.get("type")) {
          case "int":
            Crashlytics.setInt((String) key.get("key"), (int) key.get("value"));
            break;
          case "double":
            Crashlytics.setDouble((String) key.get("key"), (double) key.get("value"));
            break;
          case "string":
            Crashlytics.setString((String) key.get("key"), (String) key.get("value"));
            break;
          case "boolean":
            Crashlytics.setBool((String) key.get("key"), (boolean) key.get("value"));
            break;
        }
      }

      // Report crash.
      Exception exception = new Exception("Dart Error");
      List<Map<String, String>> errorElements = call.argument("stackTraceElements");
      List<StackTraceElement> elements = new ArrayList<>();
      for (Map<String, String> errorElement : errorElements) {
        StackTraceElement stackTraceElement = generateStackTraceElement(errorElement);
        if (stackTraceElement != null) {
          elements.add(stackTraceElement);
        }
      }
      exception.setStackTrace(elements.toArray(new StackTraceElement[elements.size()]));

      Crashlytics.setString("exception", (String) call.argument("exception"));
      Crashlytics.logException(exception);
      result.success("Error reported to Crashlytics.");
    } else if (call.method.equals("Crashlytics#isDebuggable")) {
      result.success(Fabric.isDebuggable());
    } else if (call.method.equals("Crashlytics#getVersion")) {
      result.success(Crashlytics.getInstance().getVersion());
    } else if (call.method.equals("Crashlytics#setUserEmail")) {
      Crashlytics.setUserEmail((String) call.argument("email"));
      result.success(null);
    } else if (call.method.equals("Crashlytics#setUserIdentifier")) {
      Crashlytics.setUserIdentifier((String) call.argument("identifier"));
      result.success(null);
    } else if (call.method.equals("Crashlytics#setUserName")) {
      Crashlytics.setUserName((String) call.argument("name"));
      result.success(null);
    } else {
      result.notImplemented();
    }
  }

  /**
   * Extract StackTraceElement from Dart stack trace element.
   *
   * @param errorElement Map representing the parts of a Dart error.
   * @return Stack trace element to be used as part of an Exception stack trace.
   */
  private StackTraceElement generateStackTraceElement(Map<String, String> errorElement) {
    try {
      String fileName = errorElement.get("file");
      String lineNumber = errorElement.get("line");
      String className = errorElement.get("class");
      String methodName = errorElement.get("method");

      return new StackTraceElement(className, methodName, fileName, Integer.parseInt(lineNumber));
    } catch (Exception e) {
      Log.e(TAG, "Unable to generate stack trace element from Dart side error.");
      return null;
    }
  }
}
