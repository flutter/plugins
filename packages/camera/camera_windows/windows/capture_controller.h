// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAPTURE_CONTROLLER_H_
#define PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAPTURE_CONTROLLER_H_

#include <d3d11.h>
//#include <d3d12.h>
#include <flutter/texture_registrar.h>
#include <mfapi.h>
#include <mfcaptureengine.h>
#include <mferror.h>
#include <mfidl.h>
#include <windows.h>

#include <chrono>
#include <memory>
#include <string>

#include "capture_controller_listener.h"
#include "capture_engine_listener.h"

namespace camera_windows {

enum ResolutionPreset {
  /// AUTO
  RESOLUTION_PRESET_AUTO,

  /// 240p (320x240)
  RESOLUTION_PRESET_LOW,

  /// 480p (720x480)
  RESOLUTION_PRESET_MEDIUM,

  /// 720p (1280x720)
  RESOLUTION_PRESET_HIGH,

  /// 1080p (1920x1080)
  RESOLUTION_PRESET_VERY_HIGH,

  /// 2160p (4096x2160)
  RESOLUTION_PRESET_ULTRA_HIGH,

  /// The highest resolution available.
  RESOLUTION_PRESET_MAX,
};

enum RecordingType {
  RECORDING_TYPE_NOT_SET,
  RECORDING_TYPE_CONTINUOUS,
  RECORDING_TYPE_TIMED
};

template <class T>
void Release(T** ppT) {
  static_assert(std::is_base_of<IUnknown, T>::value,
                "T must inherit from IUnknown");
  if (*ppT) {
    (*ppT)->Release();
    *ppT = NULL;
  }
}

class VideoCaptureDeviceEnumerator {
 protected:
  virtual bool EnumerateVideoCaptureDeviceSources(IMFActivate*** devices,
                                                  UINT32* count) = 0;
};

class CaptureController {
 public:
  CaptureController(){};
  virtual ~CaptureController() = default;

  // Disallow copy and move.
  CaptureController(const CaptureController&) = delete;
  CaptureController& operator=(const CaptureController&) = delete;

  virtual void CreateCaptureDevice(flutter::TextureRegistrar* texture_registrar,
                                   const std::string& device_id,
                                   bool enable_audio,
                                   ResolutionPreset resolution_preset) = 0;

  virtual int64_t GetTextureId() = 0;
  virtual uint32_t GetPreviewWidth() = 0;
  virtual uint32_t GetPreviewHeight() = 0;

  // Actions
  virtual void StartPreview() = 0;
  virtual void StopPreview() = 0;
  virtual void PausePreview() = 0;
  virtual void ResumePreview() = 0;
  virtual void StartRecord(const std::string& filepath,
                           int64_t max_video_duration_ms) = 0;
  virtual void StopRecord() = 0;
  virtual void TakePicture(const std::string filepath) = 0;
};

class CaptureControllerImpl : public CaptureController,
                              public CaptureEngineObserver {
 public:
  static bool EnumerateVideoCaptureDeviceSources(IMFActivate*** devices,
                                                 UINT32* count);

  CaptureControllerImpl(CaptureControllerListener* listener);
  virtual ~CaptureControllerImpl();

  bool IsInitialized() { return initialized_; }
  bool IsPreviewing() { return previewing_; }

  void CreateCaptureDevice(flutter::TextureRegistrar* texture_registrar,
                           const std::string& device_id, bool enable_audio,
                           ResolutionPreset resolution_preset) override;
  int64_t GetTextureId() override { return texture_id_; }
  uint32_t GetPreviewWidth() override { return preview_frame_width_; }
  uint32_t GetPreviewHeight() override { return preview_frame_height_; }

  void StartPreview() override;
  void StopPreview() override;
  void PausePreview() override;
  void ResumePreview() override;
  void StartRecord(const std::string& filepath,
                   int64_t max_video_duration_ms) override;
  void StopRecord() override;
  void TakePicture(const std::string filepath) override;

  // Handlers for CaptureEngineListener events
  // From CaptureEngineObserver
  bool IsReadyForEvents() override {
    return initialized_ || capture_engine_initialization_pending_;
  };
  bool IsReadyForSample() override {
    return initialized_ && previewing_ && !preview_paused_;
  }
  void OnCaptureEngineInitialized(bool success) override;
  void OnCaptureEngineError() override;
  void OnPicture(bool success) override;
  void OnPreviewStarted(bool success) override;
  void OnPreviewStopped(bool success) override;
  void OnRecordStarted(bool success) override;
  void OnRecordStopped(bool success) override;

  uint8_t* GetSourceBuffer(uint32_t current_length) override;
  void OnBufferUpdate() override;
  void UpdateCaptureTime(uint64_t capture_time) override;

 private:
  CaptureControllerListener* capture_controller_listener_ = nullptr;
  bool initialized_ = false;
  bool enable_audio_record_ = false;

  ResolutionPreset resolution_preset_ =
      ResolutionPreset::RESOLUTION_PRESET_MEDIUM;

  // CaptureEngine objects
  bool capture_engine_initialization_pending_ = false;
  IMFCaptureEngine* capture_engine_ = nullptr;
  CaptureEngineListener* capture_engine_callback_handler_ = nullptr;

  IMFDXGIDeviceManager* dxgi_device_manager_ = nullptr;
  ID3D11Device* dx11_device_ = nullptr;
  // ID3D12Device* dx12_device_ = nullptr;
  UINT dx_device_reset_token_ = 0;

  // Sources
  IMFMediaSource* video_source_ = nullptr;
  IMFMediaSource* audio_source_ = nullptr;

  // Texture
  int64_t texture_id_ = -1;
  flutter::TextureRegistrar* texture_registrar_ = nullptr;
  std::unique_ptr<flutter::TextureVariant> texture_;

  // TODO: add release_callback and clear buffer after each frame
  FlutterDesktopPixelBuffer flutter_desktop_pixel_buffer_ = {};
  uint32_t source_buffer_size_ = 0;
  std::unique_ptr<uint8_t[]> source_buffer_data_ = nullptr;
  std::unique_ptr<uint8_t[]> dest_buffer_ = nullptr;
  uint32_t bytes_per_pixel_ = 4;  // MFVideoFormat_RGB32

  // Preview
  bool preview_paused_ = false;
  bool preview_pending_ = false;
  bool previewing_ = false;
  uint32_t preview_frame_width_ = 0;
  uint32_t preview_frame_height_ = 0;
  IMFMediaType* base_preview_media_type = nullptr;
  IMFCapturePreviewSink* preview_sink_ = nullptr;

  // Photo / Record
  bool pending_image_capture_ = false;
  bool record_start_pending_ = false;
  bool record_stop_pending_ = false;
  bool recording_ = false;
  int64_t record_start_timestamp_us_ = -1;
  uint64_t recording_duration_us_ = 0;
  int64_t max_video_duration_ms_ = -1;

  uint32_t capture_frame_width_ = 0;
  uint32_t capture_frame_height_ = 0;
  IMFMediaType* base_capture_media_type = nullptr;
  IMFCapturePhotoSink* photo_sink_ = nullptr;
  IMFCaptureRecordSink* record_sink_ = nullptr;
  std::string pending_picture_path_ = "";
  std::string pending_record_path_ = "";

  RecordingType recording_type_ = RecordingType::RECORDING_TYPE_NOT_SET;

  void ResetCaptureEngineState();
  uint32_t GetMaxPreviewHeight();
  HRESULT CreateDefaultAudioCaptureSource();
  HRESULT CreateVideoCaptureSourceForDevice(const std::string& video_device_id);
  HRESULT CreateD3DManagerWithDX11Device();

  HRESULT CreateCaptureEngine(const std::string& video_device_id);

  HRESULT FindBaseMediaTypes();
  HRESULT InitPreviewSink();
  HRESULT InitPhotoSink(const std::string& filepath);
  HRESULT InitRecordSink(const std::string& filepath);

  void StopTimedRecord();

  const FlutterDesktopPixelBuffer* ConvertPixelBufferForFlutter(size_t width,
                                                                size_t height);
};

class CaptureControllerFactory {
 public:
  CaptureControllerFactory(){};
  virtual ~CaptureControllerFactory() = default;

  // Disallow copy and move.
  CaptureControllerFactory(const CaptureControllerFactory&) = delete;
  CaptureControllerFactory& operator=(const CaptureControllerFactory&) = delete;

  virtual std::unique_ptr<CaptureController> CreateCaptureController(
      CaptureControllerListener* listener) = 0;
};

class CaptureControllerFactoryImpl : public CaptureControllerFactory {
 public:
  CaptureControllerFactoryImpl(){};
  virtual ~CaptureControllerFactoryImpl() = default;

  // Disallow copy and move.
  CaptureControllerFactoryImpl(const CaptureControllerFactoryImpl&) = delete;
  CaptureControllerFactoryImpl& operator=(const CaptureControllerFactoryImpl&) =
      delete;

  std::unique_ptr<CaptureController> CreateCaptureController(
      CaptureControllerListener* listener) override {
    return std::make_unique<CaptureControllerImpl>(listener);
  };
};

}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAPTURE_CONTROLLER_H_
