// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.media;

import android.media.CamcorderProfile;
import android.media.MediaRecorder;
import androidx.annotation.NonNull;
import java.io.IOException;

public class MediaRecorderBuilder {
  static class MediaRecorderFactory {
    MediaRecorder makeMediaRecorder() {
      return new MediaRecorder();
    }
  }

  private final String outputFilePath;
  private final CamcorderProfile recordingProfile;
  private final MediaRecorderFactory recorderFactory;

  private boolean enableAudio;
  private int mediaOrientation;

  public MediaRecorderBuilder(
      @NonNull CamcorderProfile recordingProfile, @NonNull String outputFilePath) {
    this(recordingProfile, outputFilePath, new MediaRecorderFactory());
  }

  MediaRecorderBuilder(
      @NonNull CamcorderProfile recordingProfile,
      @NonNull String outputFilePath,
      MediaRecorderFactory helper) {
    this.outputFilePath = outputFilePath;
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
    MediaRecorder mediaRecorder = recorderFactory.makeMediaRecorder();

    // There's a fixed order that mediaRecorder expects. Only change these functions accordingly.
    // You can find the specifics here: https://developer.android.com/reference/android/media/MediaRecorder.
    if (enableAudio) mediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
    mediaRecorder.setVideoSource(MediaRecorder.VideoSource.SURFACE);
    mediaRecorder.setOutputFormat(recordingProfile.fileFormat);
    if (enableAudio) {
      mediaRecorder.setAudioEncoder(recordingProfile.audioCodec);
      mediaRecorder.setAudioEncodingBitRate(recordingProfile.audioBitRate);
      mediaRecorder.setAudioSamplingRate(recordingProfile.audioSampleRate);
    }
    mediaRecorder.setVideoEncoder(recordingProfile.videoCodec);
    mediaRecorder.setVideoEncodingBitRate(recordingProfile.videoBitRate);
    mediaRecorder.setVideoFrameRate(recordingProfile.videoFrameRate);
    mediaRecorder.setVideoSize(recordingProfile.videoFrameWidth, recordingProfile.videoFrameHeight);
    mediaRecorder.setOutputFile(outputFilePath);
    mediaRecorder.setOrientationHint(this.mediaOrientation);

    mediaRecorder.prepare();

    return mediaRecorder;
  }
}
