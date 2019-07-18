package io.flutter.plugins.urllauncherexample;

import static org.junit.Assert.assertThat;
import static org.hamcrest.CoreMatchers.notNullValue;

import android.app.Instrumentation;
import androidx.test.rule.ActivityTestRule;
import androidx.test.uiautomator.By;
import androidx.test.uiautomator.UiDevice;
import androidx.test.uiautomator.Until;
import androidx.test.InstrumentationRegistry;
import androidx.test.runner.AndroidJUnit4;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(AndroidJUnit4.class)
public class UiAutomatorTest {
    private Instrumentation instrumentation = InstrumentationRegistry.getInstrumentation();
    private UiDevice device = UiDevice.getInstance(instrumentation);
    private static final int LAUNCH_TIMEOUT = 5000;

    @Rule
    public ActivityTestRule<MainActivity> activityTestRule =
            new ActivityTestRule<>(MainActivity.class);

    @Test
    public void launchInApp() {
        assertThat(device.wait(Until.hasObject(By.text("Launch in app")), LAUNCH_TIMEOUT), notNullValue());
        device.findObject(By.text("Launch in app")).click();
        assertThat(device.wait(Until.hasObject(By.text("HTTP Request Header Display")), LAUNCH_TIMEOUT), notNullValue());
        device.pressBack();
        assertThat(device.wait(Until.hasObject(By.text("Launch in app")), LAUNCH_TIMEOUT), notNullValue());
    }
}