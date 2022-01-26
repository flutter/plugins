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
using flutter::MethodChannel;
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
  Camera(const std::string& device_id){};
  virtual ~Camera() = default;

  // Disallow copy and move.
  Camera(const Camera&) = delete;
  Camera& operator=(const Camera&) = delete;

  // Tests if current camera has given device id.
  virtual bool HasDeviceId(std::string& device_id) = 0;

  // Tests if current camera has given camera id.
  virtual bool HasCameraId(int64_t camera_id) = 0;

  // Adds pending result to the pending_results map.
  // Calls method result error handler, if result already exists.
  virtual bool AddPendingResult(PendingResultType type,
                                std::unique_ptr<MethodResult<>> result) = 0;

  // Checks if pending result with given type already exists.
  virtual bool HasPendingResultByType(PendingResultType type) = 0;

  // Returns pointer to capture controller.
  virtual camera_windows::CaptureController* GetCaptureController() = 0;

  // Initializes camera and capture controller.
  virtual void InitCamera(flutter::TextureRegistrar* texture_registrar,
                          flutter::BinaryMessenger* messenger,
                          bool record_audio,
                          ResolutionPreset resolution_preset) = 0;
};

class CameraImpl : public Camera {
 public:
  CameraImpl(const std::string& device_id);
  virtual ~CameraImpl();

  // Disallow copy and move.
  CameraImpl(const CameraImpl&) = delete;
  CameraImpl& operator=(const CameraImpl&) = delete;

  // From CaptureControllerListener.
  void OnCreateCaptureEngineSucceeded(int64_t texture_id) override;
  void OnCreateCaptureEngineFailed(const std::string& error) override;
  void OnStartPreviewSucceeded(int32_t width, int32_t height) override;
  void OnStartPreviewFailed(const std::string& error) override;
  void OnPausePreviewSucceeded() override;
  void OnPausePreviewFailed(const std::string& error) override;
  void OnResumePreviewSucceeded() override;
  void OnResumePreviewFailed(const std::string& error) override;
  void OnStartRecordSucceeded() override;
  void OnStartRecordFailed(const std::string& error) override;
  void OnStopRecordSucceeded(const std::string& file_path) override;
  void OnStopRecordFailed(const std::string& error) override;
  void OnTakePictureSucceeded(const std::string& file_path) override;
  void OnTakePictureFailed(const std::string& error) override;
  void OnVideoRecordSucceeded(const std::string& file_path,
                              int64_t video_duration) override;
  void OnVideoRecordFailed(const std::string& error) override;
  void OnCaptureError(const std::string& error) override;

  // From Camera.
  bool HasDeviceId(std::string& device_id) override {
    return device_id_ == device_id;
  };
  bool HasCameraId(int64_t camera_id) override {
    return camera_id_ == camera_id;
  };
  bool AddPendingResult(PendingResultType type,
                        std::unique_ptr<MethodResult<>> result) override;
  bool HasPendingResultByType(PendingResultType type) override;
  camera_windows::CaptureController* GetCaptureController() override {
    return capture_controller_.get();
  };
  void InitCamera(flutter::TextureRegistrar* texture_registrar,
                  flutter::BinaryMessenger* messenger, bool record_audio,
                  ResolutionPreset resolution_preset) override;

  // Inits camera with capture controller factory.
  // Called by InitCamera implementation but also used in tests.
  void InitCamera(
      std::unique_ptr<CaptureControllerFactory> capture_controller_factory,
      flutter::TextureRegistrar* texture_registrar,
      flutter::BinaryMessenger* messenger, bool record_audio,
      ResolutionPreset resolution_preset);

 private:
  std::unique_ptr<CaptureController> capture_controller_ = nullptr;
  std::unique_ptr<MethodChannel<>> camera_channel_ = nullptr;
  flutter::BinaryMessenger* messenger_ = nullptr;
  int64_t camera_id_ = -1;
  std::string device_id_;

  // Pending results.
  std::map<PendingResultType, std::unique_ptr<MethodResult<>>> pending_results_;
  std::unique_ptr<MethodResult<>> GetPendingResultByType(
      PendingResultType type);

  // Loops through all pending results calls their
  // error handler with given error id and description.
  // Pending results are cleared in the process.
  //
  // error_code: A string error code describing the error.
  // error_message: A user-readable error message (optional).
  void SendErrorForPendingResults(const std::string& error_code,
                                  const std::string& descripion);

  // Initializes method channel instance and returns pointer it
  MethodChannel<>* GetMethodChannel();
};

class CameraFactory {
 public:
  CameraFactory(){};
  virtual ~CameraFactory() = default;

  // Disallow copy and move.
  CameraFactory(const CameraFactory&) = delete;
  CameraFactory& operator=(const CameraFactory&) = delete;

  virtual std::unique_ptr<Camera> CreateCamera(
      const std::string& device_id) = 0;
};

class CameraFactoryImpl : public CameraFactory {
 public:
  CameraFactoryImpl(){};
  virtual ~CameraFactoryImpl() = default;

  // Disallow copy and move.
  CameraFactoryImpl(const CameraFactoryImpl&) = delete;
  CameraFactoryImpl& operator=(const CameraFactoryImpl&) = delete;

  std::unique_ptr<Camera> CreateCamera(const std::string& device_id) override {
    return std::make_unique<CameraImpl>(device_id);
  };
};

}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAMERA_H_
