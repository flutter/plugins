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
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  CameraPlugin(flutter::TextureRegistrar *texture_registrar,
               flutter::BinaryMessenger *messenger);

  // Creates a plugin instance with the given CameraFactory instance.
  // Exists for unit testing with mock implementations.
  CameraPlugin(flutter::TextureRegistrar *texture_registrar,
               flutter::BinaryMessenger *messenger,
               std::unique_ptr<CameraFactory> camera_factory);

  virtual ~CameraPlugin();

  // Disallow copy and move.
  CameraPlugin(const CameraPlugin &) = delete;
  CameraPlugin &operator=(const CameraPlugin &) = delete;

  // Called when a method is called on plugin channel;
  void HandleMethodCall(const flutter::MethodCall<> &method_call,
                        std::unique_ptr<MethodResult<>> result);

 protected:
  std::vector<std::unique_ptr<Camera>> cameras_;

  Camera *GetCameraByDeviceId(std::string &device_id);
  Camera *GetCameraByCameraId(int64_t camera_id);
  void DisposeCameraByCameraId(int64_t camera_id);

  bool EnumerateVideoCaptureDeviceSources(IMFActivate ***devices,
                                          UINT32 *count) override;

 private:
  std::unique_ptr<CameraFactory> camera_factory_;
  flutter::TextureRegistrar *texture_registrar_;
  flutter::BinaryMessenger *messenger_;

  // Method handlers

  void AvailableCamerasMethodHandler(
      std::unique_ptr<flutter::MethodResult<>> result);

  void CreateMethodHandler(const EncodableMap &args,
                           std::unique_ptr<MethodResult<>> result);

  void InitializeMethodHandler(const EncodableMap &args,
                               std::unique_ptr<MethodResult<>> result);

  void TakePictureMethodHandler(const EncodableMap &args,
                                std::unique_ptr<MethodResult<>> result);

  void StartVideoRecordingMethodHandler(const EncodableMap &args,
                                        std::unique_ptr<MethodResult<>> result);

  void StopVideoRecordingMethodHandler(const EncodableMap &args,
                                       std::unique_ptr<MethodResult<>> result);

  void ResumePreviewMethodHandler(const EncodableMap &args,
                                  std::unique_ptr<MethodResult<>> result);

  void PausePreviewMethodHandler(const EncodableMap &args,
                                 std::unique_ptr<MethodResult<>> result);

  void DisposeMethodHandler(const EncodableMap &args,
                            std::unique_ptr<MethodResult<>> result);
};

}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAMERA_PLUGIN_H_
