package io.flutter.plugins.packageinfoexample;

import androidx.test.rule.ActivityTestRule;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.view.FlutterView;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;
import org.junit.runner.Description;
import org.junit.runner.Runner;
import org.junit.runner.notification.Failure;
import org.junit.runner.notification.RunNotifier;

// TODO(jackson): The test runner class should be included in Flutter engine.
public class FlutterJUnitRunner extends Runner {

    private static final String CHANNEL = "dev.flutter/InstrumentationTestFlutterBinding";
    CompletableFuture<Map<String, String>> testResults;

    public FlutterJUnitRunner(Class<?> klass) {
        ActivityTestRule<MainActivity> rule = new ActivityTestRule<>(MainActivity.class);
        MainActivity fa = rule.launchActivity(null);
        FlutterView fv = fa.getFlutterView();
        MethodChannel methodChannel = new MethodChannel(fv, CHANNEL);
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
        // TODO(jackson): Expose an API that allows developers to specify a custom string.
        return Description.createTestDescription(MainActivity.class, "Flutter Tests");
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
            Description d = Description.createTestDescription(MainActivity.class, name);
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
