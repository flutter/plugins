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

// States the preview handler can be in.
//
// When created, the handler starts in |kNotStarted| state and mostly
// transitions in sequential order of the states. When the preview is running,
// it can be set to the |kPaused| state and later resumed to |kRunning| state.
enum class PreviewState {
  kNotStarted,
  kStarting,
  kRunning,
  kPaused,
  kStopping
};

// Handler for a camera's video preview.
//
// Handles preview sink initialization and manages the state of the video
// preview.
class PreviewHandler {
 public:
  PreviewHandler() {}
  virtual ~PreviewHandler() = default;

  // Prevent copying.
  PreviewHandler(PreviewHandler const&) = delete;
  PreviewHandler& operator=(PreviewHandler const&) = delete;

  // Initializes preview sink and requests capture engine to start previewing.
  // Sets preview state to: starting.
  //
  // capture_engine:  A pointer to capture engine instance. Used to start
  //                  the actual recording.
  // base_media_type: A pointer to base media type used as a base
  //                  for the actual video capture media type.
  // sample_callback: A pointer to capture engine listener.
  //                  This is set as sample callback for preview sink.
  HRESULT StartPreview(IMFCaptureEngine* capture_engine,
                       IMFMediaType* base_media_type,
                       CaptureEngineListener* sample_callback);

  // Stops existing recording.
  //
  // capture_engine:  A pointer to capture engine instance. Used to stop
  //                  the ongoing recording.
  HRESULT StopPreview(IMFCaptureEngine* capture_engine);

  // Set the preview handler recording state to: paused.
  bool PausePreview();

  // Set the preview handler recording state to: running.
  bool ResumePreview();

  // Set the preview handler recording state to: running.
  void OnPreviewStarted();

  // Returns true if preview state is running or paused.
  bool IsInitialized() const {
    return preview_state_ == PreviewState::kRunning ||
           preview_state_ == PreviewState::kPaused;
  }

  // Returns true if preview state is running.
  bool IsRunning() const { return preview_state_ == PreviewState::kRunning; }

  // Return true if preview state is paused.
  bool IsPaused() const { return preview_state_ == PreviewState::kPaused; }

  // Returns true if preview state is starting.
  bool IsStarting() const { return preview_state_ == PreviewState::kStarting; }

 private:
  // Initializes record sink for video file capture.
  HRESULT InitPreviewSink(IMFCaptureEngine* capture_engine,
                          IMFMediaType* base_media_type,
                          CaptureEngineListener* sample_callback);

  PreviewState preview_state_ = PreviewState::kNotStarted;
  ComPtr<IMFCapturePreviewSink> preview_sink_;
};

}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_PREVIEW_HANDLER_H_
