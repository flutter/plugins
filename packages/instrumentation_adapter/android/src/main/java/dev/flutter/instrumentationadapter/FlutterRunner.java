// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.plugins.instrumentationadapter;

import android.app.Activity;
import androidx.test.rule.ActivityTestRule;
import java.lang.reflect.Field;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import org.junit.Rule;
import org.junit.runner.Description;
import org.junit.runner.Runner;
import org.junit.runner.notification.Failure;
import org.junit.runner.notification.RunNotifier;

public class FlutterRunner extends Runner {

  final Class testClass;

  public FlutterRunner(Class<?> testClass) {
    super();
    this.testClass = testClass;

    // Look for an `ActivityTestRule` annotated `@Rule` and invoke `launchActivity()`
    Field[] fields = testClass.getDeclaredFields();
    for (Field field : fields) {
      if (field.isAnnotationPresent(Rule.class)) {
        try {
          Object instance = testClass.newInstance();
          ActivityTestRule<Activity> rule = (ActivityTestRule<Activity>) field.get(instance);
          rule.launchActivity(null);
        } catch (InstantiationException | IllegalAccessException e) {
          // This might occur if the developer did not make the rule public.
          // We could call field.setAccessible(true) but it seems better to throw.
          throw new RuntimeException("Unable to access activity rule", e);
        }
      }
    }
  }

  @Override
  public Description getDescription() {
    return Description.createTestDescription(testClass, "Flutter Tests");
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
      Description d = Description.createTestDescription(testClass, name);
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
