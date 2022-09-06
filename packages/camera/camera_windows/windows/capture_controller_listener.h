// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAPTURE_CONTROLLER_LISTENER_H_
#define PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAPTURE_CONTROLLER_LISTENER_H_

#include <functional>

namespace camera_windows {

// Results that can occur when interacting with the camera.
enum class CameraResult {
  // Camera operation succeeded.
  kSuccess,

  // Camera operation failed.
  kError,

  // Camera access permission is denied.
  kAccessDenied,
};

// Interface for classes that receives callbacks on events from the associated
// |CaptureController|.
class CaptureControllerListener {
 public:
  virtual ~CaptureControllerListener() = default;

  // Called by CaptureController on successful capture engine initialization.
  //
  // texture_id: A 64bit integer id registered by TextureRegistrar
  virtual void OnCreateCaptureEngineSucceeded(int64_t texture_id) = 0;

  // Called by CaptureController if initializing the capture engine fails.
  //
  // result: The kind of result.
  // error: A string describing the error.
  virtual void OnCreateCaptureEngineFailed(CameraResult result,
                                           const std::string& error) = 0;

  // Called by CaptureController on successfully started preview.
  //
  // width: Preview frame width.
  // height: Preview frame height.
  virtual void OnStartPreviewSucceeded(int32_t width, int32_t height) = 0;

  // Called by CaptureController if starting the preview fails.
  //
  // result: The kind of result.
  // error: A string describing the error.
  virtual void OnStartPreviewFailed(CameraResult result,
                                    const std::string& error) = 0;

  // Called by CaptureController on successfully paused preview.
  virtual void OnPausePreviewSucceeded() = 0;

  // Called by CaptureController if pausing the preview fails.
  //
  // result: The kind of result.
  // error: A string describing the error.
  virtual void OnPausePreviewFailed(CameraResult result,
                                    const std::string& error) = 0;

  // Called by CaptureController on successfully resumed preview.
  virtual void OnResumePreviewSucceeded() = 0;

  // Called by CaptureController if resuming the preview fails.
  //
  // result: The kind of result.
  // error: A string describing the error.
  virtual void OnResumePreviewFailed(CameraResult result,
                                     const std::string& error) = 0;

  // Called by CaptureController on successfully started recording.
  virtual void OnStartRecordSucceeded() = 0;

  // Called by CaptureController if starting the recording fails.
  //
  // result: The kind of result.
  // error: A string describing the error.
  virtual void OnStartRecordFailed(CameraResult result,
                                   const std::string& error) = 0;

  // Called by CaptureController on successfully stopped recording.
  //
  // file_path: Filesystem path of the recorded video file.
  virtual void OnStopRecordSucceeded(const std::string& file_path) = 0;

  // Called by CaptureController if stopping the recording fails.
  //
  // result: The kind of result.
  // error: A string describing the error.
  virtual void OnStopRecordFailed(CameraResult result,
                                  const std::string& error) = 0;

  // Called by CaptureController on successfully captured picture.
  //
  // file_path: Filesystem path of the captured image.
  virtual void OnTakePictureSucceeded(const std::string& file_path) = 0;

  // Called by CaptureController if taking picture fails.
  //
  // result: The kind of result.
  // error: A string describing the error.
  virtual void OnTakePictureFailed(CameraResult result,
                                   const std::string& error) = 0;

  // Called by CaptureController when timed recording is successfully recorded.
  //
  // file_path: Filesystem path of the captured image.
  // video_duration: Duration of recorded video in milliseconds.
  virtual void OnVideoRecordSucceeded(const std::string& file_path,
                                      int64_t video_duration_ms) = 0;

  // Called by CaptureController if timed recording fails.
  //
  // result: The kind of result.
  // error: A string describing the error.
  virtual void OnVideoRecordFailed(CameraResult result,
                                   const std::string& error) = 0;

  // Called by CaptureController if capture engine returns error.
  // For example when camera is disconnected while on use.
  //
  // result: The kind of result.
  // error: A string describing the error.
  virtual void OnCaptureError(CameraResult result,
                              const std::string& error) = 0;
};

}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAPTURE_CONTROLLER_LISTENER_H_
