// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.file_selector_example;

import static android.content.Intent.ACTION_GET_CONTENT;
import static android.content.Intent.ACTION_OPEN_DOCUMENT_TREE;
import static android.content.Intent.CATEGORY_OPENABLE;
import static android.content.Intent.EXTRA_ALLOW_MULTIPLE;
import static android.content.Intent.EXTRA_MIME_TYPES;
import static androidx.test.espresso.flutter.EspressoFlutter.onFlutterWidget;
import static androidx.test.espresso.flutter.action.FlutterActions.click;
import static androidx.test.espresso.flutter.assertion.FlutterAssertions.matches;
import static androidx.test.espresso.flutter.matcher.FlutterMatchers.isExisting;
import static androidx.test.espresso.flutter.matcher.FlutterMatchers.withText;
import static androidx.test.espresso.intent.Intents.intended;
import static androidx.test.espresso.intent.Intents.intending;
import static androidx.test.espresso.intent.matcher.IntentMatchers.hasAction;
import static androidx.test.espresso.intent.matcher.IntentMatchers.hasCategories;
import static androidx.test.espresso.intent.matcher.IntentMatchers.hasExtra;
import static org.hamcrest.CoreMatchers.allOf;

import android.app.Activity;
import android.app.Instrumentation;
import android.content.ClipData;
import android.content.Intent;
import android.net.Uri;
import androidx.test.core.app.ActivityScenario;
import androidx.test.espresso.intent.Intents;
import androidx.test.ext.junit.rules.ActivityScenarioRule;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(AndroidJUnit4.class)
public class MainActivityTest {
  @Rule
  public ActivityScenarioRule<MainActivity> mActivityScenarioRule =
      new ActivityScenarioRule<>(MainActivity.class);

  @Before
  public void setUp() throws Exception {
    Intents.init();
  }

  @After
  public void tearDown() {
    Intents.release();
  }

  @Test
  public void openATextFile_should_show_theFilePathAndContent_InADialog() throws IOException {
    // Arrange
    ActivityScenario<MainActivity> scenario = mActivityScenarioRule.getScenario();

    String fileName = RandomString.generate(8) + "-exampleFile.txt";
    RandomFile randomFile = new RandomFile(fileName);
    randomFile.writeGeneratedContentToFile();

    stubOpenDocumentIntent(randomFile);

    // Act
    onFlutterWidget(withText("Open a text file")).perform(click());
    onFlutterWidget(withText("Press to open a text file (json, txt)")).perform(click());

    // Assert
    intended(
        allOf(
            hasAction(ACTION_GET_CONTENT),
            hasCategories(Collections.singleton(CATEGORY_OPENABLE)),
            hasExtra(EXTRA_ALLOW_MULTIPLE, false),
            hasExtra(EXTRA_MIME_TYPES, new String[] {"text/plain", "application/json"})));
    onFlutterWidget(withText(fileName)).check(matches(isExisting()));
    onFlutterWidget(withText(randomFile.readFromFile())).check(matches(isExisting()));

    // Cleanup
    scenario.close();
    randomFile.delete();
  }

  @Test
  public void openAnImage_should_show_theImageFileName_InADialog() throws IOException {
    // Arrange
    ActivityScenario<MainActivity> scenario = mActivityScenarioRule.getScenario();

    String fileName = RandomString.generate(8) + "-exampleImageFile.png";
    RandomFile randomFile = new RandomFile(fileName);
    randomFile.writeGeneratedContentToFile();

    stubOpenDocumentIntent(randomFile);

    // Act
    onFlutterWidget(withText("Open an image")).perform(click());
    onFlutterWidget(withText("Press to open an image file (png, jpg)")).perform(click());

    // Assert
    intended(
        allOf(
            hasAction(ACTION_GET_CONTENT),
            hasCategories(Collections.singleton(CATEGORY_OPENABLE)),
            hasExtra(EXTRA_ALLOW_MULTIPLE, false),
            hasExtra(EXTRA_MIME_TYPES, new String[] {"image/jpeg", "image/png"})));
    onFlutterWidget(withText(fileName)).check(matches(isExisting()));

    // Cleanup
    scenario.close();
    randomFile.delete();
  }

  @Test
  public void openMultipleImages_should_show_theGalleryDialog() throws IOException {
    // Arrange
    ActivityScenario<MainActivity> scenario = mActivityScenarioRule.getScenario();

    String fileNameA = RandomString.generate(8) + "-exampleImageFileA.png";
    RandomFile randomImageA = new RandomFile(fileNameA);
    randomImageA.writeGeneratedContentToFile();

    String fileNameB = RandomString.generate(8) + "-exampleImageFileB.png";
    RandomFile randomImageB = new RandomFile(fileNameB);
    randomImageB.writeGeneratedContentToFile();

    List<RandomFile> fileList = new ArrayList<>();
    fileList.add(randomImageA);
    fileList.add(randomImageB);
    stubOpenMultipleDocumentsIntent(fileList);

    // Act
    onFlutterWidget(withText("Open multiple images")).perform(click());
    onFlutterWidget(withText("Press to open multiple images (png, jpg)")).perform(click());

    // Assert
    intended(
        allOf(
            hasAction(ACTION_GET_CONTENT),
            hasCategories(Collections.singleton(CATEGORY_OPENABLE)),
            hasExtra(EXTRA_ALLOW_MULTIPLE, true),
            hasExtra(EXTRA_MIME_TYPES, new String[] {"image/jpeg", "image/png"})));
    onFlutterWidget(withText("Gallery")).check(matches(isExisting()));

    // Cleanup
    scenario.close();
    randomImageB.delete();
    randomImageA.delete();
  }

  @Test
  public void openDirectoryDialog_should_ReturnThePath() throws IOException {
    // Arrange
    ActivityScenario<MainActivity> scenario = mActivityScenarioRule.getScenario();

    String pathUri = "content://path/to/directory";
    Intent openDirectoryIntentResult = new Intent().setData(Uri.parse(pathUri));
    Instrumentation.ActivityResult result =
        new Instrumentation.ActivityResult(Activity.RESULT_OK, openDirectoryIntentResult);
    intending(hasAction(ACTION_OPEN_DOCUMENT_TREE)).respondWith(result);

    // Act
    onFlutterWidget(withText("Open a get directory dialog")).perform(click());
    onFlutterWidget(withText("Press to ask user to choose a directory")).perform(click());

    // Assert
    intended(hasAction(ACTION_OPEN_DOCUMENT_TREE));
    onFlutterWidget(withText(pathUri)).check(matches(isExisting()));

    // Cleanup
    scenario.close();
  }

  private void stubOpenDocumentIntent(RandomFile randomFile) {
    Intent openFileIntentResult =
        new Intent()
            .setData(randomFile.getUriFromFileProvider())
            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            .addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
    Instrumentation.ActivityResult result =
        new Instrumentation.ActivityResult(Activity.RESULT_OK, openFileIntentResult);
    intending(hasAction(ACTION_GET_CONTENT)).respondWith(result);
  }

  private void stubOpenMultipleDocumentsIntent(List<RandomFile> filesToReturn) {
    ClipData clip = ClipData.newRawUri("fileA", filesToReturn.get(0).getUriFromFileProvider());
    filesToReturn.remove(0);
    for (RandomFile file : filesToReturn) {
      clip.addItem(new ClipData.Item(file.getUriFromFileProvider()));
    }

    Intent openFileIntentResult =
        new Intent()
            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            .addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
    openFileIntentResult.setClipData(clip);
    Instrumentation.ActivityResult result =
        new Instrumentation.ActivityResult(Activity.RESULT_OK, openFileIntentResult);
    intending(hasAction(ACTION_GET_CONTENT)).respondWith(result);
  }
}
