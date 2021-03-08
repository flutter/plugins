// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.media;

import static org.junit.Assert.assertNotNull;
import static org.mockito.Mockito.*;

import android.media.CamcorderProfile;
import android.media.MediaRecorder;
import io.flutter.plugins.camera.media.MediaRecorderBuilder.MediaRecorderFactory;
import java.io.IOException;
import java.lang.reflect.Constructor;
import org.junit.Test;
import org.mockito.InOrder;
import org.mockito.MockedStatic;

public class MediaRecorderBuilderTest {
  @Test
  public void ctor_test() {
    MediaRecorderBuilder builder =
        new MediaRecorderBuilder(CamcorderProfile.get(CamcorderProfile.QUALITY_1080P), "");

    assertNotNull(builder);
  }

  @Test
  public void build_Should_set_values_in_correct_order_When_audio_is_disabled() throws IOException {
    CamcorderProfile recorderProfile = getEmptyCamcorderProfile();
    String outputFilePath = "mock_video_file_path";
    int mediaOrientation = 1;
    MediaRecorder recorder;

    try (MockedStatic<MediaRecorderFactory> mockMediaRecorderFactory =
        mockStatic(MediaRecorderFactory.class)) {
      MediaRecorder mockMediaRecorder = mock(MediaRecorder.class);
      mockMediaRecorderFactory.when(MediaRecorderFactory::create).thenReturn(mockMediaRecorder);

      MediaRecorderBuilder builder =
          new MediaRecorderBuilder(recorderProfile, outputFilePath)
              .setEnableAudio(false)
              .setMediaOrientation(mediaOrientation);
      recorder = builder.build();
    }

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
  public void build_Should_set_values_in_correct_order_When_audio_is_enabled() throws IOException {
    MediaRecorder recorder;
    CamcorderProfile recorderProfile = getEmptyCamcorderProfile();
    String outputFilePath = "mock_video_file_path";
    int mediaOrientation = 1;

    try (MockedStatic<MediaRecorderFactory> mockMediaRecorderFactory =
        mockStatic(MediaRecorderFactory.class)) {
      MediaRecorder mockMediaRecorder = mock(MediaRecorder.class);
      mockMediaRecorderFactory.when(MediaRecorderFactory::create).thenReturn(mockMediaRecorder);

      MediaRecorderBuilder builder =
          new MediaRecorderBuilder(recorderProfile, outputFilePath)
              .setEnableAudio(true)
              .setMediaOrientation(mediaOrientation);

      recorder = builder.build();
    }

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
