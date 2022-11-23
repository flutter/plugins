// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.file_selector;

import static io.flutter.plugins.file_selector.TestHelpers.setMockUris;
import static org.mockito.Mockito.reset;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.ContentResolver;
import android.database.Cursor;
import android.net.Uri;
import android.provider.OpenableColumns;
import java.io.IOException;
import java.io.InputStream;
import java.nio.Buffer;
import java.util.ArrayList;
import java.util.Collections;
import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.mockito.Spy;

public class PathUtilsTest {
  static TemporaryFolder folder;
  static final String fileName = "FileName";
  static final String externalDirectoryName = "ExternalDir";
  static final String folderName = "FolderName";
  int bufferSize = 1024;
  final byte[] fakeByte = new byte[bufferSize];

  @Mock Activity mockActivity;
  @Mock Uri mockUri;
  @Mock Cursor mockCursor;
  @Mock ContentResolver mockContentResolver;
  @Mock InputStream mockInputStream;
  @Mock Buffer mockBuffer;
  @Spy PathUtils spyPathUtils;

  @Before
  public void setUp() throws IOException {
    MockitoAnnotations.openMocks(this);
    spyPathUtils = spy(new PathUtils());

    folder = new TemporaryFolder();
    folder.create();

    when(mockCursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)).thenReturn(0);
    when(mockContentResolver.query(
            mockUri,
            new String[] {OpenableColumns.DISPLAY_NAME, OpenableColumns.SIZE},
            null,
            null,
            null))
        .thenReturn(mockCursor);
    when(mockActivity.getContentResolver()).thenReturn(mockContentResolver);
    when(mockInputStream.read(fakeByte)).thenReturn(-1);
    when(mockContentResolver.openInputStream(mockUri)).thenReturn(mockInputStream);
    when(mockCursor.moveToFirst()).thenReturn(true);
    when(mockCursor.getString(0)).thenReturn(fileName);

    mockFiles();
  }

  @After
  public void tearDown() {
    reset(mockUri);
    reset(mockActivity);
    reset(mockCursor);
    reset(mockContentResolver);
    reset(mockInputStream);
    reset(mockBuffer);
    reset(spyPathUtils);
    folder.delete();
  }

  @Test
  public void getFileName_shouldReturnTheFileName() {
    final String actualResult =
        PathUtils.getFileName(
            mockUri,
            mockActivity,
            new String[] {OpenableColumns.DISPLAY_NAME, OpenableColumns.SIZE});

    Assert.assertEquals(fileName, actualResult);
  }

  @Test
  public void
      copyFilesToInternalStorage_whenMoreThanOneUriIsReceived_shouldReturnSameNumberOfAbsolutePaths() {
    int numberOfPickedFiles = 3;

    ArrayList<Uri> fakeUris = setMockUris(numberOfPickedFiles, mockUri);
    ArrayList<String> expectedResult = new ArrayList<>();
    String absolutPath = folder.getRoot() + "/" + folderName + "/" + fileName;
    expectedResult.add(absolutPath);
    expectedResult.add(absolutPath);
    expectedResult.add(absolutPath);

    ArrayList<String> actualResult =
        PathUtils.copyFilesToInternalStorage(fakeUris, mockActivity, folderName);

    Assert.assertEquals(expectedResult, actualResult);
    Assert.assertEquals(expectedResult.size(), actualResult.size());
  }

  @Test
  public void
      copyFilesToInternalStorage_whenExecutedSuccessfully_shouldReturnAbsolutePathOfAddedFolder() {
    ArrayList<String> expectedResult =
        new ArrayList<>(
            Collections.singletonList(folder.getRoot() + "/" + folderName + "/" + fileName));
    final ArrayList<String> actualResult =
        PathUtils.copyFilesToInternalStorage(setMockUris(1, mockUri), mockActivity, folderName);

    Assert.assertEquals(expectedResult, actualResult);
  }

  private void mockFiles() throws IOException {
    folder.newFile("myFile1.txt");
    folder.newFile("myFile2.txt");

    when(mockActivity.getFilesDir()).thenReturn(folder.getRoot());
  }
}
