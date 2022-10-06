// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.file_selector;

import static io.flutter.plugins.file_selector.FileSelectorDelegate.REQUEST_CODE_OPEN_FILE;
import static io.flutter.plugins.file_selector.TestHelpers.buildSelectionOptions;
import static io.flutter.plugins.file_selector.TestHelpers.setMockUris;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.reset;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoMoreInteractions;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.ClipData;
import android.content.Intent;
import android.net.Uri;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.mockito.Spy;

public class FileSelectorDelegateTest {
  final List<String> typesList = Arrays.asList("text", "png");
  final List<String> textMimeType = Collections.singletonList("text");
  String fakeFolder = "fakeFolder";
  int numberOfPickedFiles = 2;

  @Mock Activity mockActivity;
  @Mock Messages.Result mockResult;
  @Mock Intent mockIntent;
  @Mock Uri mockUri;
  @Mock PathUtils mockPathUtils;
  @Spy FileSelectorDelegate spyFileSelectorDelegate;
  @Mock ClipData mockClipData;
  @Mock ClipData.Item mockItem;

  @Before
  public void setUp() {
    MockitoAnnotations.openMocks(this);
    spyFileSelectorDelegate.cacheFolder = fakeFolder;

    spyFileSelectorDelegate = spy(new FileSelectorDelegate(mockActivity));

    when(mockIntent.getData()).thenReturn(mockUri);
  }

  @After
  public void tearDown() {
    reset(mockUri);
    reset(mockActivity);
    reset(mockIntent);
    reset(mockPathUtils);
    reset(mockResult);
    reset(spyFileSelectorDelegate);
    reset(mockClipData);
    reset(mockItem);
  }

  @Test
  public void getDirectoryPath_WhenPendingResultExists_FinishesWithAlreadyActiveError() {
    FileSelectorDelegate delegate = new FileSelectorDelegate(mockActivity, mockResult);

    delegate.getDirectoryPath("Directory", mockResult);

    verifyFinishedWithAlreadyActiveError();
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void onActivityResult_WhenGetDirectoryPathCanceled_FinishesWithNull() {
    FileSelectorDelegate delegate = createDelegateWithPendingResultAndMethodCall();

    delegate.onActivityResult(
        FileSelectorDelegate.REQUEST_CODE_GET_DIRECTORY_PATH, Activity.RESULT_CANCELED, null);

    verify(mockResult).success(null);
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void onActivityResult_GetDirectoryPathReturnsSuccessfully() {
    FileSelectorDelegate delegate = createDelegateWithPendingResultAndMethodCall();
    delegate.onActivityResult(
        FileSelectorDelegate.REQUEST_CODE_GET_DIRECTORY_PATH, Activity.RESULT_OK, mockIntent);

    verify(mockResult).success(mockUri.toString());
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void openFile_WhenPendingResultExists_FinishesWithAlreadyActiveError() {
    FileSelectorDelegate delegate = new FileSelectorDelegate(mockActivity, mockResult);

    Messages.SelectionOptions options =
        buildSelectionOptions(new ArrayList<String>(Collections.singleton("*/*")), false);

    delegate.openFile(options, mockResult);

    verifyFinishedWithAlreadyActiveError();
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void onActivityResult_WhenOpenFileCanceled_FinishesWithNull() {
    FileSelectorDelegate delegate = createDelegateWithPendingResultAndMethodCall();
    delegate.onActivityResult(
        FileSelectorDelegate.REQUEST_CODE_OPEN_FILE, Activity.RESULT_CANCELED, null);

    verify(mockResult).success(null);
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void openFile_WhenItIsCalled_InvokesLaunchOpenFile() {
    spyFileSelectorDelegate = spy(new FileSelectorDelegate(mockActivity));
    Messages.SelectionOptions options =
        buildSelectionOptions(new ArrayList<String>(Collections.singleton("text")), false);

    doAnswer(
            (invocation) -> {
              return null;
            })
        .when(spyFileSelectorDelegate)
        .launchOpenFile(false, textMimeType);

    spyFileSelectorDelegate.openFile(options, mockResult);

    verify(spyFileSelectorDelegate).launchOpenFile(false, textMimeType);
  }

  @Test
  public void clearCache_WhenItIsCalled_InvokesClearCacheFromPathUtils() {
    FileSelectorDelegate delegate = createDelegateWithPendingResultAndMethodCall();
    delegate.cacheFolder = fakeFolder;

    try (MockedStatic<PathUtils> mockedPathUtils = Mockito.mockStatic(PathUtils.class)) {
      delegate.clearCache();

      mockedPathUtils.verify(() -> PathUtils.clearCache(mockActivity, fakeFolder), times(1));
    }
  }

  @Test
  public void onActivityResult_WhenOpenFile_InvokesHandleOpenFileResult() {
    doAnswer(
            (invocation) -> {
              return null;
            })
        .when(spyFileSelectorDelegate)
        .handleOpenFileResult(Activity.RESULT_OK, mockIntent);

    spyFileSelectorDelegate.onActivityResult(
        FileSelectorDelegate.REQUEST_CODE_OPEN_FILE, Activity.RESULT_OK, mockIntent);

    verify(spyFileSelectorDelegate).handleOpenFileResult(Activity.RESULT_OK, mockIntent);
  }

  @Test
  public void handleOpenFileResult_WhenItIsCalled_InvokesCopyFileToInternalStorageFromPathUtils() {
    FileSelectorDelegate delegate = createDelegateWithPendingResultAndMethodCall();
    delegate.cacheFolder = fakeFolder;
    ArrayList<Uri> uris = setMockUris(1, mockUri);

    try (MockedStatic<PathUtils> mockedPathUtils = Mockito.mockStatic(PathUtils.class)) {
      when(mockIntent.getData()).thenReturn(mockUri);
      when(spyFileSelectorDelegate.uriHandler(mockIntent)).thenReturn(uris);

      spyFileSelectorDelegate.handleOpenFileResult(Activity.RESULT_OK, mockIntent);

      mockedPathUtils.verify(
          () -> PathUtils.copyFilesToInternalStorage(uris, mockActivity, fakeFolder), times(1));
    }
  }

  @Test
  public void
      handleOpenFileResult_WhenItIsCalledWithMultipleFiles_InvokesCopyFileToInternalStorageFromPathUtilsWithCorrespondingUrisArray() {
    ArrayList<Uri> uris = setMockUris(numberOfPickedFiles, mockUri);

    try (MockedStatic<PathUtils> mockedPathUtils = Mockito.mockStatic(PathUtils.class)) {
      when(spyFileSelectorDelegate.uriHandler(mockIntent)).thenReturn(uris);

      spyFileSelectorDelegate.handleOpenFileResult(Activity.RESULT_OK, mockIntent);

      mockedPathUtils.verify(
          () -> PathUtils.copyFilesToInternalStorage(uris, mockActivity, fakeFolder), times(1));
    }
  }

  @Test
  public void
      handleOpenFileResult_WhenResultCodeIsNotOk_NotInvokesCopyFileToInternalStorageFromPathUtils() {
    FileSelectorDelegate delegate = createDelegateWithPendingResultAndMethodCall();
    delegate.cacheFolder = fakeFolder;

    delegate.handleOpenFileResult(Activity.RESULT_CANCELED, mockIntent);

    verifyNoMoreInteractions(mockPathUtils);
  }

  @Test
  public void handleOpenFileResult_WhenItIsCalled_ShouldInvokeHandleOpenFileActionResults() {
    ArrayList<Uri> uris = setMockUris(1, mockUri);
    ArrayList<String> paths = new ArrayList<>();

    try (MockedStatic<PathUtils> mockedPathUtils = Mockito.mockStatic(PathUtils.class)) {
      when(mockIntent.getData()).thenReturn(mockUri);
      when(spyFileSelectorDelegate.uriHandler(mockIntent)).thenReturn(uris);

      spyFileSelectorDelegate.handleOpenFileResult(Activity.RESULT_OK, mockIntent);

      mockedPathUtils
          .when(() -> PathUtils.copyFilesToInternalStorage(uris, mockActivity, fakeFolder))
          .thenReturn(paths);

      verify(spyFileSelectorDelegate).handleOpenFileActionResults(paths);
    }
  }

  @Test
  public void
      handleOpenFileActionResults_WhenItIsCalled_ShouldInvokeSuccessAndFinishWithListSuccessMethods() {
    ArrayList<String> paths = new ArrayList<>();
    spyFileSelectorDelegate = spy(new FileSelectorDelegate(mockActivity, mockResult));

    spyFileSelectorDelegate.handleOpenFileActionResults(paths);

    verify(mockResult).success(paths);
    verify(spyFileSelectorDelegate).finishWithListSuccess(paths);
  }

  @Test
  public void uriHandler_WhenASingleFileIsPicked_ShouldInvokeGetDataMethod() {
    FileSelectorDelegate delegate = createDelegateWithPendingResultAndMethodCall();

    delegate.uriHandler(mockIntent);

    verify(mockIntent).getData();
  }

  @Test
  public void uriHandler_WhenASingleFileIsPicked_ShouldReturnAUri() {
    ArrayList<Uri> expectedResult = new ArrayList<>();
    expectedResult.add(mockUri);

    FileSelectorDelegate delegate = createDelegateWithPendingResultAndMethodCall();

    ArrayList<Uri> actualResult = delegate.uriHandler(mockIntent);

    Assert.assertEquals(expectedResult, actualResult);
  }

  @Test
  public void uriHandler_WhenMultipleFilesArePicked_ShouldReturnSameNumberOfUris() {
    ArrayList<Uri> uris = setMockUris(numberOfPickedFiles, mockUri);
    mockClipData(numberOfPickedFiles);

    ArrayList<Uri> expectedResult = new ArrayList<>();
    expectedResult.addAll(uris);

    FileSelectorDelegate delegate = createDelegateWithPendingResultAndMethodCall();

    ArrayList<Uri> actualResult = delegate.uriHandler(mockIntent);

    Assert.assertEquals(expectedResult, actualResult);
    Assert.assertEquals(numberOfPickedFiles, actualResult.stream().count());
  }

  @Test
  public void uriHandler_WhenMultipleFilesArePicked_ShouldInvokeSeveralMethodsOfClipData() {
    mockClipData(numberOfPickedFiles);

    FileSelectorDelegate delegate = createDelegateWithPendingResultAndMethodCall();

    delegate.uriHandler(mockIntent);

    verify(mockClipData).getItemCount();
    verify(mockClipData, times(numberOfPickedFiles)).getItemAt(anyInt());
  }

  @Test
  public void launchOpenFile_WhenItIsSuccessfully_ShouldInvokeStartWithSpecificArguments() {
    mockClipData(numberOfPickedFiles);
    spyFileSelectorDelegate.openFileIntent = mockIntent;

    spyFileSelectorDelegate.launchOpenFile(false, textMimeType);

    verify(mockActivity, times(1)).startActivityForResult(mockIntent, REQUEST_CODE_OPEN_FILE);
  }

  @Test
  public void
      launchOpenFile_WhenAllArgumentsAreNotEmpty_ShouldSetSeveralPropertiesOfIntentWithSpecificValues() {
    spyFileSelectorDelegate.openFileIntent = mockIntent;
    spyFileSelectorDelegate.launchOpenFile(false, textMimeType);

    verify(mockIntent, times(1)).setAction(Intent.ACTION_GET_CONTENT);
    verify(mockIntent, times(1)).addCategory(Intent.CATEGORY_OPENABLE);
    verify(mockIntent, times(1)).putExtra(Intent.EXTRA_ALLOW_MULTIPLE, false);
    verify(mockIntent, times(1)).setType("text");
  }

  @Test
  public void launchOpenFile_WhenMimeTypesAreEmpty_ShouldNotInvokePutExtraForExtraMimeTypes() {
    spyFileSelectorDelegate.openFileIntent = mockIntent;
    mockClipData(numberOfPickedFiles);

    spyFileSelectorDelegate.launchOpenFile(false, null);

    verify(mockIntent, never()).putExtra(Intent.EXTRA_MIME_TYPES, typesList.toArray(new String[0]));
  }

  @Test
  public void launchOpenFile_WhenMimeTypesAreNotEmpty_ShouldInvokePutExtraForExtraMimeTypes() {
    spyFileSelectorDelegate.openFileIntent = mockIntent;
    mockClipData(numberOfPickedFiles);

    spyFileSelectorDelegate.launchOpenFile(false, typesList);

    verify(mockIntent, times(1))
        .putExtra(Intent.EXTRA_MIME_TYPES, typesList.toArray(new String[0]));
  }

  private FileSelectorDelegate createDelegate() {
    return new FileSelectorDelegate(mockActivity, null);
  }

  private FileSelectorDelegate createDelegateWithPendingResultAndMethodCall() {
    return new FileSelectorDelegate(mockActivity, mockResult);
  }

  private void verifyFinishedWithAlreadyActiveError() {
    verify(mockResult).error(any(Throwable.class));
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
