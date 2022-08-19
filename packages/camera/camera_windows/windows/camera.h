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

// A set of result types that are stored
// for processing asynchronous commands.
enum class PendingResultType {
  kCreateCamera,
  kInitialize,
  kTakePicture,
  kStartRecord,
  kStopRecord,
  kPausePreview,
  kResumePreview,
};

// Interface implemented by cameras.
//
// Access is provided to an associated |CaptureController|, which can be used
// to capture video or photo from the camera.
class Camera : public CaptureControllerListener {
 public:
  explicit Camera(const std::string& device_id) {}
  virtual ~Camera() = default;

  // Disallow copy and move.
  Camera(const Camera&) = delete;
  Camera& operator=(const Camera&) = delete;

  // Tests if this camera has the specified device ID.
  virtual bool HasDeviceId(std::string& device_id) const = 0;

  // Tests if this camera has the specified camera ID.
  virtual bool HasCameraId(int64_t camera_id) const = 0;

  // Adds a pending result.
  //
  // Returns an error result if the result has already been added.
  virtual bool AddPendingResult(PendingResultType type,
                                std::unique_ptr<MethodResult<>> result) = 0;

  // Checks if a pending result of the specified type already exists.
  virtual bool HasPendingResultByType(PendingResultType type) const = 0;

  // Returns a |CaptureController| that allows capturing video or still photos
  // from this camera.
  virtual camera_windows::CaptureController* GetCaptureController() = 0;

  // Initializes this camera and its associated capture controller.
  //
  // Returns false if initialization fails.
  virtual bool InitCamera(flutter::TextureRegistrar* texture_registrar,
                          flutter::BinaryMessenger* messenger,
                          bool record_audio,
                          ResolutionPreset resolution_preset) = 0;
};

// Concrete implementation of the |Camera| interface.
//
// This implementation is responsible for initializing the capture controller,
// listening for camera events, processing pending results, and notifying
// application code of processed events via the method channel.
class CameraImpl : public Camera {
 public:
  explicit CameraImpl(const std::string& device_id);
  virtual ~CameraImpl();

  // Disallow copy and move.
  CameraImpl(const CameraImpl&) = delete;
  CameraImpl& operator=(const CameraImpl&) = delete;

  // CaptureControllerListener
  void OnCreateCaptureEngineSucceeded(int64_t texture_id) override;
  void OnCreateCaptureEngineFailed(CameraResult result,
                                   const std::string& error) override;
  void OnStartPreviewSucceeded(int32_t width, int32_t height) override;
  void OnStartPreviewFailed(CameraResult result,
                            const std::string& error) override;
  void OnPausePreviewSucceeded() override;
  void OnPausePreviewFailed(CameraResult result,
                            const std::string& error) override;
  void OnResumePreviewSucceeded() override;
  void OnResumePreviewFailed(CameraResult result,
                             const std::string& error) override;
  void OnStartRecordSucceeded() override;
  void OnStartRecordFailed(CameraResult result,
                           const std::string& error) override;
  void OnStopRecordSucceeded(const std::string& file_path) override;
  void OnStopRecordFailed(CameraResult result,
                          const std::string& error) override;
  void OnTakePictureSucceeded(const std::string& file_path) override;
  void OnTakePictureFailed(CameraResult result,
                           const std::string& error) override;
  void OnVideoRecordSucceeded(const std::string& file_path,
                              int64_t video_duration) override;
  void OnVideoRecordFailed(CameraResult result,
                           const std::string& error) override;
  void OnCaptureError(CameraResult result, const std::string& error) override;

  // Camera
  bool HasDeviceId(std::string& device_id) const override {
    return device_id_ == device_id;
  }
  bool HasCameraId(int64_t camera_id) const override {
    return camera_id_ == camera_id;
  }
  bool AddPendingResult(PendingResultType type,
                        std::unique_ptr<MethodResult<>> result) override;
  bool HasPendingResultByType(PendingResultType type) const override;
  camera_windows::CaptureController* GetCaptureController() override {
    return capture_controller_.get();
  }
  bool InitCamera(flutter::TextureRegistrar* texture_registrar,
                  flutter::BinaryMessenger* messenger, bool record_audio,
                  ResolutionPreset resolution_preset) override;

  // Initializes the camera and its associated capture controller.
  //
  // This is a convenience method called by |InitCamera| but also used in
  // tests.
  //
  // Returns false if initialization fails.
  bool InitCamera(
      std::unique_ptr<CaptureControllerFactory> capture_controller_factory,
      flutter::TextureRegistrar* texture_registrar,
      flutter::BinaryMessenger* messenger, bool record_audio,
      ResolutionPreset resolution_preset);

 private:
  // Loops through all pending results and calls their error handler with given
  // error ID and description. Pending results are cleared in the process.
  //
  // error_code: A string error code describing the error.
  // description: A user-readable error message (optional).
  void SendErrorForPendingResults(const std::string& error_code,
                                  const std::string& description);

  // Called when camera is disposed.
  // Sends camera closing message to the cameras method channel.
  void OnCameraClosing();

  // Initializes method channel instance and returns pointer it.
  MethodChannel<>* GetMethodChannel();

  // Finds pending result by type.
  // Returns nullptr if type is not present.
  std::unique_ptr<MethodResult<>> GetPendingResultByType(
      PendingResultType type);

  std::map<PendingResultType, std::unique_ptr<MethodResult<>>> pending_results_;
  std::unique_ptr<CaptureController> capture_controller_;
  std::unique_ptr<MethodChannel<>> camera_channel_;
  flutter::BinaryMessenger* messenger_ = nullptr;
  int64_t camera_id_ = -1;
  std::string device_id_;
};

// Factory class for creating |Camera| instances from a specified device ID.
class CameraFactory {
 public:
  CameraFactory() {}
  virtual ~CameraFactory() = default;

  // Disallow copy and move.
  CameraFactory(const CameraFactory&) = delete;
  CameraFactory& operator=(const CameraFactory&) = delete;

  // Creates camera for given device id.
  virtual std::unique_ptr<Camera> CreateCamera(
      const std::string& device_id) = 0;
};

// Concrete implementation of |CameraFactory|.
class CameraFactoryImpl : public CameraFactory {
 public:
  CameraFactoryImpl() {}
  virtual ~CameraFactoryImpl() = default;

  // Disallow copy and move.
  CameraFactoryImpl(const CameraFactoryImpl&) = delete;
  CameraFactoryImpl& operator=(const CameraFactoryImpl&) = delete;

  std::unique_ptr<Camera> CreateCamera(const std::string& device_id) override {
    return std::make_unique<CameraImpl>(device_id);
  }
};

}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAMERA_H_
