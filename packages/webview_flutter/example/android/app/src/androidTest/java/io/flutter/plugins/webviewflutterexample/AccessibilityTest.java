package io.flutter.plugins.webviewflutterexample;

import static org.junit.Assert.assertEquals;

import android.app.Instrumentation;
import android.os.Bundle;
import androidx.test.InstrumentationRegistry;
import androidx.test.rule.ActivityTestRule;
import io.flutter.plugins.webviewflutterexample.MainActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.view.FlutterView;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import java.util.concurrent.ExecutionException;
import org.junit.runners.BlockJUnit4ClassRunner;

import static androidx.test.espresso.Espresso.onView;
import static androidx.test.espresso.action.ViewActions.click;
import static androidx.test.espresso.assertion.ViewAssertions.matches;
import static androidx.test.espresso.matcher.ViewMatchers.isDisplayed;
import static androidx.test.espresso.matcher.ViewMatchers.withText;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;

import static androidx.test.core.app.ApplicationProvider.getApplicationContext;
import static androidx.test.platform.app.InstrumentationRegistry.getInstrumentation;
import androidx.test.filters.SdkSuppress;
import androidx.test.uiautomator.By;
import androidx.test.uiautomator.UiDevice;
import androidx.test.uiautomator.UiObject2;
import androidx.test.uiautomator.Until;
import androidx.test.uiautomator.UiObject;
import androidx.test.uiautomator.UiSelector;
import androidx.test.uiautomator.UiObjectNotFoundException;

import static org.hamcrest.CoreMatchers.equalTo;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.junit.Assert.assertThat;
import android.widget.Button;

@RunWith(BlockJUnit4ClassRunner.class)
public class AccessibilityTest {

    @Before
    public void setUp() {
      mDevice = UiDevice.getInstance(getInstrumentation());
    }

    private UiDevice mDevice;

    @Test
    public void checkPreconditions() {
        assertThat(mDevice, notNullValue());
    }

    @Test
    public void testAccessibility() throws UiObjectNotFoundException {
        final int timeOut = 1000 * 5;
        // TODO: We shouldn't have to use a timeOut ideally

        UiObject button = mDevice.findObject(new UiSelector().descriptionContains("Simple button"));
        button.waitForExists(timeOut);
        button.click();

        // TODO: Wait for some result to be displayed
    }
}
