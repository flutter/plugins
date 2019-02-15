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

/** FirebaseCrashlyticsPlugin */
public class FirebaseCrashlyticsPlugin implements MethodCallHandler {

  public static final String TAG = "CrashlyticsPlugin";

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_crashlytics");
    channel.setMethodCallHandler(new FirebaseCrashlyticsPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("Crashlytics#onError")) {
      Exception exception = new Exception("Dart Error");
      List<String> lines = (List<String>) call.argument("stackTraceLines");
      List<StackTraceElement> elements = new ArrayList<>();
      for (String line : lines) {
        StackTraceElement stackTraceElement = generateStackTraceElement(line);
        if (stackTraceElement != null) {
          elements.add(stackTraceElement);
        }
      }
      exception.setStackTrace(elements.toArray(new StackTraceElement[elements.size()]));

      Crashlytics.setString("exception", (String) call.argument("exception"));
      Crashlytics.setString("stackTrace", (String) call.argument("stackTrace"));
      Crashlytics.logException(exception);
      result.success("Error reported to Crashlytics.");
    } else if (call.method.equals("Crashlytics#isDebuggable")) {
      result.success(Fabric.isDebuggable());
    } else if (call.method.equals("Crashlytics#getVersion")) {
      result.success(Crashlytics.getInstance().getVersion());
    } else if (call.method.equals("Crashlytics#setInt")) {
      Crashlytics.setInt((String) call.argument("key"), (int) call.argument("value"));
      result.success(null);
    } else if (call.method.equals("Crashlytics#setDouble")) {
      Crashlytics.setDouble((String) call.argument("key"), (double) call.argument("value"));
      result.success(null);
    } else if (call.method.equals("Crashlytics#setString")) {
      Crashlytics.setString((String) call.argument("key"), (String) call.argument("value"));
      result.success(null);
    } else if (call.method.equals("Crashlytics#setBool")) {
      Crashlytics.setBool((String) call.argument("key"), (boolean) call.argument("value"));
      result.success(null);
    } else if (call.method.equals("Crashlytics#log")) {
      Crashlytics.log((String) call.argument("msg"));
      result.success(null);
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
   * Extract StackTraceElement from line from Dart stack trace. Incoming line is expected in the
   * following format:
   *
   * <p>FILE_PATH LINE_NUMBER:CHARACTER_NUMBER METHOD_NAME
   *
   * @param line Line from Dart stack trace.
   * @return Stack trace element to be used as part of an Exception stack trace.
   */
  private StackTraceElement generateStackTraceElement(String line) {
    try {
      // Split line on white spaces.
      String[] lineParts = line.split("\\s+");
      String fileName = lineParts[0].trim();
      String lineNumber = lineParts[1].substring(0, lineParts[1].indexOf(":")).trim();
      String className = lineParts[2].substring(0, lineParts[2].indexOf(".")).trim();
      String methodName = lineParts[2].substring(lineParts[2].indexOf(".") + 1).trim();

      return new StackTraceElement(className, methodName, fileName, Integer.parseInt(lineNumber));
    } catch (Exception e) {
      Log.e(TAG, "Unable to generate stack trace element from: " + line);
      return null;
    }
  }
}
