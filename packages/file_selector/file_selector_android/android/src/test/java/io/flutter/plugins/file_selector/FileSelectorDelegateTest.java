// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.file_selector;

import static io.flutter.plugins.file_selector.FileSelectorPlugin.METHOD_GET_DIRECTORY_PATH;
import static io.flutter.plugins.file_selector.TestHelpers.buildMethodCall;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoMoreInteractions;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

public class FileSelectorDelegateTest {
  @Mock Activity mockActivity;
  @Mock MethodChannel.Result mockResult;
  @Mock Intent mockIntent;

  @Mock Uri mockUri;

  @Before
  public void setUp() {
    MockitoAnnotations.openMocks(this);

    mockUri = mock(Uri.class);
    when(mockIntent.getData()).thenReturn(mockUri);
  }

  @Test
  public void getDirectoryPath_WhenPendingResultExists_FinishesWithAlreadyActiveError() {
    MethodCall call = buildMethodCall(METHOD_GET_DIRECTORY_PATH);
    FileSelectorDelegate delegate = new FileSelectorDelegate(mockActivity, mockResult, call);

    delegate.getDirectoryPath(call, mockResult);

    verifyFinishedWithAlreadyActiveError();
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void onActivityResult_WhenGetDirectoryPathCanceled_FinishesWithNull() {
    MethodCall call = buildMethodCall(METHOD_GET_DIRECTORY_PATH);
    FileSelectorDelegate delegate = createDelegateWithPendingResultAndMethodCall(call);

    delegate.onActivityResult(
        FileSelectorDelegate.REQUEST_CODE_GET_DIRECTORY_PATH, Activity.RESULT_CANCELED, null);

    verify(mockResult).success(null);
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void onActivityResult_GetDirectoryPathReturnsSuccessfully() {
    MethodCall call = buildMethodCall(METHOD_GET_DIRECTORY_PATH);
    FileSelectorDelegate delegate = createDelegateWithPendingResultAndMethodCall(call);
    delegate.onActivityResult(
        FileSelectorDelegate.REQUEST_CODE_GET_DIRECTORY_PATH, Activity.RESULT_OK, mockIntent);

    verify(mockResult).success(mockUri.toString());
    verifyNoMoreInteractions(mockResult);
  }

  private FileSelectorDelegate createDelegate() {
    return new FileSelectorDelegate(mockActivity, null, null);
  }

  private FileSelectorDelegate createDelegateWithPendingResultAndMethodCall(MethodCall call) {
    return new FileSelectorDelegate(mockActivity, mockResult, call);
  }

  private void verifyFinishedWithAlreadyActiveError() {
    verify(mockResult).error("already_active", "File selector is already active", null);
  }
}
