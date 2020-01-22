// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.androidalarmmanagerexample;

import static androidx.test.espresso.Espresso.pressBackUnconditionally;
import static androidx.test.espresso.flutter.EspressoFlutter.onFlutterWidget;
import static androidx.test.espresso.flutter.action.FlutterActions.click;
import static androidx.test.espresso.flutter.matcher.FlutterMatchers.withValueKey;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import android.app.Activity;
import android.util.Log;
import android.view.View;
import androidx.test.core.app.ActivityScenario;
import androidx.test.core.app.ApplicationProvider;
import androidx.test.espresso.UiController;
import androidx.test.espresso.flutter.action.WidgetInfoFetcher;
import androidx.test.espresso.flutter.api.FlutterTestingProtocol;
import androidx.test.espresso.flutter.api.WidgetAction;
import androidx.test.espresso.flutter.api.WidgetMatcher;
import androidx.test.espresso.flutter.assertion.FlutterAssertions;
import androidx.test.espresso.flutter.matcher.FlutterMatchers;
import androidx.test.espresso.flutter.model.WidgetInfo;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.rule.ActivityTestRule;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Future;
import javax.annotation.Nonnull;
import javax.annotation.Nullable;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(AndroidJUnit4.class)
public class AlarmManagerTest {

  // Helper class to retrieve the integer value of a Text widget.
  private class CountValueFetcher implements WidgetAction {
    @Override
    public Future<Void> perform(
        @Nullable WidgetMatcher targetWidget,
        @Nonnull View flutterView,
        @Nonnull FlutterTestingProtocol flutterTestingProtocol,
        @Nonnull UiController androidUiController) {
      try {
        WidgetInfo result = new WidgetInfoFetcher().perform(targetWidget,
                                                            flutterView,
                                                            flutterTestingProtocol,
                                                            androidUiController).get();
        count = Integer.parseInt(result.getText());
      } finally {
        CompletableFuture<Void> future = new CompletableFuture<>();
        future.complete(null);
        return future;
      }
    }

    public int getCount() {
      return count;
    }

    private int count;
  }

  // TODO(bkonyi): uncomment
  /*
  @Rule
  public ActivityTestRule<MainActivity> myActivityTestRule =
      new ActivityTestRule<>(MainActivity.class, true, false);
  */

  @Before
  public void setUp() throws Exception {
    ActivityScenario.launch(MainActivity.class);
  }

  @Test
  public void startBackgroundIsolate() throws Exception {
    // TODO(bkonyi): uncomment
    /*
    CountValueFetcher fetcher = new CountValueFetcher();
    onFlutterWidget(withValueKey("RegisterAlarms")).perform(click());
    onFlutterWidget(withValueKey("BackgroundCountText")).perform(fetcher);
    Log.e("TEST", "Result: " + fetcher.getCount());
    int originalCount = fetcher.getCount();
    //pressBackUnconditionally();
    //Thread.sleep(40000);
    //myActivityTestRule.launchActivity(null);
    onFlutterWidget(withValueKey("BackgroundCountText")).perform(fetcher);
    Log.e("TEST", "Result: " + fetcher.getCount());
    assertTrue(fetcher.getCount() > originalCount);
    */
  }

  // TODO(bkonyi): uncomment?
  /*
  @After
  public void shutdown() {
    Log.e("TEST", "SHUTDOWN");
    myActivityTestRule.finishActivity();
  }
  */
}
