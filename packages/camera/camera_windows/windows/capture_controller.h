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

#include <chrono>
#include <memory>
#include <string>

#include "capture_controller_listener.h"
#include "capture_engine_listener.h"

namespace camera_windows {
using Microsoft::WRL::ComPtr;

struct FlutterDesktopPixel {
  BYTE r = 0;
  BYTE g = 0;
  BYTE b = 0;
  BYTE a = 0;
};

struct MFVideoFormatRGB32Pixel {
  BYTE b = 0;
  BYTE g = 0;
  BYTE r = 0;
  BYTE x = 0;
};

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

  virtual void InitCaptureDevice(flutter::TextureRegistrar* texture_registrar,
                                 const std::string& device_id,
                                 bool enable_audio,
                                 ResolutionPreset resolution_preset) = 0;

  virtual int64_t GetTextureId() = 0;
  virtual uint32_t GetPreviewWidth() = 0;
  virtual uint32_t GetPreviewHeight() = 0;

  // Actions
  virtual void StartPreview() = 0;
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

  // Disallow copy and move.
  CaptureControllerImpl(const CaptureControllerImpl&) = delete;
  CaptureControllerImpl& operator=(const CaptureControllerImpl&) = delete;

  bool IsInitialized() { return initialized_; }
  bool IsPreviewing() { return previewing_; }

  void InitCaptureDevice(flutter::TextureRegistrar* texture_registrar,
                         const std::string& device_id, bool enable_audio,
                         ResolutionPreset resolution_preset) override;
  int64_t GetTextureId() override { return texture_id_; }
  uint32_t GetPreviewWidth() override { return preview_frame_width_; }
  uint32_t GetPreviewHeight() override { return preview_frame_height_; }

  void StartPreview() override;
  void PausePreview() override;
  void ResumePreview() override;
  void StartRecord(const std::string& filepath,
                   int64_t max_video_duration_ms) override;
  void StopRecord() override;
  void TakePicture(const std::string filepath) override;

  // Handlers for CaptureEngineListener events
  // From CaptureEngineObserver
  bool IsReadyForSample() override {
    return initialized_ && previewing_ && !preview_paused_;
  }

  void OnEvent(IMFMediaEvent* event) override;

  uint8_t* GetSourceBuffer(uint32_t current_length) override;
  void OnBufferUpdated() override;
  void UpdateCaptureTime(uint64_t capture_time) override;

  // Sets capture engine, for mocking purposes
  void SetCaptureEngine(IMFCaptureEngine* capture_engine) {
    capture_engine_ = capture_engine;
  };

  // Sets video source, for mocking purposes
  void SetVideoSource(IMFMediaSource* video_source) {
    video_source_ = video_source;
  };

  // Sets audio source, for mocking purposes
  void SetAudioSource(IMFMediaSource* audio_source) {
    audio_source_ = audio_source;
  };

 private:
  CaptureControllerListener* capture_controller_listener_ = nullptr;
  bool initialized_ = false;
  bool enable_audio_record_ = false;
  std::string video_device_id_;

  ResolutionPreset resolution_preset_ =
      ResolutionPreset::RESOLUTION_PRESET_MEDIUM;

  // CaptureEngine objects
  bool capture_engine_initialization_pending_ = false;
  ComPtr<IMFCaptureEngine> capture_engine_;
  ComPtr<CaptureEngineListener> capture_engine_callback_handler_;

  ComPtr<IMFDXGIDeviceManager> dxgi_device_manager_;
  ComPtr<ID3D11Device> dx11_device_;
  // ID3D12Device* dx12_device_ = nullptr;
  UINT dx_device_reset_token_ = 0;

  // Sources
  ComPtr<IMFMediaSource> video_source_;
  ComPtr<IMFMediaSource> audio_source_;

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
  ComPtr<IMFMediaType> base_preview_media_type_;
  ComPtr<IMFCapturePreviewSink> preview_sink_;

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
  ComPtr<IMFMediaType> base_capture_media_type_;
  ComPtr<IMFCapturePhotoSink> photo_sink_;
  ComPtr<IMFCaptureRecordSink> record_sink_;
  std::string pending_picture_path_ = "";
  std::string pending_record_path_ = "";

  RecordingType recording_type_ = RecordingType::RECORDING_TYPE_NOT_SET;

  void ResetCaptureController();
  uint32_t GetMaxPreviewHeight();
  HRESULT CreateDefaultAudioCaptureSource();
  HRESULT CreateVideoCaptureSourceForDevice(const std::string& video_device_id);
  HRESULT CreateD3DManagerWithDX11Device();

  HRESULT CreateCaptureEngine();

  HRESULT FindBaseMediaTypes();
  HRESULT InitPreviewSink();
  HRESULT InitPhotoSink(const std::string& filepath);
  HRESULT InitRecordSink(const std::string& filepath);

  void StopTimedRecord();
  void StopPreview();

  void OnCaptureEngineInitialized(bool success, const std::string& error);
  void OnCaptureEngineError(HRESULT hr, const std::string& error);
  void OnPicture(bool success, const std::string& error);
  void OnPreviewStarted(bool success, const std::string& error);
  void OnPreviewStopped(bool success, const std::string& error);
  void OnRecordStarted(bool success, const std::string& error);
  void OnRecordStopped(bool success, const std::string& error);

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
