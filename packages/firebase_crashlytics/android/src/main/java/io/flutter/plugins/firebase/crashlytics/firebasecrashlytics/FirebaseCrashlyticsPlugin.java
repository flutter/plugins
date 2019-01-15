package io.flutter.plugins.firebase.crashlytics.firebasecrashlytics;

import android.util.Log;

import com.crashlytics.android.Crashlytics;

import java.util.ArrayList;
import java.util.List;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FirebaseCrashlyticsPlugin */
public class FirebaseCrashlyticsPlugin implements MethodCallHandler {

  public static final String TAG = "CrashlyticsPlugin";

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_crashlytics");
    channel.setMethodCallHandler(new FirebaseCrashlyticsPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("Crashlytics#onError")) {
      Exception exception = new Exception("Dart Error");
      List<String> lines = (List<String>) call.argument("stackTraceLines");
      List<StackTraceElement> elements = new ArrayList<>();
      for (String line : lines) {
        elements.add(generateStackTraceElement(line));
      }
      exception.setStackTrace(elements.toArray(new StackTraceElement[elements.size()]));

      Crashlytics.setString("exception", (String) call.argument("exception"));
      Crashlytics.setString("stackTrace", (String) call.argument("stackTrace"));
      Crashlytics.logException(exception);
      result.success("Error logged");
    } else {
      result.notImplemented();
    }
  }

  private StackTraceElement generateStackTraceElement(String line) {
    // Get string before first dot on line
    String[] lineParts = line.split("\\s+");
    String fileName = lineParts[0].trim();
    String lineNumber = lineParts[1].trim().substring(0, lineParts[1].indexOf(":"));
    String className = lineParts[2].trim().substring(0, lineParts[2].indexOf("."));
    String methodName = lineParts[2].trim().substring(lineParts[2].indexOf(".") + 1);

    return new StackTraceElement(className,
                methodName,
                fileName,
                Integer.parseInt(lineNumber));
  }
}
