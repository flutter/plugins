package dev.flutter.plugins.instrumentationadapter;

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

  public FlutterRunner(Class<FlutterActivity> activityClass) {
    super();
    Class mainClass = activityClass.getSuperclass();
    ActivityTestRule<FlutterActivity> rule = new ActivityTestRule<>(mainClass);
    FlutterActivity activity = rule.launchActivity(null);
  }

  @Override
  public Description getDescription() {
    return Description.createTestDescription(FlutterRunner.class, "Flutter Tests");
  }

  @Override
  public void run(RunNotifier notifier) {
    Map<String, String> results = null;
    try {
      results = InstrumentationAdapterPlugin.testResults.get();
    } catch (ExecutionException | InterruptedException e) {
      throw new IllegalThreadStateException("Unable to get test results");
    }

    for (String name : results.keySet()) {
      Description d = Description.createTestDescription(FlutterRunner.class, name);
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
