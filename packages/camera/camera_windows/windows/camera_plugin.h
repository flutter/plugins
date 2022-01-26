// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAMERA_PLUGIN_H_
#define PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAMERA_PLUGIN_H_

#include <flutter/flutter_view.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <functional>

#include "camera.h"
#include "capture_controller.h"
#include "capture_controller_listener.h"

namespace camera_windows {
using flutter::MethodResult;

class CameraPlugin : public flutter::Plugin,
                     public VideoCaptureDeviceEnumerator {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  CameraPlugin(flutter::TextureRegistrar* texture_registrar,
               flutter::BinaryMessenger* messenger);

  // Creates a plugin instance with the given CameraFactory instance.
  // Exists for unit testing with mock implementations.
  CameraPlugin(flutter::TextureRegistrar* texture_registrar,
               flutter::BinaryMessenger* messenger,
               std::unique_ptr<CameraFactory> camera_factory);

  virtual ~CameraPlugin();

  // Disallow copy and move.
  CameraPlugin(const CameraPlugin&) = delete;
  CameraPlugin& operator=(const CameraPlugin&) = delete;

  // Called when a method is called on plugin channel.
  void HandleMethodCall(const flutter::MethodCall<>& method_call,
                        std::unique_ptr<MethodResult<>> result);

 protected:
  // Loops through cameras and returns camera
  // with matching device_id or nullptr.
  Camera* GetCameraByDeviceId(std::string& device_id);

  // Loops through cameras and returns camera
  // with matching camera_id or nullptr.
  Camera* GetCameraByCameraId(int64_t camera_id);

  // Disposes camera by camera id.
  void DisposeCameraByCameraId(int64_t camera_id);

  // Enumerates video capture devices via static CameraController method.
  bool EnumerateVideoCaptureDeviceSources(IMFActivate*** devices,
                                          UINT32* count) override;

  std::vector<std::unique_ptr<Camera>> cameras_;

 private:
  // Handles availableCameras method calls.
  // Enumerates video capture devices and
  // returns list of available camera devices.
  void AvailableCamerasMethodHandler(
      std::unique_ptr<flutter::MethodResult<>> result);

  // Handles create method calls.
  // Creates and initializes capture controller
  // and MFCaptureEngine for requested device.
  // Stores MethodResult object to be handled after request is processed.
  void CreateMethodHandler(const EncodableMap& args,
                           std::unique_ptr<MethodResult<>> result);

  // Handles initialize method calls.
  // Requests existing camera controller to start preview.
  // Stores MethodResult object to be handled after request is processed.
  void InitializeMethodHandler(const EncodableMap& args,
                               std::unique_ptr<MethodResult<>> result);

  // Handles takePicture method calls.
  // Requests existing camera controller to take photo.
  // Stores MethodResult object to be handled after request is processed.
  void TakePictureMethodHandler(const EncodableMap& args,
                                std::unique_ptr<MethodResult<>> result);

  // Handles startVideoRecording method calls.
  // Requests existing camera controller to start recording.
  // Stores MethodResult object to be handled after request is processed.
  void StartVideoRecordingMethodHandler(const EncodableMap& args,
                                        std::unique_ptr<MethodResult<>> result);

  // Handles stopVideoRecording method calls.
  // Requests existing camera controller to stop recording.
  // Stores MethodResult object to be handled after request is processed.
  void StopVideoRecordingMethodHandler(const EncodableMap& args,
                                       std::unique_ptr<MethodResult<>> result);

  // Handles pausePreview method calls.
  // Requests existing camera controller to pause recording.
  // Stores MethodResult object to be handled after request is processed.
  void PausePreviewMethodHandler(const EncodableMap& args,
                                 std::unique_ptr<MethodResult<>> result);

  // Handles resumePreview method calls.
  // Requests existing camera controller to resume preview.
  // Stores MethodResult object to be handled after request is processed.
  void ResumePreviewMethodHandler(const EncodableMap& args,
                                  std::unique_ptr<MethodResult<>> result);

  // Handles dsipose method calls.
  // Disposes camera if exists.
  void DisposeMethodHandler(const EncodableMap& args,
                            std::unique_ptr<MethodResult<>> result);

  std::unique_ptr<CameraFactory> camera_factory_;
  flutter::TextureRegistrar* texture_registrar_;
  flutter::BinaryMessenger* messenger_;
};

}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAMERA_PLUGIN_H_
