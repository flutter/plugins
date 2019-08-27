// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.plugins.instrumentationadapter;

import java.util.Map;
import java.util.concurrent.ExecutionException;
import org.junit.runner.Description;
import org.junit.runner.Runner;
import org.junit.runner.notification.Failure;
import org.junit.runner.notification.RunNotifier;

public class FlutterRunner extends Runner {

  final Class testClass;

  public FlutterRunner(Class<FlutterTest> testClass) {
    super();
    this.testClass = testClass;
    try {
      testClass.newInstance().launchActivity();
    } catch (InstantiationException | IllegalAccessException e) {
      throw new IllegalThreadStateException("Unable to launch test");
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
