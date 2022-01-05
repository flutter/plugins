// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAPTURE_CONTROLLER_LISTENER_H_
#define PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAPTURE_CONTROLLER_LISTENER_H_

#include <functional>

namespace camera_windows {

class CaptureControllerListener {
 public:
  virtual ~CaptureControllerListener() = default;

  virtual void OnCreateCaptureEngineSucceeded(int64_t texture_id) = 0;
  virtual void OnCreateCaptureEngineFailed(const std::string& error) = 0;

  virtual void OnStartPreviewSucceeded(int32_t width, int32_t height) = 0;
  virtual void OnStartPreviewFailed(const std::string& error) = 0;

  virtual void OnResumePreviewSucceeded() = 0;
  virtual void OnResumePreviewFailed(const std::string& error) = 0;

  virtual void OnPausePreviewSucceeded() = 0;
  virtual void OnPausePreviewFailed(const std::string& error) = 0;

  virtual void OnStartRecordSucceeded() = 0;
  virtual void OnStartRecordFailed(const std::string& error) = 0;

  virtual void OnStopRecordSucceeded(const std::string& filepath) = 0;
  virtual void OnStopRecordFailed(const std::string& error) = 0;

  virtual void OnPictureSuccess(const std::string& filepath) = 0;
  virtual void OnPictureFailed(const std::string& error) = 0;

  virtual void OnVideoRecordedSuccess(const std::string& filepath,
                                      int64_t video_duration) = 0;
  virtual void OnVideoRecordedFailed(const std::string& error) = 0;
};

}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAPTURE_CONTROLLER_LISTENER_H_
