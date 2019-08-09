package io.flutter.plugins.instrumentationtest;

import androidx.test.rule.ActivityTestRule;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.view.FlutterView;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;
import org.junit.runner.Description;
import org.junit.runner.Runner;
import org.junit.runner.notification.Failure;
import org.junit.runner.notification.RunNotifier;

public class FlutterRunner extends Runner {

  private static final String CHANNEL = "dev.flutter/InstrumentationTestFlutterBinding";
  CompletableFuture<Map<String, String>> testResults;

  final Class activityClass;

  public FlutterRunner(Class<?> klass) {
    activityClass = klass;
    ActivityTestRule<FlutterActivity> rule = new ActivityTestRule<>(activityClass);
    FlutterActivity activity = rule.launchActivity(null);
    FlutterView view = activity.getFlutterView();
    MethodChannel methodChannel = new MethodChannel(view, CHANNEL);
    testResults = new CompletableFuture<>();
    methodChannel.setMethodCallHandler(
        new MethodCallHandler() {
          @Override
          public void onMethodCall(MethodCall call, Result result) {
            if (call.method.equals("testFinished")) {
              Map<String, String> results = call.argument("results");
              testResults.complete(results);
              result.success(null);
            } else {
              result.notImplemented();
            }
          }
        });
  }

  @Override
  public Description getDescription() {
    return Description.createTestDescription(activityClass, "Flutter Tests");
  }

  @Override
  public void run(RunNotifier notifier) {
    Map<String, String> results = null;
    try {
      results = testResults.get();
    } catch (ExecutionException e) {
      e.printStackTrace();
    } catch (InterruptedException e) {
      e.printStackTrace();
    }

    for (String name : results.keySet()) {
      Description d = Description.createTestDescription(activityClass, name);
      notifier.fireTestStarted(d);
      String outcome = results.get(name);
      if (outcome.equals("failed")) {
        Exception dummyException = new Exception(outcome);
        notifier.fireTestFailure(new Failure(d, dummyException));
      }
      notifier.fireTestFinished(d);
    }
  }
}
