package io.flutter.plugins.firebase.crashlytics.firebasecrashlytics;

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
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_crashlytics");
    channel.setMethodCallHandler(new FirebaseCrashlyticsPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("Crashlytics#onError")) {
      Exception exception = new Exception("i am working");
      List<String> lines = (List<String>) call.argument("stackTrace");
      List<StackTraceElement> elements = new ArrayList<>();
      for (String line : lines) {
        elements.add(new StackTraceElement("SomeFlutterClass",
                "Some flutter method",
                "Some flutter file name",
                1));
      }
      exception.setStackTrace(elements.toArray(new StackTraceElement[elements.size()]));
      Crashlytics.getInstance().logException(exception);
      result.success("exception logged");
    } else {
      result.notImplemented();
    }
  }
}
