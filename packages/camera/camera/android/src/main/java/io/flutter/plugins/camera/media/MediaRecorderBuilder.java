// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.media;

import android.media.CamcorderProfile;
import android.media.EncoderProfiles;
import android.content.Context;
import android.media.MediaRecorder;
import androidx.annotation.NonNull;
import java.io.IOException;

public class MediaRecorderBuilder {
  static class MediaRecorderFactory {
    MediaRecorder makeMediaRecorder(Context applicationContext) {
      return new MediaRecorder(applicationContext);
    }
  }

  private final String outputFilePath;
  private final EncoderProfiles recordingProfile;
  private final MediaRecorderFactory recorderFactory;
  private final Context applicationContext;

  private boolean enableAudio;
  private int mediaOrientation;

  public MediaRecorderBuilder(
      @NonNull EncoderProfiles recordingProfile, @NonNull Context applicationContext, @NonNull String outputFilePath) {
    this(recordingProfile, applicationContext, outputFilePath, new MediaRecorderFactory());
  }

  MediaRecorderBuilder(
      @NonNull EncoderProfiles recordingProfile,
      @NonNull Context applicationContext,
      @NonNull String outputFilePath,
      MediaRecorderFactory helper) {
    this.outputFilePath = outputFilePath;
    this.applicationContext = applicationContext;
    this.recordingProfile = recordingProfile;
    this.recorderFactory = helper;
  }

  public MediaRecorderBuilder setEnableAudio(boolean enableAudio) {
    this.enableAudio = enableAudio;
    return this;
  }

  public MediaRecorderBuilder setMediaOrientation(int orientation) {
    this.mediaOrientation = orientation;
    return this;
  }

  public MediaRecorder build() throws IOException {
    MediaRecorder mediaRecorder = recorderFactory.makeMediaRecorder(applicationContext);

    EncoderProfiles.VideoProfile videoProfile = recordingProfile.getVideoProfiles().get(0);
    EncoderProfiles.AudioProfile audioProfile = recordingProfile.getAudioProfiles().get(0);

    // There's a fixed order that mediaRecorder expects. Only change these functions accordingly.
    // You can find the specifics here: https://developer.android.com/reference/android/media/MediaRecorder.
    if (enableAudio) mediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
    mediaRecorder.setVideoSource(MediaRecorder.VideoSource.SURFACE);
    // mediaRecorder.setOutputFormat(recordingProfile.fileFormat);
    mediaRecorder.setOutputFormat(recordingProfile.getRecommendedFileFormat());
    if (enableAudio) {
      // mediaRecorder.setAudioEncoder(recordingProfile.audioCodec);
      mediaRecorder.setAudioEncoder(audioProfile.getCodec());
      // mediaRecorder.setAudioEncodingBitRate(recordingProfile.audioBitRate);
      mediaRecorder.setAudioEncodingBitRate(audioProfile.getBitrate());
      // mediaRecorder.setAudioSamplingRate(recordingProfile.audioSampleRate);
      mediaRecorder.setAudioSamplingRate(audioProfile.getSampleRate());
    }
    // mediaRecorder.setVideoEncoder(recordingProfile.videoCodec);
    mediaRecorder.setVideoEncoder(videoProfile.getCodec());
    // mediaRecorder.setVideoEncodingBitRate(recordingProfile.videoBitRate);
    mediaRecorder.setVideoEncodingBitRate(videoProfile.getBitrate());
    // mediaRecorder.setVideoFrameRate(recordingProfile.videoFrameRate);
    mediaRecorder.setVideoFrameRate(videoProfile.getFrameRate());
    // mediaRecorder.setVideoSize(recordingProfile.videoFrameWidth, recordingProfile.videoFrameHeight);
    mediaRecorder.setVideoSize(videoProfile.getWidth(), videoProfile.getHeight());
    mediaRecorder.setOutputFile(outputFilePath);
    mediaRecorder.setOrientationHint(this.mediaOrientation);

    mediaRecorder.prepare();

    return mediaRecorder;
  }
}
