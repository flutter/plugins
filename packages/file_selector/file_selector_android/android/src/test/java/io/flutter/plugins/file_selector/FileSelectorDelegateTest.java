// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.file_selector;

import static io.flutter.plugins.file_selector.FileSelectorDelegate.REQUEST_CODE_GET_DIRECTORY_PATH;
import static io.flutter.plugins.file_selector.FileSelectorDelegate.REQUEST_CODE_OPEN_FILE;
import static io.flutter.plugins.file_selector.TestHelpers.buildSelectionOptions;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.reset;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoMoreInteractions;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.ClipData;
import android.content.Intent;
import android.net.Uri;
import java.util.ArrayList;
import java.util.Collections;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;

public class FileSelectorDelegateTest {
  String fakeFolder = "fakeFolder";

  @Mock Activity mockActivity;
  @Mock Messages.Result mockResult;
  @Mock Intent mockIntent;
  @Mock Uri mockUri;
  @Mock PathUtils mockPathUtils;
  @Mock ClipData mockClipData;
  @Mock ClipData.Item mockItem;

  @Before
  public void setUp() {
    MockitoAnnotations.openMocks(this);
    FileSelectorDelegate.cacheFolder = fakeFolder;

    when(mockIntent.getData()).thenReturn(mockUri);
  }

  @After
  public void tearDown() {
    reset(mockUri);
    reset(mockActivity);
    reset(mockIntent);
    reset(mockPathUtils);
    reset(mockResult);
    reset(mockClipData);
    reset(mockItem);
  }

  @Test
  public void onActivityResult_WhenGetDirectoryPathCanceled_FinishesWithNull() {
    // Arrange
    FileSelectorDelegate delegate = createDelegateWithPendingResultAndMethodCall();

    // Act
    delegate.onActivityResult(
        FileSelectorDelegate.REQUEST_CODE_GET_DIRECTORY_PATH, Activity.RESULT_CANCELED, null);

    // Assert
    verify(mockResult).success(null);
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void onActivityResult_GetDirectoryPathReturnsSuccessfully() {
    // Arrange
    FileSelectorDelegate delegate = createDelegateWithPendingResultAndMethodCall();

    // Act
    delegate.onActivityResult(
        FileSelectorDelegate.REQUEST_CODE_GET_DIRECTORY_PATH, Activity.RESULT_OK, mockIntent);

    // Assert
    verify(mockResult).success(mockUri.toString());
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void onActivityResult_WhenOpenFileCanceled_FinishesWithEmptyList() {
    // Arrange
    FileSelectorDelegate delegate = createDelegateWithPendingResultAndMethodCall();

    // Act
    delegate.onActivityResult(
        FileSelectorDelegate.REQUEST_CODE_OPEN_FILE, Activity.RESULT_CANCELED, null);

    // Assert
    verify(mockResult).success(new ArrayList<String>());
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void onActivityResult_OpenFileReturnsSuccessfully() {
    // Arrange
    FileSelectorDelegate delegate = createDelegateWithPendingResultAndMethodCall();
    mockClipData(2);
    ArrayList<String> returnedUris = new ArrayList<>();
    returnedUris.add(mockUri.toString());
    returnedUris.add(mockUri.toString());

    try (MockedStatic<PathUtils> mockedPathUtils = Mockito.mockStatic(PathUtils.class)) {
      mockedPathUtils
          .when(() -> PathUtils.copyFilesToInternalStorage(any(), any(), any()))
          .thenReturn(returnedUris);

      // Act
      delegate.onActivityResult(
          FileSelectorDelegate.REQUEST_CODE_OPEN_FILE, Activity.RESULT_OK, mockIntent);

      // Assert
      verify(mockResult).success(returnedUris);
      verifyNoMoreInteractions(mockResult);
    }
  }

  @Test
  public void getDirectoryPath_WhenPendingResultExists_FinishesWithAlreadyActiveError() {
    // Arrange
    FileSelectorDelegate delegate = createDelegateWithPendingResultAndMethodCall();

    // Act
    delegate.getDirectoryPath("Directory", mockResult);

    // Assert
    verify(mockResult).error(any(Throwable.class));
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void getDirectoryPath_ShouldStartActivityWith_SpecificRequestCode() {
    // Arrange
    FileSelectorDelegate delegate = createDelegateWithNoPendingResult();

    // Act
    delegate.getDirectoryPath("", mockResult);

    // Assert
    verify(mockActivity)
        .startActivityForResult(any(Intent.class), eq(REQUEST_CODE_GET_DIRECTORY_PATH));
  }

  @Test
  public void openFile_WhenPendingResultExists_FinishesWithAlreadyActiveError() {
    // Arrange
    FileSelectorDelegate delegate = createDelegateWithPendingResultAndMethodCall();
    Messages.SelectionOptions options =
        buildSelectionOptions(new ArrayList<>(Collections.singleton("*/*")), false);

    // Act
    delegate.openFile(options, mockResult);

    // Assert
    verify(mockResult).error(any(Throwable.class));
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void openFile_ShouldStartActivityWith_SpecificRequestCode() {
    // Arrange
    FileSelectorDelegate delegate = createDelegateWithNoPendingResult();
    Messages.SelectionOptions options =
        buildSelectionOptions(new ArrayList<>(Collections.singleton("*/*")), false);

    // Act
    delegate.openFile(options, mockResult);

    // Assert
    verify(mockActivity).startActivityForResult(any(Intent.class), eq(REQUEST_CODE_OPEN_FILE));
  }

  @Test
  public void clearCache_WhenItIsCalled_InvokesClearCacheFromPathUtils() {
    FileSelectorDelegate delegate = createDelegateWithPendingResultAndMethodCall();
    FileSelectorDelegate.cacheFolder = fakeFolder;

    try (MockedStatic<PathUtils> mockedPathUtils = Mockito.mockStatic(PathUtils.class)) {
      delegate.clearCache();

      mockedPathUtils.verify(() -> PathUtils.clearCache(mockActivity, fakeFolder), times(1));
    }
  }

  private FileSelectorDelegate createDelegateWithPendingResultAndMethodCall() {
    return new FileSelectorDelegate(mockActivity, mockResult);
  }

  private FileSelectorDelegate createDelegateWithNoPendingResult() {
    return new FileSelectorDelegate(mockActivity, null);
  }

  private void mockClipData(int uriCount) {
    when(mockItem.getUri()).thenReturn(mockUri);
    when(mockClipData.getItemCount()).thenReturn(uriCount);
    for (int i = 0; i < uriCount; i++) {
      when(mockClipData.getItemAt(i)).thenReturn(mockItem);
    }
    when(mockIntent.getClipData()).thenReturn(mockClipData);
  }
}
