// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAMERA_H_
#define PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAMERA_H_

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <functional>

#include "capture_controller.h"

namespace camera_windows {

using flutter::EncodableMap;
using flutter::MethodResult;

enum PendingResultType {
  CREATE_CAMERA,
  INITIALIZE,
  TAKE_PICTURE,
  START_RECORD,
  STOP_RECORD,
  PAUSE_PREVIEW,
  RESUME_PREVIEW,
};

class Camera : public CaptureControllerListener {
 public:
  Camera(const std::string &device_id){};
  virtual ~Camera() = default;

  // Disallow copy and move.
  Camera(const Camera &) = delete;
  Camera &operator=(const Camera &) = delete;

  virtual bool HasDeviceId(std::string &device_id) = 0;
  virtual bool HasCameraId(int64_t camera_id) = 0;

  virtual bool AddPendingResult(PendingResultType type,
                                std::unique_ptr<MethodResult<>> result) = 0;
  virtual bool HasPendingResultByType(PendingResultType type) = 0;

  virtual camera_windows::CaptureController *GetCaptureController() = 0;

  virtual void InitCamera(flutter::TextureRegistrar *texture_registrar,
                          flutter::BinaryMessenger *messenger,
                          bool enable_audio,
                          ResolutionPreset resolution_preset) = 0;
};

class CameraImpl : public Camera {
 public:
  CameraImpl(const std::string &device_id);
  virtual ~CameraImpl();

  // Disallow copy and move.
  CameraImpl(const CameraImpl &) = delete;
  CameraImpl &operator=(const CameraImpl &) = delete;

  // From CaptureControllerListener
  void OnCreateCaptureEngineSucceeded(int64_t texture_id) override;
  void OnCreateCaptureEngineFailed(const std::string &error) override;
  void OnStartPreviewSucceeded(int32_t width, int32_t height) override;
  void OnStartPreviewFailed(const std::string &error) override;
  void OnPausePreviewSucceeded() override;
  void OnPausePreviewFailed(const std::string &error) override;
  void OnResumePreviewSucceeded() override;
  void OnResumePreviewFailed(const std::string &error) override;
  void OnStartRecordSucceeded() override;
  void OnStartRecordFailed(const std::string &error) override;
  void OnStopRecordSucceeded(const std::string &filepath) override;
  void OnStopRecordFailed(const std::string &error) override;
  void OnPictureSuccess(const std::string &filepath) override;
  void OnPictureFailed(const std::string &error) override;
  void OnVideoRecordedSuccess(const std::string &filepath,
                              int64_t video_duration) override;
  void OnVideoRecordedFailed(const std::string &error) override;

  // From Camera

  bool HasDeviceId(std::string &device_id) override {
    return device_id_ == device_id;
  };

  bool HasCameraId(int64_t camera_id) override {
    return camera_id_ == camera_id;
  };

  bool AddPendingResult(PendingResultType type,
                        std::unique_ptr<MethodResult<>> result) override;

  bool HasPendingResultByType(PendingResultType type) override;

  camera_windows::CaptureController *GetCaptureController() override {
    return capture_controller_.get();
  };

  void InitCamera(flutter::TextureRegistrar *texture_registrar,
                  flutter::BinaryMessenger *messenger, bool enable_audio,
                  ResolutionPreset resolution_preset) override;

  void InitCamera(
      std::unique_ptr<CaptureControllerFactory> capture_controller_factory,
      flutter::TextureRegistrar *texture_registrar,
      flutter::BinaryMessenger *messenger, bool enable_audio,
      ResolutionPreset resolution_preset);

 private:
  std::unique_ptr<CaptureController> capture_controller_;
  flutter::BinaryMessenger *messenger_;
  int64_t camera_id_;
  std::string device_id_;

  // Pending results
  std::map<PendingResultType, std::unique_ptr<MethodResult<>>> pending_results_;
  std::unique_ptr<MethodResult<>> GetPendingResultByType(
      PendingResultType type);
  void ClearPendingResultByType(PendingResultType type);
  void ClearPendingResults();
};

class CameraFactory {
 public:
  CameraFactory(){};
  virtual ~CameraFactory() = default;

  // Disallow copy and move.
  CameraFactory(const CameraFactory &) = delete;
  CameraFactory &operator=(const CameraFactory &) = delete;

  virtual std::unique_ptr<Camera> CreateCamera(
      const std::string &device_id) = 0;
};

class CameraFactoryImpl : public CameraFactory {
 public:
  CameraFactoryImpl(){};
  virtual ~CameraFactoryImpl() = default;

  // Disallow copy and move.
  CameraFactoryImpl(const CameraFactoryImpl &) = delete;
  CameraFactoryImpl &operator=(const CameraFactoryImpl &) = delete;

  std::unique_ptr<Camera> CreateCamera(const std::string &device_id) override {
    return std::make_unique<CameraImpl>(device_id);
  };
};

}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAMERA_H_
