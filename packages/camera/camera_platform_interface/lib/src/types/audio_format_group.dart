// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Group of audio formats available across Android and iOS platforms
/// Additional format groups may be added in the future
///
/// Sources:
/// https://developer.android.com/guide/topics/media/media-formats#audio-formats
/// https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/MultimediaPG/UsingAudio/UsingAudio.html
enum AudioFormatGroup {
  /// AAC LC format
  ///
  /// Supported for recording and playback on every Android device and iOS devices since iPhone 3GS.
  /// Seems to be auto-selected on iOS.
  ///
  /// On Android, this is `android.media.MediaRecorder.AudioEncoder.AAC`. See
  /// [https://developer.android.com/reference/android/media/MediaRecorder.AudioEncoder#AAC]
  ///
  /// On iOS, this is `kMPEG4Object_AAC_LC`. See
  /// [https://developer.apple.com/documentation/coreaudiotypes/mpeg4objectid/kmpeg4object_aac_lc?language=objc]
  aac,
}

/// Extension on [AudioFormatGroup] to stringify the enum
extension AudioFormatGroupName on AudioFormatGroup {
  /// returns a String value for [AudioFormatGroup]
  String name() {
    switch(this) {
      case AudioFormatGroup.aac:
        return 'aac';
    }
  }
}