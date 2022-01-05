// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "capture_controller.h"

#include <wincodec.h>

#include <cassert>

#include "string_utils.h"

namespace camera_windows {

struct FlutterDesktop_Pixel {
  BYTE r = 0;
  BYTE g = 0;
  BYTE b = 0;
  BYTE a = 0;
};

struct MFVideoFormat_RGB32_Pixel {
  BYTE b = 0;
  BYTE g = 0;
  BYTE r = 0;
  BYTE x = 0;
};

CaptureControllerImpl::CaptureControllerImpl(
    CaptureControllerListener *listener)
    : capture_controller_listener_(listener), CaptureController(){};

CaptureControllerImpl::~CaptureControllerImpl() {
  ResetCaptureEngineState();
  capture_controller_listener_ = nullptr;
};

// static
bool CaptureControllerImpl::EnumerateVideoCaptureDeviceSources(
    IMFActivate ***devices, UINT32 *count) {
  IMFAttributes *attributes = nullptr;

  HRESULT hr = MFCreateAttributes(&attributes, 1);

  if (SUCCEEDED(hr)) {
    hr = attributes->SetGUID(MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE,
                             MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_VIDCAP_GUID);
  }

  if (SUCCEEDED(hr)) {
    hr = MFEnumDeviceSources(attributes, devices, count);
  }

  Release(&attributes);
  return SUCCEEDED(hr);
}

HRESULT BuildMediaTypeForVideoPreview(IMFMediaType *src_media_type,
                                      IMFMediaType **preview_media_type) {
  Release(preview_media_type);
  IMFMediaType *new_media_type = nullptr;

  HRESULT hr = MFCreateMediaType(&new_media_type);

  // First clone everything from original media type
  if (SUCCEEDED(hr)) {
    hr = src_media_type->CopyAllItems(new_media_type);
  }

  if (SUCCEEDED(hr)) {
    // Change subtype to requested
    hr = new_media_type->SetGUID(MF_MT_SUBTYPE, MFVideoFormat_RGB32);
  }

  if (SUCCEEDED(hr)) {
    hr = new_media_type->SetUINT32(MF_MT_ALL_SAMPLES_INDEPENDENT, TRUE);
  }

  if (SUCCEEDED(hr)) {
    *preview_media_type = new_media_type;
    (*preview_media_type)->AddRef();
  }

  Release(&new_media_type);
  return hr;
}

// Creates media type for photo capture for jpeg images
HRESULT BuildMediaTypeForPhotoCapture(IMFMediaType *src_media_type,
                                      IMFMediaType **photo_media_type,
                                      GUID image_format) {
  Release(photo_media_type);
  IMFMediaType *new_media_type = nullptr;

  HRESULT hr = MFCreateMediaType(&new_media_type);

  // First clone everything from original media type
  if (SUCCEEDED(hr)) {
    hr = src_media_type->CopyAllItems(new_media_type);
  }

  if (SUCCEEDED(hr)) {
    hr = new_media_type->SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Image);
  }

  if (SUCCEEDED(hr)) {
    hr = new_media_type->SetGUID(MF_MT_SUBTYPE, image_format);
  }

  if (SUCCEEDED(hr)) {
    *photo_media_type = new_media_type;
    (*photo_media_type)->AddRef();
  }

  Release(&new_media_type);
  return hr;
}

// Creates media type for video capture
HRESULT BuildMediaTypeForVideoCapture(IMFMediaType *src_media_type,
                                      IMFMediaType **video_record_media_type,
                                      GUID capture_format) {
  Release(video_record_media_type);
  IMFMediaType *new_media_type = nullptr;

  HRESULT hr = MFCreateMediaType(&new_media_type);

  // First clone everything from original media type
  if (SUCCEEDED(hr)) {
    hr = src_media_type->CopyAllItems(new_media_type);
  }

  if (SUCCEEDED(hr)) {
    hr = new_media_type->SetGUID(MF_MT_SUBTYPE, capture_format);
  }

  if (SUCCEEDED(hr)) {
    *video_record_media_type = new_media_type;
    (*video_record_media_type)->AddRef();
  }

  Release(&new_media_type);
  return hr;
}

// Queries interface object from collection
template <class Q>
HRESULT GetCollectionObject(IMFCollection *pCollection, DWORD index,
                            Q **ppObj) {
  IUnknown *pUnk;
  HRESULT hr = pCollection->GetElement(index, &pUnk);
  if (SUCCEEDED(hr)) {
    hr = pUnk->QueryInterface(IID_PPV_ARGS(ppObj));
    pUnk->Release();
  }
  return hr;
}

HRESULT BuildMediaTypeForAudioCapture(IMFMediaType **audio_record_media_type) {
  Release(audio_record_media_type);

  IMFAttributes *audio_output_attributes = nullptr;
  IMFCollection *available_output_types = nullptr;
  IMFMediaType *src_media_type = nullptr;
  IMFMediaType *new_media_type = nullptr;
  DWORD mt_count = 0;

  HRESULT hr = MFCreateAttributes(&audio_output_attributes, 1);

  if (SUCCEEDED(hr)) {
    // Enumerate only low latency audio outputs
    hr = audio_output_attributes->SetUINT32(MF_LOW_LATENCY, TRUE);
  }

  if (SUCCEEDED(hr)) {
    DWORD mft_flags = (MFT_ENUM_FLAG_ALL & (~MFT_ENUM_FLAG_FIELDOFUSE)) |
                      MFT_ENUM_FLAG_SORTANDFILTER;

    hr = MFTranscodeGetAudioOutputAvailableTypes(MFAudioFormat_AAC, mft_flags,
                                                 audio_output_attributes,
                                                 &available_output_types);
  }

  if (SUCCEEDED(hr)) {
    hr = GetCollectionObject(available_output_types, 0, &src_media_type);
  }

  if (SUCCEEDED(hr)) {
    hr = available_output_types->GetElementCount(&mt_count);
  }

  if (mt_count == 0) {
    // No sources found
    hr = E_FAIL;
  }

  // Create new media type to copy original media type to
  if (SUCCEEDED(hr)) {
    hr = MFCreateMediaType(&new_media_type);
  }

  if (SUCCEEDED(hr)) {
    hr = src_media_type->CopyAllItems(new_media_type);
  }

  if (SUCCEEDED(hr)) {
    // Point target media type to new media type
    *audio_record_media_type = new_media_type;
    (*audio_record_media_type)->AddRef();
  }

  Release(&audio_output_attributes);
  Release(&available_output_types);
  Release(&src_media_type);
  Release(&new_media_type);

  return hr;
}

// Uses first audio source to capture audio. Enumerating audio sources via
// platform interface is not supported.
HRESULT CaptureControllerImpl::CreateDefaultAudioCaptureSource() {
  this->audio_source_ = nullptr;
  IMFActivate **devices = nullptr;
  UINT32 count = 0;

  IMFAttributes *attributes = nullptr;
  HRESULT hr = MFCreateAttributes(&attributes, 1);

  if (SUCCEEDED(hr)) {
    hr = attributes->SetGUID(MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE,
                             MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_AUDCAP_GUID);
  }

  if (SUCCEEDED(hr)) {
    hr = MFEnumDeviceSources(attributes, &devices, &count);
  }

  Release(&attributes);

  if (SUCCEEDED(hr) && count > 0) {
    wchar_t *audio_device_id;
    UINT32 audio_device_id_size;

    // Use first audio device
    hr = devices[0]->GetAllocatedString(
        MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_AUDCAP_ENDPOINT_ID, &audio_device_id,
        &audio_device_id_size);

    if (SUCCEEDED(hr)) {
      IMFAttributes *audio_capture_source_attributes = nullptr;
      hr = MFCreateAttributes(&audio_capture_source_attributes, 2);

      if (SUCCEEDED(hr)) {
        hr = audio_capture_source_attributes->SetGUID(
            MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE,
            MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_AUDCAP_GUID);
      }

      if (SUCCEEDED(hr)) {
        hr = audio_capture_source_attributes->SetString(
            MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_AUDCAP_ENDPOINT_ID,
            audio_device_id);
      }

      if (SUCCEEDED(hr)) {
        hr = MFCreateDeviceSource(audio_capture_source_attributes,
                                  &this->audio_source_);
      }
      Release(&audio_capture_source_attributes);
    }

    ::CoTaskMemFree(audio_device_id);
  }

  CoTaskMemFree(devices);

  return hr;
}

HRESULT CaptureControllerImpl::CreateVideoCaptureSourceForDevice(
    const std::string &video_device_id) {
  this->video_source_ = nullptr;

  IMFAttributes *video_capture_source_attributes = nullptr;

  HRESULT hr = MFCreateAttributes(&video_capture_source_attributes, 2);

  if (SUCCEEDED(hr)) {
    hr = video_capture_source_attributes->SetGUID(
        MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE,
        MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_VIDCAP_GUID);
  }

  if (SUCCEEDED(hr)) {
    hr = video_capture_source_attributes->SetString(
        MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_VIDCAP_SYMBOLIC_LINK,
        Utf16FromUtf8(video_device_id).c_str());
  }

  if (SUCCEEDED(hr)) {
    hr = MFCreateDeviceSource(video_capture_source_attributes,
                              &this->video_source_);
  }

  Release(&video_capture_source_attributes);

  return hr;
}

// Create DX11 Device and D3D Manager
// TODO: Check if DX12 device can be used with flutter:
//       Separate CreateD3DManagerWithDX12Device functionality
//       can be written if needed
//       D3D_FEATURE_LEVEL min_feature_level = D3D_FEATURE_LEVEL_9_1;
//       D3D12CreateDevice(nullptr,min_feature_level,...);
HRESULT CaptureControllerImpl::CreateD3DManagerWithDX11Device() {
  HRESULT hr = S_OK;
  /*
  // Captures selected feature level
  D3D_FEATURE_LEVEL feature_level;

  // List of allowed feature levels
  static const D3D_FEATURE_LEVEL allowed_feature_levels[] = {
      D3D_FEATURE_LEVEL_11_1, D3D_FEATURE_LEVEL_11_0, D3D_FEATURE_LEVEL_10_1,
      D3D_FEATURE_LEVEL_10_0, D3D_FEATURE_LEVEL_9_3,  D3D_FEATURE_LEVEL_9_2,
      D3D_FEATURE_LEVEL_9_1};

  hr = D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_HARDWARE, nullptr,
                         D3D11_CREATE_DEVICE_VIDEO_SUPPORT,
                         allowed_feature_levels,
                        ARRAYSIZE(allowed_feature_levels), D3D11_SDK_VERSION,
                         &dx11_device_, &feature_level, nullptr );
  */

  hr = D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_HARDWARE, nullptr,
                         D3D11_CREATE_DEVICE_VIDEO_SUPPORT, nullptr, 0,
                         D3D11_SDK_VERSION, &dx11_device_, nullptr, nullptr);

  if (SUCCEEDED(hr)) {
    // Enable multithread protection
    ID3D10Multithread *multi_thread;
    hr = dx11_device_->QueryInterface(IID_PPV_ARGS(&multi_thread));
    if (SUCCEEDED(hr)) {
      multi_thread->SetMultithreadProtected(TRUE);
    }
    Release(&multi_thread);
  }

  if (SUCCEEDED(hr)) {
    hr = MFCreateDXGIDeviceManager(&dx_device_reset_token_,
                                   &dxgi_device_manager_);
  }

  if (SUCCEEDED(hr)) {
    hr =
        dxgi_device_manager_->ResetDevice(dx11_device_, dx_device_reset_token_);
  }

  return hr;
}

HRESULT CaptureControllerImpl::CreateCaptureEngine(
    const std::string &video_device_id) {
  HRESULT hr = S_OK;
  IMFAttributes *attributes = nullptr;
  IMFCaptureEngineClassFactory *capture_engine_factory = nullptr;

  if (!capture_engine_callback_handler_) {
    capture_engine_callback_handler_ = new CaptureEngineListener(this);
    capture_engine_callback_handler_->AddRef();
  }

  if (SUCCEEDED(hr)) {
    hr = CreateD3DManagerWithDX11Device();
  }

  if (SUCCEEDED(hr)) {
    hr = MFCreateAttributes(&attributes, 2);
  }

  if (SUCCEEDED(hr)) {
    hr = attributes->SetUnknown(MF_CAPTURE_ENGINE_D3D_MANAGER,
                                dxgi_device_manager_);
  }

  if (SUCCEEDED(hr)) {
    hr = attributes->SetUINT32(MF_CAPTURE_ENGINE_USE_VIDEO_DEVICE_ONLY,
                               !enable_audio_record_);
  }

  if (SUCCEEDED(hr)) {
    hr = CoCreateInstance(CLSID_MFCaptureEngineClassFactory, nullptr,
                          CLSCTX_INPROC_SERVER,
                          IID_PPV_ARGS(&capture_engine_factory));
  }

  if (SUCCEEDED(hr)) {
    // Create CaptureEngine.
    hr = capture_engine_factory->CreateInstance(CLSID_MFCaptureEngine,
                                                IID_PPV_ARGS(&capture_engine_));
  }

  if (SUCCEEDED(hr)) {
    hr = CreateVideoCaptureSourceForDevice(video_device_id);
  }

  if (enable_audio_record_) {
    if (SUCCEEDED(hr)) {
      hr = CreateDefaultAudioCaptureSource();
    }
  }

  if (SUCCEEDED(hr)) {
    hr = capture_engine_->Initialize(capture_engine_callback_handler_,
                                     attributes, audio_source_, video_source_);
  }

  return hr;
}

void CaptureControllerImpl::ResetCaptureEngineState() {
  initialized_ = false;
  if (previewing_) {
    StopPreview();
  }

  if (recording_type_ == RecordingType::RECORDING_TYPE_CONTINUOUS) {
    StopRecord();
  } else if (recording_type_ == RecordingType::RECORDING_TYPE_TIMED) {
    StopTimedRecord();
  }

  // States
  capture_engine_initialization_pending_ = false;
  preview_pending_ = false;
  previewing_ = false;
  record_start_pending_ = false;
  record_stop_pending_ = false;
  recording_ = false;
  pending_image_capture_ = false;
  max_video_duration_ms_ = -1;
  recording_type_ = RecordingType::RECORDING_TYPE_NOT_SET;
  record_start_timestamp_us_ = -1;
  recording_duration_us_ = 0;
  max_video_duration_ms_ = -1;

  // Preview
  Release(&preview_sink_);
  preview_frame_width_ = 0;
  preview_frame_height_ = 0;

  // Photo / Record
  Release(&photo_sink_);
  Release(&record_sink_);
  capture_frame_width_ = 0;
  capture_frame_height_ = 0;

  // CaptureEngine
  Release(&capture_engine_callback_handler_);
  Release(&capture_engine_);

  Release(&audio_source_);
  Release(&video_source_);

  Release(&base_preview_media_type);
  Release(&base_capture_media_type);

  if (dxgi_device_manager_) {
    dxgi_device_manager_->ResetDevice(dx11_device_, dx_device_reset_token_);
  }
  Release(&dxgi_device_manager_);
  Release(&dx11_device_);

  // Texture
  if (texture_registrar_ && texture_id_ > -1) {
    texture_registrar_->UnregisterTexture(texture_id_);
  }
  texture_ = nullptr;
}

uint8_t *CaptureControllerImpl::GetSourceBuffer(uint32_t current_length) {
  if (this->source_buffer_data_ == nullptr ||
      this->source_buffer_size_ != current_length) {
    // Update source buffer size
    this->source_buffer_data_ = nullptr;
    this->source_buffer_data_ = std::make_unique<uint8_t[]>(current_length);
    this->source_buffer_size_ = current_length;
  }
  return this->source_buffer_data_.get();
}

void CaptureControllerImpl::OnBufferUpdate() {
  if (this->texture_registrar_ && this->texture_id_ >= 0) {
    this->texture_registrar_->MarkTextureFrameAvailable(this->texture_id_);
  }
}

void CaptureControllerImpl::UpdateCaptureTime(uint64_t capture_time_us) {
  // Check if max_video_duration_ms is passed
  if (recording_ && recording_type_ == RecordingType::RECORDING_TYPE_TIMED &&
      max_video_duration_ms_ > 0) {
    if (record_start_timestamp_us_ < 0) {
      record_start_timestamp_us_ = capture_time_us;
    }

    recording_duration_us_ = (capture_time_us - record_start_timestamp_us_);

    if (!record_stop_pending_ &&
        recording_duration_us_ >=
            (static_cast<uint64_t>(max_video_duration_ms_) * 1000)) {
      StopTimedRecord();
    }
  }
}

void CaptureControllerImpl::CreateCaptureDevice(
    flutter::TextureRegistrar *texture_registrar, const std::string &device_id,
    bool enable_audio, ResolutionPreset resolution_preset) {
  assert(capture_controller_listener_);

  if (initialized_ && texture_id_ >= 0) {
    return capture_controller_listener_->OnCreateCaptureEngineFailed(
        "Capture device already initialized");
  } else if (capture_engine_initialization_pending_) {
    return capture_controller_listener_->OnCreateCaptureEngineFailed(
        "Capture device already initializing");
  }

  // Reset current capture engine state before creating new capture engine;
  ResetCaptureEngineState();

  capture_engine_initialization_pending_ = true;
  resolution_preset_ = resolution_preset;
  enable_audio_record_ = enable_audio;
  texture_registrar_ = texture_registrar;

  HRESULT hr = CreateCaptureEngine(device_id);

  if (FAILED(hr)) {
    capture_controller_listener_->OnCreateCaptureEngineFailed(
        "Failed to create camera");
    ResetCaptureEngineState();
    return;
  }
}

const FlutterDesktopPixelBuffer *
CaptureControllerImpl::ConvertPixelBufferForFlutter(size_t target_width,
                                                    size_t target_height) {
  if (this->source_buffer_data_ && this->source_buffer_size_ > 0 &&
      this->preview_frame_width_ > 0 && this->preview_frame_height_ > 0) {
    uint32_t pixels_total =
        this->preview_frame_width_ * this->preview_frame_height_;
    dest_buffer_ = std::make_unique<uint8_t[]>(pixels_total * 4);

    MFVideoFormat_RGB32_Pixel *src =
        (MFVideoFormat_RGB32_Pixel *)this->source_buffer_data_.get();
    FlutterDesktop_Pixel *dst = (FlutterDesktop_Pixel *)dest_buffer_.get();

    for (uint32_t i = 0; i < pixels_total; i++) {
      dst[i].r = src[i].r;
      dst[i].g = src[i].g;
      dst[i].b = src[i].b;
      dst[i].a = 255;
    }

    this->flutter_desktop_pixel_buffer_.buffer = dest_buffer_.get();
    this->flutter_desktop_pixel_buffer_.width = this->preview_frame_width_;
    this->flutter_desktop_pixel_buffer_.height = this->preview_frame_height_;
    return &this->flutter_desktop_pixel_buffer_;
  }
  return nullptr;
}

void CaptureControllerImpl::TakePicture(const std::string filepath) {
  assert(capture_controller_listener_);

  if (!initialized_) {
    return capture_controller_listener_->OnPictureFailed("Not initialized");
  }

  if (pending_image_capture_) {
    return capture_controller_listener_->OnPictureFailed(
        "Already capturing image");
  }

  HRESULT hr = InitPhotoSink(filepath);

  if (SUCCEEDED(hr)) {
    // Request new photo
    pending_picture_path_ = filepath;
    pending_image_capture_ = true;
    hr = capture_engine_->TakePhoto();
  }

  if (FAILED(hr)) {
    pending_image_capture_ = false;
    pending_picture_path_ = std::string();
    return capture_controller_listener_->OnPictureFailed(
        "Failed to take picture");
  }
}

void CaptureControllerImpl::OnPicture(bool success) {
  if (capture_controller_listener_) {
    if (success && !pending_picture_path_.empty()) {
      capture_controller_listener_->OnPictureSuccess(pending_picture_path_);
    } else {
      capture_controller_listener_->OnPictureFailed("Failed to take picture");
    }
  }
  pending_image_capture_ = false;
  pending_picture_path_ = std::string();
}

void CaptureControllerImpl::OnCaptureEngineInitialized(bool success) {
  if (capture_controller_listener_) {
    // Create flutter desktop pixelbuffer texture;
    texture_ =
        std::make_unique<flutter::TextureVariant>(flutter::PixelBufferTexture(
            [this](size_t width,
                   size_t height) -> const FlutterDesktopPixelBuffer * {
              return this->ConvertPixelBufferForFlutter(width, height);
            }));

    auto new_texture_id = texture_registrar_->RegisterTexture(texture_.get());

    if (new_texture_id >= 0) {
      texture_id_ = new_texture_id;
      capture_controller_listener_->OnCreateCaptureEngineSucceeded(texture_id_);
      initialized_ = true;
    } else {
      initialized_ = false;
    }
  }
  capture_engine_initialization_pending_ = false;
}

void CaptureControllerImpl::OnCaptureEngineError() {
  // TODO: detect error type and update state depending of error type, also send
  // other than capture engine creation errors to separate error handler
  if (capture_controller_listener_) {
    capture_controller_listener_->OnCreateCaptureEngineFailed(
        "Error while capturing device");
  }

  initialized_ = false;
  capture_engine_initialization_pending_ = false;
}

void CaptureControllerImpl::OnPreviewStarted(bool success) {
  if (capture_controller_listener_) {
    if (success && preview_frame_width_ > 0 && preview_frame_height_ > 0) {
      capture_controller_listener_->OnStartPreviewSucceeded(
          preview_frame_width_, preview_frame_height_);
    } else {
      capture_controller_listener_->OnStartPreviewFailed(
          "Failed to start preview");
    }
  }

  // update state
  preview_pending_ = false;
  previewing_ = success;
};

void CaptureControllerImpl::OnPreviewStopped(bool success) {
  // update state
  previewing_ = false;
};

void CaptureControllerImpl::OnRecordStarted(bool success) {
  if (capture_controller_listener_) {
    if (success) {
      capture_controller_listener_->OnStartRecordSucceeded();
    } else {
      capture_controller_listener_->OnStartRecordFailed(
          "Failed to start recording");
    }
  }

  // update state
  record_start_pending_ = false;
  recording_ = success;
};

void CaptureControllerImpl::OnRecordStopped(bool success) {
  if (capture_controller_listener_) {
    if (recording_type_ == RecordingType::RECORDING_TYPE_CONTINUOUS) {
      if (success && !pending_record_path_.empty()) {
        capture_controller_listener_->OnStopRecordSucceeded(
            pending_record_path_);
      } else {
        capture_controller_listener_->OnStopRecordFailed(
            "Failed to record video");
      }
    } else if (recording_type_ == RecordingType::RECORDING_TYPE_TIMED) {
      if (success && !pending_record_path_.empty()) {
        capture_controller_listener_->OnVideoRecordedSuccess(
            pending_record_path_, (recording_duration_us_ / 1000));

      } else {
        capture_controller_listener_->OnVideoRecordedFailed(
            "Failed to record video");
      }
    }
  }

  // update state
  recording_ = false;
  record_stop_pending_ = false;
  recording_type_ = RecordingType::RECORDING_TYPE_NOT_SET;
  pending_record_path_ = std::string();
}

void CaptureControllerImpl::StartRecord(const std::string &filepath,
                                        int64_t max_video_duration_ms) {
  assert(capture_controller_listener_);
  if (!initialized_) {
    return capture_controller_listener_->OnStartRecordFailed(
        "Capture not initialized");
  } else if (recording_) {
    return capture_controller_listener_->OnStartRecordFailed(
        "Already recording");
  } else if (record_start_pending_) {
    return capture_controller_listener_->OnStartRecordFailed(
        "Start record already requested");
  }

  HRESULT hr = InitRecordSink(filepath);

  if (SUCCEEDED(hr)) {
    recording_type_ = max_video_duration_ms < 0
                          ? RecordingType::RECORDING_TYPE_CONTINUOUS
                          : RecordingType::RECORDING_TYPE_TIMED;
    max_video_duration_ms_ = max_video_duration_ms;
    record_start_timestamp_us_ = -1;
    recording_duration_us_ = 0;
    pending_record_path_ = filepath;
    record_start_pending_ = true;

    // Request to start recording.
    // Check MF_CAPTURE_ENGINE_RECORD_STARTED event with CaptureEngineListener
    hr = capture_engine_->StartRecord();
  }

  if (FAILED(hr)) {
    record_start_pending_ = false;
    recording_ = false;
    return capture_controller_listener_->OnStartRecordFailed(
        "Failed to initialize video recording");
  }
}

void CaptureControllerImpl::StopRecord() {
  assert(capture_controller_listener_);

  if (!initialized_) {
    return capture_controller_listener_->OnStopRecordFailed(
        "Capture not initialized");
  } else if (!recording_ && !record_start_pending_) {
    return capture_controller_listener_->OnStopRecordFailed("Not recording");
  } else if (record_stop_pending_) {
    return capture_controller_listener_->OnStopRecordFailed(
        "Stop already requested");
  }

  // Request to stop recording.
  // Check MF_CAPTURE_ENGINE_RECORD_STOPPED event with CaptureEngineListener
  record_stop_pending_ = true;
  HRESULT hr = capture_engine_->StopRecord(true, false);

  if (FAILED(hr)) {
    record_stop_pending_ = false;
    recording_ = false;
    return capture_controller_listener_->OnStopRecordFailed(
        "Failed to stop recording");
  }
}

void CaptureControllerImpl::StopTimedRecord() {
  assert(capture_controller_listener_);
  if (!recording_ && record_stop_pending_ &&
      recording_type_ != RecordingType::RECORDING_TYPE_TIMED) {
    return;
  }

  // Request to stop recording.
  // Check MF_CAPTURE_ENGINE_RECORD_STOPPED event with CaptureEngineListener
  record_stop_pending_ = true;
  HRESULT hr = capture_engine_->StopRecord(true, false);

  if (FAILED(hr)) {
    record_stop_pending_ = false;
    recording_ = false;
    return capture_controller_listener_->OnVideoRecordedFailed(
        "Failed to record video");
  }
}

uint32_t CaptureControllerImpl::GetMaxPreviewHeight() {
  switch (resolution_preset_) {
    case RESOLUTION_PRESET_LOW:
      return 240;
      break;
    case RESOLUTION_PRESET_MEDIUM:
      return 480;
      break;
    case RESOLUTION_PRESET_HIGH:
      return 720;
      break;
    case RESOLUTION_PRESET_VERY_HIGH:
      return 1080;
      break;
    case RESOLUTION_PRESET_ULTRA_HIGH:
      return 2160;
      break;
    case RESOLUTION_PRESET_AUTO:
    default:
      // no limit
      return 0xffffffff;
      break;
  }
}

HRESULT CaptureControllerImpl::FindBaseMediaTypes() {
  if (!initialized_) {
    return E_FAIL;
  }

  IMFCaptureSource *source = nullptr;
  HRESULT hr = capture_engine_->GetSource(&source);

  if (SUCCEEDED(hr)) {
    IMFMediaType *media_type = nullptr;
    uint32_t max_height = GetMaxPreviewHeight();

    // Loop native media types
    for (int i = 0;; i++) {
      // Release media type if exists from previous loop;
      Release(&media_type);

      if (FAILED(source->GetAvailableDeviceMediaType(
              (DWORD)
                  MF_CAPTURE_ENGINE_PREFERRED_SOURCE_STREAM_FOR_VIDEO_PREVIEW,
              i, &media_type))) {
        break;
      }

      uint32_t frame_width;
      uint32_t frame_height;
      if (SUCCEEDED(MFGetAttributeSize(media_type, MF_MT_FRAME_SIZE,
                                       &frame_width, &frame_height))) {
        // Update media type for photo and record capture
        if (capture_frame_width_ < frame_width ||
            capture_frame_height_ < frame_height) {
          // Release old base type if allocated
          Release(&base_capture_media_type);

          base_capture_media_type = media_type;
          base_capture_media_type->AddRef();

          capture_frame_width_ = frame_width;
          capture_frame_height_ = frame_height;
        }

        // Update media type for preview
        if (frame_height <= max_height &&
            (preview_frame_width_ < frame_width ||
             preview_frame_height_ < frame_height)) {
          // Release old base type if allocated
          Release(&base_preview_media_type);

          base_preview_media_type = media_type;
          base_preview_media_type->AddRef();

          preview_frame_width_ = frame_width;
          preview_frame_height_ = frame_height;
        }
      }
    }
    Release(&media_type);

    if (base_preview_media_type && base_capture_media_type) {
      hr = S_OK;
    } else {
      hr = E_FAIL;
    }
  }

  Release(&source);
  return hr;
}

HRESULT CaptureControllerImpl::InitPreviewSink() {
  if (!initialized_) {
    return E_FAIL;
  }

  HRESULT hr = S_OK;
  if (preview_sink_) {
    return hr;
  }

  IMFMediaType *preview_media_type = nullptr;
  IMFCaptureSink *capture_sink = nullptr;

  // Get sink with preview type;
  hr = capture_engine_->GetSink(MF_CAPTURE_ENGINE_SINK_TYPE_PREVIEW,
                                &capture_sink);

  if (SUCCEEDED(hr)) {
    hr = capture_sink->QueryInterface(IID_PPV_ARGS(&preview_sink_));
  }

  if (SUCCEEDED(hr) && !base_preview_media_type) {
    hr = FindBaseMediaTypes();
  }

  if (SUCCEEDED(hr)) {
    hr = BuildMediaTypeForVideoPreview(base_preview_media_type,
                                       &preview_media_type);
  }

  if (SUCCEEDED(hr)) {
    DWORD preview_sink_stream_index;
    hr = preview_sink_->AddStream(
        (DWORD)MF_CAPTURE_ENGINE_PREFERRED_SOURCE_STREAM_FOR_VIDEO_PREVIEW,
        preview_media_type, nullptr, &preview_sink_stream_index);

    if (SUCCEEDED(hr)) {
      hr = preview_sink_->SetSampleCallback(preview_sink_stream_index,
                                            capture_engine_callback_handler_);
    }
  }

  if (FAILED(hr)) {
    Release(&preview_sink_);
  }

  Release(&capture_sink);
  return hr;
}

HRESULT CaptureControllerImpl::InitPhotoSink(const std::string &filepath) {
  HRESULT hr = S_OK;

  if (photo_sink_) {
    // If photo sink already exists, only update output filename
    hr = photo_sink_->SetOutputFileName(Utf16FromUtf8(filepath).c_str());

    if (FAILED(hr)) {
      Release(&photo_sink_);
    }

    return hr;
  }

  IMFMediaType *photo_media_type = nullptr;
  IMFCaptureSink *capture_sink = nullptr;

  // Get sink with photo type;
  hr = capture_engine_->GetSink(MF_CAPTURE_ENGINE_SINK_TYPE_PHOTO,
                                &capture_sink);

  if (SUCCEEDED(hr)) {
    hr = capture_sink->QueryInterface(IID_PPV_ARGS(&photo_sink_));
  }

  if (SUCCEEDED(hr) && !base_capture_media_type) {
    hr = FindBaseMediaTypes();
  }

  if (SUCCEEDED(hr)) {
    hr = BuildMediaTypeForPhotoCapture(
        base_capture_media_type, &photo_media_type, GUID_ContainerFormatJpeg);
  }

  if (SUCCEEDED(hr)) {
    // Remove existing streams if available
    hr = photo_sink_->RemoveAllStreams();
  }

  if (SUCCEEDED(hr)) {
    DWORD dwSinkStreamIndex;
    hr = photo_sink_->AddStream(
        (DWORD)MF_CAPTURE_ENGINE_PREFERRED_SOURCE_STREAM_FOR_PHOTO,
        photo_media_type, nullptr, &dwSinkStreamIndex);
  }

  if (SUCCEEDED(hr)) {
    hr = photo_sink_->SetOutputFileName(Utf16FromUtf8(filepath).c_str());
  }

  if (FAILED(hr)) {
    Release(&photo_sink_);
  }

  Release(&capture_sink);
  Release(&photo_media_type);

  return hr;
}

HRESULT CaptureControllerImpl::InitRecordSink(const std::string &filepath) {
  HRESULT hr = S_OK;

  if (record_sink_) {
    // If record sink already exists, only update output filename
    hr = record_sink_->SetOutputFileName(Utf16FromUtf8(filepath).c_str());

    if (FAILED(hr)) {
      Release(&record_sink_);
    }

    return hr;
  }

  IMFMediaType *video_record_media_type = nullptr;
  IMFCaptureSink *capture_sink = nullptr;

  // Get sink with record type;
  hr = capture_engine_->GetSink(MF_CAPTURE_ENGINE_SINK_TYPE_RECORD,
                                &capture_sink);

  if (SUCCEEDED(hr)) {
    hr = capture_sink->QueryInterface(IID_PPV_ARGS(&record_sink_));
  }

  if (SUCCEEDED(hr) && !base_capture_media_type) {
    hr = FindBaseMediaTypes();
  }

  if (SUCCEEDED(hr)) {
    // Remove existing streams if available
    hr = record_sink_->RemoveAllStreams();
  }

  if (SUCCEEDED(hr)) {
    hr = BuildMediaTypeForVideoCapture(
        base_capture_media_type, &video_record_media_type, MFVideoFormat_H264);
  }

  if (SUCCEEDED(hr)) {
    DWORD video_record_sink_stream_index;
    hr = record_sink_->AddStream(
        (DWORD)MF_CAPTURE_ENGINE_PREFERRED_SOURCE_STREAM_FOR_VIDEO_RECORD,
        video_record_media_type, nullptr, &video_record_sink_stream_index);
  }

  IMFMediaType *audio_record_media_type = nullptr;
  if (SUCCEEDED(hr) && enable_audio_record_) {
    HRESULT audio_capture_hr = S_OK;
    audio_capture_hr = BuildMediaTypeForAudioCapture(&audio_record_media_type);

    if (SUCCEEDED(audio_capture_hr)) {
      DWORD audio_record_sink_stream_index;
      hr = record_sink_->AddStream(
          (DWORD)MF_CAPTURE_ENGINE_PREFERRED_SOURCE_STREAM_FOR_AUDIO,
          audio_record_media_type, nullptr, &audio_record_sink_stream_index);
    }
  }

  if (SUCCEEDED(hr)) {
    hr = record_sink_->SetOutputFileName(Utf16FromUtf8(filepath).c_str());
  }

  if (FAILED(hr)) {
    Release(&record_sink_);
  }

  Release(&capture_sink);
  Release(&video_record_media_type);
  Release(&audio_record_media_type);
  return hr;
}

void CaptureControllerImpl::StartPreview() {
  assert(capture_controller_listener_);

  if (!initialized_ || previewing_) {
    return OnPreviewStarted(false);
  }

  HRESULT hr = InitPreviewSink();

  if (SUCCEEDED(hr)) {
    preview_pending_ = true;

    // Request to start preview.
    // Check MF_CAPTURE_ENGINE_PREVIEW_STARTED event with CaptureEngineListener
    hr = capture_engine_->StartPreview();
  }

  if (FAILED(hr)) {
    return OnPreviewStarted(false);
  }
}

void CaptureControllerImpl::StopPreview() {
  assert(capture_controller_listener_);

  if (!initialized_) {
    return capture_controller_listener_->OnPausePreviewFailed(
        "Capture not initialized");
  } else if (!previewing_ && !preview_pending_) {
    return capture_controller_listener_->OnPausePreviewFailed("Not previewing");
  }

  // Request to stop preview.
  // Check MF_CAPTURE_ENGINE_PREVIEW_STOPPED event with CaptureEngineListener
  HRESULT hr = capture_engine_->StopPreview();

  if (FAILED(hr)) {
    capture_controller_listener_->OnPausePreviewFailed(
        "Failed to stop previewing");
  };
}

void CaptureControllerImpl::PausePreview() {
  if (!previewing_) {
    preview_paused_ = false;
    return capture_controller_listener_->OnPausePreviewFailed(
        "Preview not started");
  }
  preview_paused_ = true;
  capture_controller_listener_->OnPausePreviewSucceeded();
}

void CaptureControllerImpl::ResumePreview() {
  preview_paused_ = false;
  capture_controller_listener_->OnResumePreviewSucceeded();
}
}  // namespace camera_windows
