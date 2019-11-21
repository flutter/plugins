// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import static org.hamcrest.core.IsEqual.equalTo;
import static org.junit.Assert.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.when;

import android.graphics.Bitmap;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import org.junit.Before;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.mockito.Spy;
import org.mockito.invocation.InvocationOnMock;

public class ImageResizerTest {

  @Mock Bitmap mockBitMap;
  @Mock Bitmap mockScaledBitMap;
  @Spy @InjectMocks ImageResizer resizer;
  @Mock File mockFile;
  @Mock FileOutputStream mockOutputStream;

  @Before
  public void setUp() {
    MockitoAnnotations.initMocks(this);
    when(mockBitMap.getWidth()).thenReturn(100);
    when(mockBitMap.getHeight()).thenReturn(100);
    when(mockBitMap.hasAlpha()).thenReturn(true);
    doReturn(mockBitMap).when(resizer).decodeFile(any(String.class));
    doReturn(mockScaledBitMap)
        .when(resizer)
        .createScaledBitmap(any(Bitmap.class), any(int.class), any(int.class), any(boolean.class));
    when(mockScaledBitMap.getWidth()).thenReturn(100);
    when(mockScaledBitMap.getHeight()).thenReturn(100);
    doAnswer(
            (InvocationOnMock invocation) -> {
              when(mockFile.getPath()).thenReturn("scaledFolder" + invocation.getArgument(1));
              return mockFile;
            })
        .when(resizer)
        .createFile(any(File.class), any(String.class));

    try {
      doReturn(mockOutputStream).when(resizer).createOutputStream(mockFile);
    } catch (IOException e) {
      throw new RuntimeException(e);
    }
    doNothing().when(resizer).copyExif(any(String.class), any(String.class));
  }

  @Test
  public void onResizeImageIfNeeded_WhenQualityIsNull_ShoultNotResize_ReturnTheSameFile() {
    String outoutFile = resizer.resizeImageIfNeeded("dummyFolder/dummyPath.png", null, null, null);
    assertThat(outoutFile, equalTo("dummyFolder/dummyPath.png"));
  }

  @Test
  public void onResizeImageIfNeeded_WhenQualityIsNotNull_ShoulResize_ReturnResizedFile() {
    String outoutFile = resizer.resizeImageIfNeeded("dummyFolder/dummyPath.png", null, null, 50);
    assertThat(outoutFile, equalTo("scaledFolder/scaled_dummyPath.png"));
  }

  @Test
  public void onResizeImageIfNeeded_WhenWidthIsNotNull_ShoulResize_ReturnResizedFile() {
    String outoutFile = resizer.resizeImageIfNeeded("dummyFolder/dummyPath.png", 100.0, null, null);
    assertThat(outoutFile, equalTo("scaledFolder/scaled_dummyPath.png"));
  }

  @Test
  public void onResizeImageIfNeeded_WhenHeightIsNotNull_ShoulResize_ReturnResizedFile() {
    String outoutFile = resizer.resizeImageIfNeeded("dummyFolder/dummyPath.png", null, 100.0, null);
    assertThat(outoutFile, equalTo("scaledFolder/scaled_dummyPath.png"));
  }
}
