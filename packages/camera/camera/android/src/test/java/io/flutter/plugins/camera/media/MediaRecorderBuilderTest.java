// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.media;

import static org.junit.Assert.assertNotNull;
import static org.mockito.Mockito.*;

import android.media.CamcorderProfile;
import android.media.MediaRecorder;
import java.io.IOException;
import java.lang.reflect.Constructor;
import org.junit.Test;
import org.mockito.InOrder;

public class MediaRecorderBuilderTest {
  @Test
  public void ctor_test() {
    MediaRecorderBuilder builder =
        new MediaRecorderBuilder(CamcorderProfile.get(CamcorderProfile.QUALITY_1080P), "");

    assertNotNull(builder);
  }

  @Test
  public void build_shouldSetValuesInCorrectOrderWhenAudioIsDisabled() throws IOException {
    CamcorderProfile recorderProfile = getEmptyCamcorderProfile();
    MediaRecorderBuilder.MediaRecorderFactory mockFactory =
        mock(MediaRecorderBuilder.MediaRecorderFactory.class);
    MediaRecorder mockMediaRecorder = mock(MediaRecorder.class);
    String outputFilePath = "mock_video_file_path";
    int mediaOrientation = 1;
    MediaRecorderBuilder builder =
        new MediaRecorderBuilder(recorderProfile, outputFilePath, mockFactory)
            .setEnableAudio(false)
            .setMediaOrientation(mediaOrientation);

    when(mockFactory.makeMediaRecorder()).thenReturn(mockMediaRecorder);

    MediaRecorder recorder = builder.build();

    InOrder inOrder = inOrder(recorder);
    inOrder.verify(recorder).setVideoSource(MediaRecorder.VideoSource.SURFACE);
    inOrder.verify(recorder).setOutputFormat(recorderProfile.fileFormat);
    inOrder.verify(recorder).setVideoEncoder(recorderProfile.videoCodec);
    inOrder.verify(recorder).setVideoEncodingBitRate(recorderProfile.videoBitRate);
    inOrder.verify(recorder).setVideoFrameRate(recorderProfile.videoFrameRate);
    inOrder
        .verify(recorder)
        .setVideoSize(recorderProfile.videoFrameWidth, recorderProfile.videoFrameHeight);
    inOrder.verify(recorder).setOutputFile(outputFilePath);
    inOrder.verify(recorder).setOrientationHint(mediaOrientation);
    inOrder.verify(recorder).prepare();
  }

  @Test
  public void build_shouldSetValuesInCorrectOrderWhenAudioIsEnabled() throws IOException {
    CamcorderProfile recorderProfile = getEmptyCamcorderProfile();
    MediaRecorderBuilder.MediaRecorderFactory mockFactory =
        mock(MediaRecorderBuilder.MediaRecorderFactory.class);
    MediaRecorder mockMediaRecorder = mock(MediaRecorder.class);
    String outputFilePath = "mock_video_file_path";
    int mediaOrientation = 1;
    MediaRecorderBuilder builder =
        new MediaRecorderBuilder(recorderProfile, outputFilePath, mockFactory)
            .setEnableAudio(true)
            .setMediaOrientation(mediaOrientation);

    when(mockFactory.makeMediaRecorder()).thenReturn(mockMediaRecorder);

    MediaRecorder recorder = builder.build();

    InOrder inOrder = inOrder(recorder);
    inOrder.verify(recorder).setAudioSource(MediaRecorder.AudioSource.MIC);
    inOrder.verify(recorder).setVideoSource(MediaRecorder.VideoSource.SURFACE);
    inOrder.verify(recorder).setOutputFormat(recorderProfile.fileFormat);
    inOrder.verify(recorder).setAudioEncoder(recorderProfile.audioCodec);
    inOrder.verify(recorder).setAudioEncodingBitRate(recorderProfile.audioBitRate);
    inOrder.verify(recorder).setAudioSamplingRate(recorderProfile.audioSampleRate);
    inOrder.verify(recorder).setVideoEncoder(recorderProfile.videoCodec);
    inOrder.verify(recorder).setVideoEncodingBitRate(recorderProfile.videoBitRate);
    inOrder.verify(recorder).setVideoFrameRate(recorderProfile.videoFrameRate);
    inOrder
        .verify(recorder)
        .setVideoSize(recorderProfile.videoFrameWidth, recorderProfile.videoFrameHeight);
    inOrder.verify(recorder).setOutputFile(outputFilePath);
    inOrder.verify(recorder).setOrientationHint(mediaOrientation);
    inOrder.verify(recorder).prepare();
  }

  private CamcorderProfile getEmptyCamcorderProfile() {
    try {
      Constructor<CamcorderProfile> constructor =
          CamcorderProfile.class.getDeclaredConstructor(
              int.class, int.class, int.class, int.class, int.class, int.class, int.class,
              int.class, int.class, int.class, int.class, int.class);

      constructor.setAccessible(true);
      return constructor.newInstance(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    } catch (Exception ignored) {
    }

    return null;
  }
}
