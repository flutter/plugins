// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAPTURE_CONTROLLER_H_
#define PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAPTURE_CONTROLLER_H_

#include <d3d11.h>
#include <flutter/texture_registrar.h>
#include <mfapi.h>
#include <mfcaptureengine.h>
#include <mferror.h>
#include <mfidl.h>
#include <windows.h>
#include <wrl/client.h>

#include <memory>
#include <string>

#include "capture_controller_listener.h"
#include "capture_engine_listener.h"
#include "photo_handler.h"
#include "preview_handler.h"
#include "record_handler.h"
#include "texture_handler.h"

namespace camera_windows {
using flutter::TextureRegistrar;
using Microsoft::WRL::ComPtr;

// Camera resolution presets. Used to request a capture resolution.
enum class ResolutionPreset {
  // Automatic resolution, uses the highest resolution available.
  kAuto,
  // 240p (320x240)
  kLow,
  // 480p (720x480)
  kMedium,
  // 720p (1280x720)
  kHigh,
  // 1080p (1920x1080)
  kVeryHigh,
  // 2160p (4096x2160)
  kUltraHigh,
  // The highest resolution available.
  kMax,
};

// Camera capture engine state.
//
// On creation, |CaptureControllers| start in state |kNotInitialized|.
// On initialization, the capture controller transitions to the |kInitializing|
// and then |kInitialized| state.
enum class CaptureEngineState { kNotInitialized, kInitializing, kInitialized };

// Interface for a class that enumerates video capture device sources.
class VideoCaptureDeviceEnumerator {
 private:
  virtual bool EnumerateVideoCaptureDeviceSources(IMFActivate*** devices,
                                                  UINT32* count) = 0;
};

// Interface implemented by capture controllers.
//
// Capture controllers are used to capture video streams or still photos from
// their associated |Camera|.
class CaptureController {
 public:
  CaptureController() {}
  virtual ~CaptureController() = default;

  // Disallow copy and move.
  CaptureController(const CaptureController&) = delete;
  CaptureController& operator=(const CaptureController&) = delete;

  // Initializes the capture controller with the specified device id.
  //
  // Returns false if the capture controller could not be initialized
  // or is already initialized.
  //
  // texture_registrar: Pointer to Flutter TextureRegistrar instance. Used to
  //                    register texture for capture preview.
  // device_id:         A string that holds information of camera device id to
  //                    be captured.
  // record_audio:      A boolean value telling if audio should be captured on
  //                    video recording.
  // resolution_preset: Maximum capture resolution height.
  virtual bool InitCaptureDevice(TextureRegistrar* texture_registrar,
                                 const std::string& device_id,
                                 bool record_audio,
                                 ResolutionPreset resolution_preset) = 0;

  // Returns preview frame width
  virtual uint32_t GetPreviewWidth() const = 0;

  // Returns preview frame height
  virtual uint32_t GetPreviewHeight() const = 0;

  // Starts the preview.
  virtual void StartPreview() = 0;

  // Pauses the preview.
  virtual void PausePreview() = 0;

  // Resumes the preview.
  virtual void ResumePreview() = 0;

  // Starts recording video.
  virtual void StartRecord(const std::string& file_path,
                           int64_t max_video_duration_ms) = 0;

  // Stops the current video recording.
  virtual void StopRecord() = 0;

  // Captures a still photo.
  virtual void TakePicture(const std::string& file_path) = 0;
};

// Concrete implementation of the |CaptureController| interface.
//
// Handles the video preview stream via a |PreviewHandler| instance, video
// capture via a |RecordHandler| instance, and still photo capture via a
// |PhotoHandler| instance.
class CaptureControllerImpl : public CaptureController,
                              public CaptureEngineObserver {
 public:
  static bool EnumerateVideoCaptureDeviceSources(IMFActivate*** devices,
                                                 UINT32* count);

  explicit CaptureControllerImpl(CaptureControllerListener* listener);
  virtual ~CaptureControllerImpl();

  // Disallow copy and move.
  CaptureControllerImpl(const CaptureControllerImpl&) = delete;
  CaptureControllerImpl& operator=(const CaptureControllerImpl&) = delete;

  // CaptureController
  bool InitCaptureDevice(TextureRegistrar* texture_registrar,
                         const std::string& device_id, bool record_audio,
                         ResolutionPreset resolution_preset) override;
  uint32_t GetPreviewWidth() const override { return preview_frame_width_; }
  uint32_t GetPreviewHeight() const override { return preview_frame_height_; }
  void StartPreview() override;
  void PausePreview() override;
  void ResumePreview() override;
  void StartRecord(const std::string& file_path,
                   int64_t max_video_duration_ms) override;
  void StopRecord() override;
  void TakePicture(const std::string& file_path) override;

  // CaptureEngineObserver
  void OnEvent(IMFMediaEvent* event) override;
  bool IsReadyForSample() const override {
    return capture_engine_state_ == CaptureEngineState::kInitialized &&
           preview_handler_ && preview_handler_->IsRunning();
  }
  bool UpdateBuffer(uint8_t* data, uint32_t data_length) override;
  void UpdateCaptureTime(uint64_t capture_time) override;

  // Sets capture engine, for testing purposes.
  void SetCaptureEngine(IMFCaptureEngine* capture_engine) {
    capture_engine_ = capture_engine;
  }

  // Sets video source, for testing purposes.
  void SetVideoSource(IMFMediaSource* video_source) {
    video_source_ = video_source;
  }

  // Sets audio source, for testing purposes.
  void SetAudioSource(IMFMediaSource* audio_source) {
    audio_source_ = audio_source;
  }

 private:
  // Helper function to return initialized state as boolean;
  bool IsInitialized() const {
    return capture_engine_state_ == CaptureEngineState::kInitialized;
  }

  // Resets capture controller state.
  // This is called if capture engine creation fails or is disposed.
  void ResetCaptureController();

  // Returns max preview height calculated from resolution present.
  uint32_t GetMaxPreviewHeight() const;

  // Uses first audio source to capture audio.
  // Note: Enumerating audio sources via platform interface is not supported.
  HRESULT CreateDefaultAudioCaptureSource();

  // Initializes video capture source from camera device.
  HRESULT CreateVideoCaptureSourceForDevice(const std::string& video_device_id);

  // Creates DX11 Device and D3D Manager.
  HRESULT CreateD3DManagerWithDX11Device();

  // Initializes capture engine object.
  HRESULT CreateCaptureEngine();

  // Enumerates video_sources media types and finds out best resolution
  // for preview and video capture.
  HRESULT FindBaseMediaTypes();

  // Stops timed video record. Called internally when record handler when max
  // recording time is exceeded.
  void StopTimedRecord();

  // Stops preview. Called internally on camera reset and dispose.
  HRESULT StopPreview();

  // Handles capture engine initalization event.
  void OnCaptureEngineInitialized(CameraResult result,
                                  const std::string& error);

  // Handles capture engine errors.
  void OnCaptureEngineError(CameraResult result, const std::string& error);

  // Handles picture events.
  void OnPicture(CameraResult result, const std::string& error);

  // Handles preview started events.
  void OnPreviewStarted(CameraResult result, const std::string& error);

  // Handles preview stopped events.
  void OnPreviewStopped(CameraResult result, const std::string& error);

  // Handles record started events.
  void OnRecordStarted(CameraResult result, const std::string& error);

  // Handles record stopped events.
  void OnRecordStopped(CameraResult result, const std::string& error);

  bool media_foundation_started_ = false;
  bool record_audio_ = false;
  uint32_t preview_frame_width_ = 0;
  uint32_t preview_frame_height_ = 0;
  UINT dx_device_reset_token_ = 0;
  std::unique_ptr<RecordHandler> record_handler_;
  std::unique_ptr<PreviewHandler> preview_handler_;
  std::unique_ptr<PhotoHandler> photo_handler_;
  std::unique_ptr<TextureHandler> texture_handler_;
  CaptureControllerListener* capture_controller_listener_;

  std::string video_device_id_;
  CaptureEngineState capture_engine_state_ =
      CaptureEngineState::kNotInitialized;
  ResolutionPreset resolution_preset_ = ResolutionPreset::kMedium;
  ComPtr<IMFCaptureEngine> capture_engine_;
  ComPtr<CaptureEngineListener> capture_engine_callback_handler_;
  ComPtr<IMFDXGIDeviceManager> dxgi_device_manager_;
  ComPtr<ID3D11Device> dx11_device_;
  ComPtr<IMFMediaType> base_capture_media_type_;
  ComPtr<IMFMediaType> base_preview_media_type_;
  ComPtr<IMFMediaSource> video_source_;
  ComPtr<IMFMediaSource> audio_source_;

  TextureRegistrar* texture_registrar_ = nullptr;
};

// Inferface for factory classes that create |CaptureController| instances.
class CaptureControllerFactory {
 public:
  CaptureControllerFactory() {}
  virtual ~CaptureControllerFactory() = default;

  // Disallow copy and move.
  CaptureControllerFactory(const CaptureControllerFactory&) = delete;
  CaptureControllerFactory& operator=(const CaptureControllerFactory&) = delete;

  // Create and return a |CaptureController| that makes callbacks on the
  // specified |CaptureControllerListener|, which must not be null.
  virtual std::unique_ptr<CaptureController> CreateCaptureController(
      CaptureControllerListener* listener) = 0;
};

// Concreate implementation of |CaptureControllerFactory|.
class CaptureControllerFactoryImpl : public CaptureControllerFactory {
 public:
  CaptureControllerFactoryImpl() {}
  virtual ~CaptureControllerFactoryImpl() = default;

  // Disallow copy and move.
  CaptureControllerFactoryImpl(const CaptureControllerFactoryImpl&) = delete;
  CaptureControllerFactoryImpl& operator=(const CaptureControllerFactoryImpl&) =
      delete;

  std::unique_ptr<CaptureController> CreateCaptureController(
      CaptureControllerListener* listener) override {
    return std::make_unique<CaptureControllerImpl>(listener);
  }
};

}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAPTURE_CONTROLLER_H_
