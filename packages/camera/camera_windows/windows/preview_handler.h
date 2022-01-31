// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_PREVIEW_HANDLER_H_
#define PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_PREVIEW_HANDLER_H_

#include <mfapi.h>
#include <mfcaptureengine.h>
#include <wrl/client.h>

#include <memory>
#include <string>

#include "capture_engine_listener.h"

namespace camera_windows {
using Microsoft::WRL::ComPtr;

enum PreviewState {
  PREVIEW_STATE__NOT_STARTED,
  PREVIEW_STATE__STARTING,
  PREVIEW_STATE__RUNNING,
  PREVIEW_STATE__PAUSED,
  PREVIEW_STATE__STOPPING
};

class PreviewHandler {
 public:
  PreviewHandler(){};
  virtual ~PreviewHandler() = default;

  // Prevent copying.
  PreviewHandler(PreviewHandler const&) = delete;
  PreviewHandler& operator=(PreviewHandler const&) = delete;

  // Initializes preview sink and requests capture engine to start previewing.
  // Sets preview state to: starting.
  // Returns false if recording cannot be started.
  //
  // capture_engine:  A pointer to capture engine instance. Used to start
  //                  the actual recording.
  // base_media_type: A pointer to base media type used as a base
  //                  for the actual video capture media type.
  // sample_callback: A pointer to capture engine listener.
  //                  This is set as sample callback for preview sink.
  bool StartPreview(IMFCaptureEngine* capture_engine,
                    IMFMediaType* base_media_type,
                    CaptureEngineListener* sample_callback);

  // Stops existing recording.
  // Returns false if recording cannot be stopped.
  //
  // capture_engine:  A pointer to capture engine instance. Used to stop
  //                  the ongoing recording.
  bool StopPreview(IMFCaptureEngine* capture_engine);

  // Set the preview handler recording state to: paused.
  bool PausePreview();

  // Set the preview handler recording state to: running.
  bool ResumePreview();

  // Set the preview handler recording state to: running.
  void OnPreviewStarted();

  // Returns true if preview state is running or paused.
  bool IsInitialized() {
    return preview_state_ == PreviewState::PREVIEW_STATE__RUNNING &&
           preview_state_ == PreviewState::PREVIEW_STATE__PAUSED;
  };

  // Returns true if preview state is running.
  bool IsRunning() {
    return preview_state_ == PreviewState::PREVIEW_STATE__RUNNING;
  };

  // Return true if preview state is paused.
  bool IsPaused() {
    return preview_state_ == PreviewState::PREVIEW_STATE__PAUSED;
  };

  // Returns true if preview state is starting.
  bool IsStarting() {
    return preview_state_ == PreviewState::PREVIEW_STATE__STARTING;
  };

 private:
  // Initializes record sink for video file capture.
  HRESULT InitPreviewSink(IMFCaptureEngine* capture_engine,
                          IMFMediaType* base_media_type,
                          CaptureEngineListener* sample_callback);

  PreviewState preview_state_ = PreviewState::PREVIEW_STATE__NOT_STARTED;
  ComPtr<IMFCapturePreviewSink> preview_sink_;
};

}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_PREVIEW_HANDLER_H_
