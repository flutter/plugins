// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_RECORD_HANDLER_H_
#define PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_RECORD_HANDLER_H_

#include <mfapi.h>
#include <mfcaptureengine.h>
#include <wrl/client.h>

#include <memory>
#include <string>

namespace camera_windows {
using Microsoft::WRL::ComPtr;

enum RecordingType { CONTINUOUS, TIMED };

enum RecordState {
  RECORD_STATE__NOT_STARTED,
  RECORD_STATE__STARTING,
  RECORD_STATE__RUNNING,
  RECORD_STATE__STOPPING
};

class RecordHandler {
 public:
  RecordHandler(bool record_audio) : record_audio_(record_audio){};
  virtual ~RecordHandler() = default;

  // Prevent copying.
  RecordHandler(RecordHandler const&) = delete;
  RecordHandler& operator=(RecordHandler const&) = delete;

  // Initializes record sink and requests capture engine to start recording.
  // Sets record state to: starting.
  // Returns false if recording cannot be started.
  //
  // file_path:       A string that hold file path for video capture.
  // max_duration:    A int64 value of maximun recording duration.
  //                  If value is -1 video recording is considered as
  //                  a continuous recording.
  // capture_engine:  A pointer to capture engine instance. Used to start
  //                  the actual recording.
  // base_media_type: A pointer to base media type used as a base
  //                  for the actual video capture media type.
  bool StartRecord(const std::string& file_path, int64_t max_duration,
                   IMFCaptureEngine* capture_engine,
                   IMFMediaType* base_media_type);

  // Stops existing recording.
  // Returns false if recording cannot be stopped.
  //
  // capture_engine:  A pointer to capture engine instance. Used to stop
  //                  the ongoing recording.
  bool StopRecord(IMFCaptureEngine* capture_engine);

  // Set the record handler recording state to: running.
  void OnRecordStarted();

  // Resets the record handler state and
  // sets recording state to: not started.
  void OnRecordStopped();

  // Returns true if recording type is continuous recording.
  bool IsContinuousRecording() { return type_ == RecordingType::CONTINUOUS; };

  // Returns true if recording type is timed recording.
  bool IsTimedRecording() { return type_ == RecordingType::TIMED; };

  // Returns true if new recording can be started.
  bool CanStart() {
    return recording_state_ == RecordState::RECORD_STATE__NOT_STARTED;
  };

  // Returns true if recording can be stopped.
  bool CanStop() {
    return recording_state_ == RecordState::RECORD_STATE__RUNNING;
  };

  // Returns path to video recording.
  std::string GetRecordPath() { return file_path_; };

  // Returns path to video recording in microseconds.
  uint64_t GetRecordedDuration() { return recording_duration_us_; };

  // Calculates new recording time from capture timestamp.
  void UpdateRecordingTime(uint64_t timestamp);

  // Tests if recording time has overlapped the max duration
  // given for timed recordings.
  bool ShouldStopTimedRecording();

 private:
  // Initializes record sink for video file capture.
  HRESULT InitRecordSink(IMFCaptureEngine* capture_engine,
                         IMFMediaType* base_media_type);

  bool record_audio_ = false;
  int64_t max_video_duration_ms_ = -1;
  int64_t recording_start_timestamp_us_ = -1;
  uint64_t recording_duration_us_ = 0;
  std::string file_path_ = "";
  RecordState recording_state_ = RecordState::RECORD_STATE__NOT_STARTED;
  RecordingType type_;
  ComPtr<IMFCaptureRecordSink> record_sink_;
};
}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_RECORD_HANDLER_H_