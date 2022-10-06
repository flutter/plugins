// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.file_selector;

import static io.flutter.plugins.file_selector.TestHelpers.buildSelectionOptions;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.reset;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.app.Application;
import androidx.annotation.NonNull;
import androidx.lifecycle.Lifecycle;
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference;
import io.flutter.plugin.common.BinaryMessenger;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

public class FileSelectorPluginTest {
  final HashMap<String, ArrayList<String>> xTypeGroups = new HashMap<>();
  final ArrayList<String> mimeTypes = new ArrayList<String>();
  final HashMap<String, Boolean> multiple = new HashMap<>();

  @Mock io.flutter.plugin.common.PluginRegistry.Registrar mockRegistrar;
  @Mock ActivityPluginBinding mockActivityBinding;
  @Mock FlutterPluginBinding mockPluginBinding;
  @Mock Activity mockActivity;
  @Mock Application mockApplication;
  @Mock FileSelectorDelegate mockFileSelectorDelegate;
  @Mock Messages.Result mockResult;
  @Mock PathUtils mockPathUtils;
  @Mock ActivityStateHelper mockActivityStateHelper;
  FileSelectorPlugin plugin;

  @Before
  public void setUp() {
    MockitoAnnotations.openMocks(this);

    doNothing().when(mockFileSelectorDelegate).clearCache();
    when(mockRegistrar.context()).thenReturn(mockApplication);
    when(mockActivityBinding.getActivity()).thenReturn(mockActivity);
    when(mockPluginBinding.getApplicationContext()).thenReturn(mockApplication);

    plugin = new FileSelectorPlugin(mockFileSelectorDelegate, mockActivity);
  }

  @After
  public void tearDown() {
    reset(mockRegistrar);
    reset(mockActivity);
    reset(mockPluginBinding);
    reset(mockPathUtils);
    reset(mockResult);
    reset(mockActivityBinding);
    reset(mockFileSelectorDelegate);
    reset(mockApplication);
  }

  @Test
  public void onOpenFilesCall_WhenActivityIsNull_FinishesWithForegroundActivityRequiredError() {
    FileSelectorPlugin fileSelectorPluginWithNullActivity =
        new FileSelectorPlugin(mockFileSelectorDelegate, null);

    Messages.SelectionOptions options =
        buildSelectionOptions(new ArrayList<String>(Collections.singleton("*/*")), false);

    fileSelectorPluginWithNullActivity.openFiles(options, mockResult);

    verify(mockResult).error(any(Throwable.class));
  }

  @Test
  public void
      onMethodCall_GetDirectoryPath_WhenCalledWithoutInitialDirectory_InvokesRootSourceFolder() {
    plugin.getDirectoryPath(null, mockResult);

    verifyNoInteractions(mockResult);
  }

  @Test
  public void onMethodCall_GetDirectoryPath_WhenCalledWithInitialDirectory_InvokesSourceFolder() {
    plugin.getDirectoryPath("Documents", mockResult);

    verify(mockFileSelectorDelegate).getDirectoryPath(eq("Documents"), any());
    verifyNoInteractions(mockResult);
  }

  @Test
  public void onDetachedFromActivity_ShouldReleaseActivityState() {
    plugin.delegate = mockFileSelectorDelegate;

    final BinaryMessenger mockBinaryMessenger = mock(BinaryMessenger.class);
    when(mockPluginBinding.getBinaryMessenger()).thenReturn(mockBinaryMessenger);

    final HiddenLifecycleReference mockLifecycleReference = mock(HiddenLifecycleReference.class);
    when(mockActivityBinding.getLifecycle()).thenReturn(mockLifecycleReference);

    final Lifecycle mockLifecycle = mock(Lifecycle.class);
    when(mockLifecycleReference.getLifecycle()).thenReturn(mockLifecycle);

    plugin.onAttachedToEngine(mockPluginBinding);
    plugin.onAttachedToActivity(mockActivityBinding);
    assertNotNull(plugin.getActivityState());

    plugin.onDetachedFromActivity();
    assertNull(plugin.getActivityState());
  }

  @Test
  public void onMethodCall_OpenFile_ShouldBeCalledWithCorrespondingArguments() {
    final ArrayList<HashMap> arguments = prepareArguments();
    Messages.SelectionOptions options =
        buildSelectionOptions(new ArrayList<String>(Collections.singleton("*/*")), false);
    plugin.openFiles(options, mockResult);

    verify(mockFileSelectorDelegate).openFile(eq(options), any());
    verifyNoInteractions(mockResult);
  }

  @Test
  public void tearDown_ShouldClearState() {
    plugin.activityState = mockActivityStateHelper;
    plugin.delegate = mockFileSelectorDelegate;
    doNothing().when(mockFileSelectorDelegate).clearCache();
    doNothing().when(mockActivityStateHelper).release();
    plugin.tearDown();

    verify(mockActivityStateHelper, times(1)).release();
    verify(mockFileSelectorDelegate, times(1)).clearCache();
    Assert.assertNull(plugin.activityState);
  }

  @NonNull
  private ArrayList<HashMap> prepareArguments() {
    final ArrayList<HashMap> arguments = new ArrayList<HashMap>();
    mimeTypes.add("text");
    xTypeGroups.put("mimeTypes", mimeTypes);
    multiple.put("multiple", false);
    arguments.add(xTypeGroups);
    arguments.add(multiple);

    return arguments;
  }
}
