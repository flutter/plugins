/*
 * Copyright (C) 2019 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.example.espresso_example;

//import static androidx.test.espresso.flutter.EspressoFlutter.onFlutterWidget;
//import static androidx.test.espresso.flutter.action.FlutterActions.click;
//import static androidx.test.espresso.flutter.action.FlutterActions.syntheticClick;
//import static androidx.test.espresso.flutter.assertion.FlutterAssertions.matches;
//import static androidx.test.espresso.flutter.matcher.FlutterMatchers.isDescendantOf;
//import static androidx.test.espresso.flutter.matcher.FlutterMatchers.withText;
//import static androidx.test.espresso.flutter.matcher.FlutterMatchers.withTooltip;
//import static androidx.test.espresso.flutter.matcher.FlutterMatchers.withType;
//import static androidx.test.espresso.flutter.matcher.FlutterMatchers.withValueKey;
import static com.google.common.truth.Truth.assertThat;
import static org.junit.Assert.fail;

import androidx.test.core.app.ActivityScenario;
//import androidx.test.espresso.flutter.EspressoFlutter.WidgetInteraction;
//import androidx.test.espresso.flutter.assertion.FlutterAssertions;
//import androidx.test.espresso.flutter.matcher.FlutterMatchers;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

/** Unit tests for {@link EspressoFlutter}. */
@RunWith(AndroidJUnit4.class)
public class MainActivityTest {

    @Before
    public void setUp() throws Exception {
        ActivityScenario.launch(MainActivity.class);
    }

    @Test
    public void performTripleClick() {
//        WidgetInteraction interaction =
//                onFlutterWidget(withTooltip("Increment")).perform(click(), click()).perform(click());
//        assertThat(interaction).isNotNull();
//        onFlutterWidget(withValueKey("CountText")).check(matches(withText("Button tapped 3 times.")));
//        onFlutterWidget(withValueKey("CountRichText"))
//                .check(matches(withText("Button tapped 3 times.")));
    }

    @Test
    public void performSyntheticClick() {
//        WidgetInteraction interaction =
//                onFlutterWidget(withTooltip("Increment")).perform(syntheticClick());
//        assertThat(interaction).isNotNull();
//        onFlutterWidget(withValueKey("CountText")).check(matches(withText("Button tapped 1 time.")));
//        onFlutterWidget(withValueKey("CountRichText"))
//                .check(matches(withText("Button tapped 1 time.")));
    }

    @Test
    public void performTwiceSyntheticClicks() {
//        WidgetInteraction interaction =
//                onFlutterWidget(withTooltip("Increment")).perform(syntheticClick(), syntheticClick());
//        assertThat(interaction).isNotNull();
//        onFlutterWidget(withValueKey("CountText")).check(matches(withText("Button tapped 2 times.")));
//        onFlutterWidget(withValueKey("CountRichText"))
//                .check(matches(withText("Button tapped 2 times.")));
    }

    @Test
    public void isDescendantMatcher() {
//        onFlutterWidget(withTooltip("Increment")).perform(click());
//        onFlutterWidget(isDescendantOf(withValueKey("TwoTimesCounterContainer"), withType("Text")))
//                .check(matches(withText("Button tapped 2 times.")));
    }

    @Test
    public void isDescendantMatcher_multipleMatches() {
//        onFlutterWidget(withTooltip("Increment")).perform(click());
//        try {
//            onFlutterWidget(isDescendantOf(withType("ListView"), withType("Text")))
//                    .check(matches(withText("Button tapped 2 times.")));
//            fail("Espresso should fail when there are more than one matched widgets.");
//        } catch (Exception e) {
//            assertThat(e)
//                    .hasCauseThat()
//                    .hasMessageThat()
//                    .contains("Error occurred during retrieving widget's diagnostics info.");
//        }
    }

    @Test
    public void isIncrementButtonExists() {
//        onFlutterWidget(FlutterMatchers.withTooltip("Increment"))
//                .check(FlutterAssertions.matches(FlutterMatchers.isExisting()));
    }

    @Test
    public void isAppBarExists() {
//        onFlutterWidget(FlutterMatchers.withType("AppBar"))
//                .check(FlutterAssertions.matches(FlutterMatchers.isExisting()));
    }

    @Test
    public void isWidgetNonExists() {
//        try {
//            onFlutterWidget(FlutterMatchers.withType("AppBar2"))
//                    .check(FlutterAssertions.matches(FlutterMatchers.isExisting()));
//            fail("Espresso should fail when none of the widgets matches the given matcher.");
//        } catch (Exception e) {
//            assertThat(e)
//                    .hasCauseThat()
//                    .hasMessageThat()
//                    .contains("Error occurred during retrieving widget's diagnostics info.");
//        }
    }
}