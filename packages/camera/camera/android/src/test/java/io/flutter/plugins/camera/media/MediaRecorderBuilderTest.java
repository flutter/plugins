// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.media;

import static org.junit.Assert.assertNotNull;
import static org.mockito.Mockito.*;

import android.content.Context;
import android.media.CamcorderProfile;
import android.media.EncoderProfiles;
import android.media.MediaRecorder;
import java.io.IOException;
import java.lang.reflect.Constructor;
import java.util.List;
import org.junit.Test;
import org.mockito.InOrder;

public class MediaRecorderBuilderTest {
  @Test
  public void ctor_test() {
    Context mockApplicationContext = mock(Context.class);
    MediaRecorderBuilder builder =
        new MediaRecorderBuilder(CamcorderProfile.getAll("0",CamcorderProfile.QUALITY_1080P), mockApplicationContext, "");

    assertNotNull(builder);
  }

  @Test
  public void build_shouldSetValuesInCorrectOrderWhenAudioIsDisabled() throws IOException {
    // CamcorderProfile recorderProfile = getEmptyCamcorderProfile();
    EncoderProfiles recorderProfile = mock(EncoderProfiles.class);
    Context mockApplicationContext = mock(Context.class);
    List<EncoderProfiles.VideoProfile> mockVideoProfiles = List.of(mock(EncoderProfiles.VideoProfile.class));
    List<EncoderProfiles.AudioProfile> mockAudioProfiles = List.of(mock(EncoderProfiles.AudioProfile.class));
    MediaRecorderBuilder.MediaRecorderFactory mockFactory =
        mock(MediaRecorderBuilder.MediaRecorderFactory.class);
    MediaRecorder mockMediaRecorder = mock(MediaRecorder.class);
    String outputFilePath = "mock_video_file_path";
    int mediaOrientation = 1;
    MediaRecorderBuilder builder =
        new MediaRecorderBuilder(recorderProfile, mockApplicationContext, outputFilePath, mockFactory)
            .setEnableAudio(false)
            .setMediaOrientation(mediaOrientation);

    when(mockFactory.makeMediaRecorder(mockApplicationContext)).thenReturn(mockMediaRecorder);
    when(recorderProfile.getVideoProfiles()).thenReturn(mockVideoProfiles);
    when(recorderProfile.getAudioProfiles()).thenReturn(mockAudioProfiles);


    MediaRecorder recorder = builder.build();

    EncoderProfiles.VideoProfile videoProfile = mockVideoProfiles.get(0);

    InOrder inOrder = inOrder(recorder);
    inOrder.verify(recorder).setVideoSource(MediaRecorder.VideoSource.SURFACE);
    // inOrder.verify(recorder).setOutputFormat(recorderProfile.fileFormat);
    inOrder.verify(recorder).setOutputFormat(recorderProfile.getRecommendedFileFormat());
    // inOrder.verify(recorder).setVideoEncoder(recorderProfile.videoCodec);
    inOrder.verify(recorder).setVideoEncoder(videoProfile.getCodec());
    // inOrder.verify(recorder).setVideoEncodingBitRate(recorderProfile.videoBitRate);
    inOrder.verify(recorder).setVideoEncodingBitRate(videoProfile.getBitrate());
    // inOrder.verify(recorder).setVideoFrameRate(recorderProfile.videoFrameRate);
    inOrder.verify(recorder).setVideoFrameRate(videoProfile.getFrameRate());

    inOrder
        .verify(recorder)
        .setVideoSize(videoProfile.getWidth(), videoProfile.getHeight());
        // .setVideoSize(recorderProfile.videoFrameWidth, recorderProfile.videoFrameHeight);
    inOrder.verify(recorder).setOutputFile(outputFilePath);
    inOrder.verify(recorder).setOrientationHint(mediaOrientation);
    inOrder.verify(recorder).prepare();
  }

  @Test
  public void build_shouldSetValuesInCorrectOrderWhenAudioIsEnabled() throws IOException {
    // CamcorderProfile recorderProfile = getEmptyCamcorderProfile();
    EncoderProfiles recorderProfile = mock(EncoderProfiles.class);
    Context mockApplicationContext = mock(Context.class);
    List<EncoderProfiles.VideoProfile> mockVideoProfiles = List.of(mock(EncoderProfiles.VideoProfile.class));
    List<EncoderProfiles.AudioProfile> mockAudioProfiles = List.of(mock(EncoderProfiles.AudioProfile.class));
    MediaRecorderBuilder.MediaRecorderFactory mockFactory =
        mock(MediaRecorderBuilder.MediaRecorderFactory.class);
    MediaRecorder mockMediaRecorder = mock(MediaRecorder.class);
    String outputFilePath = "mock_video_file_path";
    int mediaOrientation = 1;
    MediaRecorderBuilder builder =
        new MediaRecorderBuilder(recorderProfile, mockApplicationContext, outputFilePath, mockFactory)
            .setEnableAudio(true)
            .setMediaOrientation(mediaOrientation);

    when(mockFactory.makeMediaRecorder(mockApplicationContext)).thenReturn(mockMediaRecorder);
    when(recorderProfile.getVideoProfiles()).thenReturn(mockVideoProfiles);
    when(recorderProfile.getAudioProfiles()).thenReturn(mockAudioProfiles);

    MediaRecorder recorder = builder.build();

    EncoderProfiles.VideoProfile videoProfile = mockVideoProfiles.get(0);
    EncoderProfiles.AudioProfile audioProfile = mockAudioProfiles.get(0);

    InOrder inOrder = inOrder(recorder);
    inOrder.verify(recorder).setAudioSource(MediaRecorder.AudioSource.MIC);
    inOrder.verify(recorder).setVideoSource(MediaRecorder.VideoSource.SURFACE);
    // inOrder.verify(recorder).setOutputFormat(recorderProfile.fileFormat);
    inOrder.verify(recorder).setOutputFormat(recorderProfile.getRecommendedFileFormat());
    // inOrder.verify(recorder).setAudioEncoder(recorderProfile.audioCodec);
    inOrder.verify(recorder).setAudioEncoder(audioProfile.getCodec());
    // inOrder.verify(recorder).setAudioEncodingBitRate(recorderProfile.audioBitRate);
    inOrder.verify(recorder).setAudioEncodingBitRate(audioProfile.getBitrate());
    // inOrder.verify(recorder).setAudioSamplingRate(recorderProfile.audioSampleRate);
    inOrder.verify(recorder).setAudioSamplingRate(audioProfile.getSampleRate());
    // inOrder.verify(recorder).setVideoEncoder(recorderProfile.videoCodec);
    inOrder.verify(recorder).setVideoEncoder(videoProfile.getCodec());
    // inOrder.verify(recorder).setVideoEncodingBitRate(recorderProfile.videoBitRate);
    inOrder.verify(recorder).setVideoEncodingBitRate(videoProfile.getBitrate());
    // inOrder.verify(recorder).setVideoFrameRate(recorderProfile.videoFrameRate);
    inOrder.verify(recorder).setVideoFrameRate(videoProfile.getFrameRate());
    inOrder
        .verify(recorder)
        .setVideoSize(videoProfile.getWidth(), videoProfile.getHeight());
        // .setVideoSize(recorderProfile.videoFrameWidth, recorderProfile.videoFrameHeight);
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
