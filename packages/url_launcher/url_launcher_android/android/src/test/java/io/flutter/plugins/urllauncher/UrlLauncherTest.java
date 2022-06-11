// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.urllauncher;

import static org.junit.Assert.assertEquals;
import static org.mockito.Matchers.any;
import static org.mockito.Matchers.anyInt;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.os.Build;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentMatcher;
import org.mockito.Matchers;
import org.robolectric.RobolectricTestRunner;

import java.util.Arrays;
import java.util.Collections;

import io.flutter.plugins.urllauncher.utils.IntentDataMatcher;
import io.flutter.plugins.urllauncher.utils.TestUtils;

@RunWith(RobolectricTestRunner.class)
public class UrlLauncherTest {
  private Context applicationContext;
  private UrlLauncher urlLauncher;

  private static final String LAUNCH_URL = "https://www.google.com";

  @Before
  public void setUp() {
    applicationContext = mock(Context.class);
    Activity activity = mock(Activity.class);
    urlLauncher = new UrlLauncher(applicationContext, activity);
  }

  @Test
  public void launch_shouldNotQueryPackageManagerWhenUniversalLinksOnlyOnAndroidR() {
    updateSdkVersion(Build.VERSION_CODES.R);

    try {
      PackageManager mockPackageManager = mock(PackageManager.class);
      when(applicationContext.getPackageManager()).thenReturn(mockPackageManager);

      urlLauncher.launch(LAUNCH_URL, null, false, false, false, true);

      verify(mockPackageManager, never()).queryIntentActivities(any(Intent.class), anyInt());
    } finally {
      updateSdkVersion(0);
    }
  }

  @Test
  public void launch_shouldReturnOkWhenUniversalLinksOnlyBelowAndroidRAndNonBrowserPresent() {
    updateSdkVersion(Build.VERSION_CODES.Q);

    try {
      PackageManager mockPackageManager = mock(PackageManager.class);
      when(applicationContext.getPackageManager()).thenReturn(mockPackageManager);
      ResolveInfo browserIntentActivity = stubResolveInfo("browser");
      ResolveInfo nonBrowserIntentActivity = stubResolveInfo("nonBrowser");
      when(mockPackageManager.queryIntentActivities(any(Intent.class), anyInt()))
          .thenReturn(Collections.singletonList(browserIntentActivity));
      when(mockPackageManager.queryIntentActivities(
              Matchers.argThat(new IntentDataMatcher(LAUNCH_URL)), anyInt()))
          .thenReturn(Arrays.asList(nonBrowserIntentActivity, browserIntentActivity));

      UrlLauncher.LaunchStatus launchStatus =
          urlLauncher.launch(LAUNCH_URL, null, false, false, false, true);

      verify(mockPackageManager, times(2)).queryIntentActivities(any(Intent.class), anyInt());
      assertEquals(launchStatus, UrlLauncher.LaunchStatus.OK);
    } finally {
      updateSdkVersion(0);
    }
  }

  @Test
  public void
      launch_shouldReturnActivityNotFoundWhenUniversalLinksOnlyBelowAndroidRAndNonBrowserNotPresent() {
    updateSdkVersion(Build.VERSION_CODES.Q);

    try {
      PackageManager mockPackageManager = mock(PackageManager.class);
      when(applicationContext.getPackageManager()).thenReturn(mockPackageManager);
      ResolveInfo browserIntentActivity = stubResolveInfo("browser");
      when(mockPackageManager.queryIntentActivities(any(Intent.class), anyInt()))
          .thenReturn(Collections.singletonList(browserIntentActivity));
      when(mockPackageManager.queryIntentActivities(
              Matchers.argThat(new IntentDataMatcher(LAUNCH_URL)), anyInt()))
          .thenReturn(Collections.singletonList(browserIntentActivity));

      UrlLauncher.LaunchStatus launchStatus =
          urlLauncher.launch(LAUNCH_URL, null, false, false, false, true);

      verify(mockPackageManager, times(2)).queryIntentActivities(any(Intent.class), anyInt());
      assertEquals(launchStatus, UrlLauncher.LaunchStatus.ACTIVITY_NOT_FOUND);
    } finally {
      updateSdkVersion(0);
    }
  }

  private static ResolveInfo stubResolveInfo(String packageName) {
    ResolveInfo resolveInfo = new ResolveInfo();
    resolveInfo.activityInfo = new ActivityInfo();
    resolveInfo.activityInfo.packageName = packageName;
    return resolveInfo;
  }

  private static void updateSdkVersion(int version) {
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", version);
  }
}
