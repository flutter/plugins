package io.flutter.plugins.sharedpreferencesexample;

import static androidx.test.espresso.Espresso.pressBack;
import static androidx.test.espresso.Espresso.pressBackUnconditionally;
import static androidx.test.espresso.flutter.EspressoFlutter.onFlutterWidget;

import androidx.test.core.app.ActivityScenario;
import androidx.test.espresso.flutter.action.FlutterActions;
import androidx.test.espresso.flutter.assertion.FlutterAssertions;
import androidx.test.espresso.flutter.matcher.FlutterMatchers;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.rule.ActivityTestRule;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(AndroidJUnit4.class)
public final class SharedPreferencesIntegrationTest {

    @Before
    public void setUp() throws Exception {
        ActivityScenario.launch(MainActivity.class);
    }

    @Test
    public void tapToCheckPersistentData() throws Exception {
        onFlutterWidget(FlutterMatchers.withText("Shared Preferences Sample"))
                .perform(FlutterActions.click());
        onFlutterWidget(FlutterMatchers.withTooltip("Clear")).perform(FlutterActions.click());
        onFlutterWidget(FlutterMatchers.withTooltip("Increment")).perform(FlutterActions.click());
        onFlutterWidget(FlutterMatchers.withValueKey("ResultText"))
                .check(
                        FlutterAssertions.matches(
                                FlutterMatchers.withText(
                                        "Button tapped 1 time.\n\nThis should persist across restarts.")));
        // go back to main page
        pressBack();
        // close the application
        pressBackUnconditionally();
        // reopen the application
        ActivityScenario.launch(MainActivity.class);
        onFlutterWidget(FlutterMatchers.withText("Shared Preferences Sample"))
                .perform(FlutterActions.click());
        onFlutterWidget(FlutterMatchers.withValueKey("ResultText"))
                .check(
                        FlutterAssertions.matches(
                                FlutterMatchers.withText(
                                        "Button tapped 1 time.\n\nThis should persist across restarts.")));
    }
}