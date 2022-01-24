// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "capture_controller.h"

#include <wincodec.h>
#include <wrl/client.h>

#include <cassert>
#include <system_error>

#include "string_utils.h"

namespace camera_windows {

using Microsoft::WRL::ComPtr;

CaptureControllerImpl::CaptureControllerImpl(
    CaptureControllerListener *listener)
    : capture_controller_listener_(listener), CaptureController(){};

CaptureControllerImpl::~CaptureControllerImpl() {
  ResetCaptureController();
  capture_controller_listener_ = nullptr;
};

// static
bool CaptureControllerImpl::EnumerateVideoCaptureDeviceSources(
    IMFActivate ***devices, UINT32 *count) {
  ComPtr<IMFAttributes> attributes;

  HRESULT hr = MFCreateAttributes(&attributes, 1);

  if (SUCCEEDED(hr)) {
    hr = attributes->SetGUID(MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE,
                             MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_VIDCAP_GUID);
  }

  if (SUCCEEDED(hr)) {
    hr = MFEnumDeviceSources(attributes.Get(), devices, count);
  }

  return SUCCEEDED(hr);
}

HRESULT BuildMediaTypeForVideoPreview(IMFMediaType *src_media_type,
                                      IMFMediaType **preview_media_type) {
  assert(src_media_type);
  ComPtr<IMFMediaType> new_media_type;

  HRESULT hr = MFCreateMediaType(&new_media_type);

  if (SUCCEEDED(hr)) {
    // Clones everything from original media type.
    hr = src_media_type->CopyAllItems(new_media_type.Get());
  }

  if (SUCCEEDED(hr)) {
    // Changes subtype to MFVideoFormat_RGB32.
    hr = new_media_type->SetGUID(MF_MT_SUBTYPE, MFVideoFormat_RGB32);
  }

  if (SUCCEEDED(hr)) {
    hr = new_media_type->SetUINT32(MF_MT_ALL_SAMPLES_INDEPENDENT, TRUE);
  }

  if (SUCCEEDED(hr)) {
    new_media_type.CopyTo(preview_media_type);
  }

  return hr;
}

// Initializes media type for photo capture for jpeg images.
HRESULT BuildMediaTypeForPhotoCapture(IMFMediaType *src_media_type,
                                      IMFMediaType **photo_media_type,
                                      GUID image_format) {
  assert(src_media_type);
  ComPtr<IMFMediaType> new_media_type;

  HRESULT hr = MFCreateMediaType(&new_media_type);

  if (SUCCEEDED(hr)) {
    // Clones everything from original media type.
    hr = src_media_type->CopyAllItems(new_media_type.Get());
  }

  if (SUCCEEDED(hr)) {
    hr = new_media_type->SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Image);
  }

  if (SUCCEEDED(hr)) {
    hr = new_media_type->SetGUID(MF_MT_SUBTYPE, image_format);
  }

  if (SUCCEEDED(hr)) {
    new_media_type.CopyTo(photo_media_type);
  }

  return hr;
}

// Initializes media type for video capture.
HRESULT BuildMediaTypeForVideoCapture(IMFMediaType *src_media_type,
                                      IMFMediaType **video_record_media_type,
                                      GUID capture_format) {
  assert(src_media_type);
  ComPtr<IMFMediaType> new_media_type;

  HRESULT hr = MFCreateMediaType(&new_media_type);

  if (SUCCEEDED(hr)) {
    // Clones everything from original media type.
    hr = src_media_type->CopyAllItems(new_media_type.Get());
  }

  if (SUCCEEDED(hr)) {
    hr = new_media_type->SetGUID(MF_MT_SUBTYPE, capture_format);
  }

  if (SUCCEEDED(hr)) {
    new_media_type.CopyTo(video_record_media_type);
  }

  return hr;
}

// Queries interface object from collection.
template <class Q>
HRESULT GetCollectionObject(IMFCollection *pCollection, DWORD index,
                            Q **ppObj) {
  ComPtr<IUnknown> pUnk;
  HRESULT hr = pCollection->GetElement(index, pUnk.GetAddressOf());
  if (SUCCEEDED(hr)) {
    hr = pUnk->QueryInterface(IID_PPV_ARGS(ppObj));
  }
  return hr;
}

// Initializes media type for audo capture.
HRESULT BuildMediaTypeForAudioCapture(IMFMediaType **audio_record_media_type) {
  ComPtr<IMFAttributes> audio_output_attributes;
  ComPtr<IMFMediaType> src_media_type;
  ComPtr<IMFMediaType> new_media_type;
  ComPtr<IMFCollection> available_output_types;
  DWORD mt_count = 0;

  HRESULT hr = MFCreateAttributes(&audio_output_attributes, 1);

  if (SUCCEEDED(hr)) {
    // Enumerates only low latency audio outputs.
    hr = audio_output_attributes->SetUINT32(MF_LOW_LATENCY, TRUE);
  }

  if (SUCCEEDED(hr)) {
    DWORD mft_flags = (MFT_ENUM_FLAG_ALL & (~MFT_ENUM_FLAG_FIELDOFUSE)) |
                      MFT_ENUM_FLAG_SORTANDFILTER;

    hr = MFTranscodeGetAudioOutputAvailableTypes(
        MFAudioFormat_AAC, mft_flags, audio_output_attributes.Get(),
        available_output_types.GetAddressOf());
  }

  if (SUCCEEDED(hr)) {
    hr = GetCollectionObject(available_output_types.Get(), 0,
                             src_media_type.GetAddressOf());
  }

  if (SUCCEEDED(hr)) {
    hr = available_output_types->GetElementCount(&mt_count);
  }

  if (mt_count == 0) {
    // No sources found, mark process as failure.
    hr = E_FAIL;
  }

  if (SUCCEEDED(hr)) {
    // Create new media type to copy original media type to.
    hr = MFCreateMediaType(&new_media_type);
  }

  if (SUCCEEDED(hr)) {
    hr = src_media_type->CopyAllItems(new_media_type.Get());
  }

  if (SUCCEEDED(hr)) {
    new_media_type.CopyTo(audio_record_media_type);
  }

  return hr;
}

// Uses first audio source to capture audio.
// Note: Enumerating audio sources via platform interface is not supported.
HRESULT CaptureControllerImpl::CreateDefaultAudioCaptureSource() {
  audio_source_ = nullptr;
  IMFActivate **devices = nullptr;
  UINT32 count = 0;

  ComPtr<IMFAttributes> attributes;
  HRESULT hr = MFCreateAttributes(&attributes, 1);

  if (SUCCEEDED(hr)) {
    hr = attributes->SetGUID(MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE,
                             MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_AUDCAP_GUID);
  }

  if (SUCCEEDED(hr)) {
    hr = MFEnumDeviceSources(attributes.Get(), &devices, &count);
  }

  if (SUCCEEDED(hr) && count > 0) {
    wchar_t *audio_device_id;
    UINT32 audio_device_id_size;

    // Use first audio device
    hr = devices[0]->GetAllocatedString(
        MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_AUDCAP_ENDPOINT_ID, &audio_device_id,
        &audio_device_id_size);

    if (SUCCEEDED(hr)) {
      ComPtr<IMFAttributes> audio_capture_source_attributes;
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
        hr = MFCreateDeviceSource(audio_capture_source_attributes.Get(),
                                  audio_source_.GetAddressOf());
      }
    }

    CoTaskMemFree(audio_device_id);
  }

  CoTaskMemFree(devices);

  return hr;
}

HRESULT CaptureControllerImpl::CreateVideoCaptureSourceForDevice(
    const std::string &video_device_id) {
  video_source_ = nullptr;

  ComPtr<IMFAttributes> video_capture_source_attributes;

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
    hr = MFCreateDeviceSource(video_capture_source_attributes.Get(),
                              video_source_.GetAddressOf());
  }

  return hr;
}

// Create DX11 Device and D3D Manager
// TODO: If DX12 device can be used with flutter:
//       Separate CreateD3DManagerWithDX12Device functionality
//       can be written if needed
// TODO: Should shared ANGLE device be used?
HRESULT CaptureControllerImpl::CreateD3DManagerWithDX11Device() {
  HRESULT hr = S_OK;
  hr = D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_HARDWARE, nullptr,
                         D3D11_CREATE_DEVICE_VIDEO_SUPPORT, nullptr, 0,
                         D3D11_SDK_VERSION, &dx11_device_, nullptr, nullptr);

  if (SUCCEEDED(hr)) {
    // Enable multithread protection
    ComPtr<ID3D10Multithread> multi_thread;
    hr = dx11_device_.As(&multi_thread);
    if (SUCCEEDED(hr)) {
      multi_thread->SetMultithreadProtected(TRUE);
    }
  }

  if (SUCCEEDED(hr)) {
    hr = MFCreateDXGIDeviceManager(&dx_device_reset_token_,
                                   dxgi_device_manager_.GetAddressOf());
  }

  if (SUCCEEDED(hr)) {
    hr = dxgi_device_manager_->ResetDevice(dx11_device_.Get(),
                                           dx_device_reset_token_);
  }

  return hr;
}

HRESULT CaptureControllerImpl::CreateCaptureEngine() {
  assert(!video_device_id_.empty());

  HRESULT hr = S_OK;
  ComPtr<IMFAttributes> attributes;

  // Creates capture engine only if not already initialized by test framework
  if (!capture_engine_) {
    ComPtr<IMFCaptureEngineClassFactory> capture_engine_factory;

    if (SUCCEEDED(hr)) {
      hr = CoCreateInstance(CLSID_MFCaptureEngineClassFactory, nullptr,
                            CLSCTX_INPROC_SERVER,
                            IID_PPV_ARGS(&capture_engine_factory));
    }

    if (SUCCEEDED(hr)) {
      // Creates CaptureEngine.
      hr = capture_engine_factory->CreateInstance(
          CLSID_MFCaptureEngine, IID_PPV_ARGS(&capture_engine_));
    }
  }

  if (SUCCEEDED(hr)) {
    hr = CreateD3DManagerWithDX11Device();
  }

  if (SUCCEEDED(hr) && !video_source_) {
    hr = CreateVideoCaptureSourceForDevice(video_device_id_);
  }

  if (enable_audio_record_ && !audio_source_) {
    if (SUCCEEDED(hr)) {
      hr = CreateDefaultAudioCaptureSource();
    }
  }

  if (!capture_engine_callback_handler_) {
    capture_engine_callback_handler_ =
        ComPtr<CaptureEngineListener>(new CaptureEngineListener(this));
  }

  if (SUCCEEDED(hr)) {
    hr = MFCreateAttributes(&attributes, 2);
  }

  if (SUCCEEDED(hr)) {
    hr = attributes->SetUnknown(MF_CAPTURE_ENGINE_D3D_MANAGER,
                                dxgi_device_manager_.Get());
  }

  if (SUCCEEDED(hr)) {
    hr = attributes->SetUINT32(MF_CAPTURE_ENGINE_USE_VIDEO_DEVICE_ONLY,
                               !enable_audio_record_);
  }

  if (SUCCEEDED(hr)) {
    hr = capture_engine_->Initialize(capture_engine_callback_handler_.Get(),
                                     attributes.Get(), audio_source_.Get(),
                                     video_source_.Get());
  }

  return hr;
}

void CaptureControllerImpl::ResetCaptureController() {
  if (previewing_) {
    StopPreview();
  }

  if (recording_type_ == RecordingType::RECORDING_TYPE_CONTINUOUS) {
    StopRecord();
  } else if (recording_type_ == RecordingType::RECORDING_TYPE_TIMED) {
    StopTimedRecord();
  }

  // States
  initialized_ = false;
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
  preview_sink_ = nullptr;
  preview_frame_width_ = 0;
  preview_frame_height_ = 0;

  // Photo / Record
  photo_sink_ = nullptr;
  record_sink_ = nullptr;
  capture_frame_width_ = 0;
  capture_frame_height_ = 0;

  // CaptureEngine
  capture_engine_callback_handler_ = nullptr;
  capture_engine_ = nullptr;

  audio_source_ = nullptr;
  video_source_ = nullptr;

  base_preview_media_type_ = nullptr;
  base_capture_media_type_ = nullptr;

  if (dxgi_device_manager_) {
    dxgi_device_manager_->ResetDevice(dx11_device_.Get(),
                                      dx_device_reset_token_);
  }
  dxgi_device_manager_ = nullptr;
  dx11_device_ = nullptr;

  // Texture
  if (texture_registrar_ && texture_id_ > -1) {
    texture_registrar_->UnregisterTexture(texture_id_);
  }
  texture_ = nullptr;
}

void CaptureControllerImpl::InitCaptureDevice(
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

  capture_engine_initialization_pending_ = true;
  resolution_preset_ = resolution_preset;
  enable_audio_record_ = enable_audio;
  texture_registrar_ = texture_registrar;
  video_device_id_ = device_id;

  HRESULT hr = CreateCaptureEngine();

  if (FAILED(hr)) {
    capture_controller_listener_->OnCreateCaptureEngineFailed(
        "Failed to create camera");
    ResetCaptureController();
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

    MFVideoFormatRGB32Pixel *src =
        (MFVideoFormatRGB32Pixel *)this->source_buffer_data_.get();
    FlutterDesktopPixel *dst = (FlutterDesktopPixel *)dest_buffer_.get();

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
    return capture_controller_listener_->OnTakePictureFailed("Not initialized");
  }

  if (pending_image_capture_) {
    return capture_controller_listener_->OnTakePictureFailed(
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
    return capture_controller_listener_->OnTakePictureFailed(
        "Failed to take picture");
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

  ComPtr<IMFCaptureSource> source;
  HRESULT hr = capture_engine_->GetSource(&source);

  if (SUCCEEDED(hr)) {
    ComPtr<IMFMediaType> media_type;
    uint32_t max_height = GetMaxPreviewHeight();

    // Loop native media types
    for (int i = 0;; i++) {
      // Release media type if exists from previous loop;
      media_type = nullptr;

      if (FAILED(source->GetAvailableDeviceMediaType(
              (DWORD)
                  MF_CAPTURE_ENGINE_PREFERRED_SOURCE_STREAM_FOR_VIDEO_PREVIEW,
              i, media_type.GetAddressOf()))) {
        break;
      }

      uint32_t frame_width;
      uint32_t frame_height;
      if (SUCCEEDED(MFGetAttributeSize(media_type.Get(), MF_MT_FRAME_SIZE,
                                       &frame_width, &frame_height))) {
        // Update media type for photo and record capture
        if (capture_frame_width_ < frame_width ||
            capture_frame_height_ < frame_height) {
          base_capture_media_type_ = media_type;

          capture_frame_width_ = frame_width;
          capture_frame_height_ = frame_height;
        }

        // Update media type for preview
        if (frame_height <= max_height &&
            (preview_frame_width_ < frame_width ||
             preview_frame_height_ < frame_height)) {
          base_preview_media_type_ = media_type;

          preview_frame_width_ = frame_width;
          preview_frame_height_ = frame_height;
        }
      }
    }

    if (base_preview_media_type_ && base_capture_media_type_) {
      hr = S_OK;
    } else {
      hr = E_FAIL;
    }
  }

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

  ComPtr<IMFMediaType> preview_media_type;
  ComPtr<IMFCaptureSink> capture_sink;

  // Get sink with preview type.
  hr = capture_engine_->GetSink(MF_CAPTURE_ENGINE_SINK_TYPE_PREVIEW,
                                &capture_sink);

  if (capture_sink && SUCCEEDED(hr)) {
    hr = capture_sink.As(&preview_sink_);
  }

  if (preview_sink_ && SUCCEEDED(hr)) {
    hr = preview_sink_->RemoveAllStreams();
  }

  if (SUCCEEDED(hr) && !base_preview_media_type_) {
    hr = FindBaseMediaTypes();
  }

  if (SUCCEEDED(hr)) {
    hr = BuildMediaTypeForVideoPreview(base_preview_media_type_.Get(),
                                       preview_media_type.GetAddressOf());
  }

  if (SUCCEEDED(hr)) {
    DWORD preview_sink_stream_index;
    hr = preview_sink_->AddStream(
        (DWORD)MF_CAPTURE_ENGINE_PREFERRED_SOURCE_STREAM_FOR_VIDEO_PREVIEW,
        preview_media_type.Get(), nullptr, &preview_sink_stream_index);

    if (SUCCEEDED(hr)) {
      hr = preview_sink_->SetSampleCallback(
          preview_sink_stream_index, capture_engine_callback_handler_.Get());
    }
  }

  if (FAILED(hr)) {
    preview_sink_ = nullptr;
  }

  return hr;
}

HRESULT CaptureControllerImpl::InitPhotoSink(const std::string &filepath) {
  HRESULT hr = S_OK;

  if (photo_sink_) {
    // If photo sink already exists, only update output filename.
    hr = photo_sink_->SetOutputFileName(Utf16FromUtf8(filepath).c_str());

    if (FAILED(hr)) {
      photo_sink_ = nullptr;
    }

    return hr;
  }

  ComPtr<IMFMediaType> photo_media_type;
  ComPtr<IMFCaptureSink> capture_sink;

  // Gets sink with photo type.
  hr = capture_engine_->GetSink(MF_CAPTURE_ENGINE_SINK_TYPE_PHOTO,
                                &capture_sink);

  if (SUCCEEDED(hr)) {
    hr = capture_sink.As(&photo_sink_);
  }

  if (SUCCEEDED(hr) && !base_capture_media_type_) {
    hr = FindBaseMediaTypes();
  }

  if (SUCCEEDED(hr)) {
    hr = BuildMediaTypeForPhotoCapture(base_capture_media_type_.Get(),
                                       photo_media_type.GetAddressOf(),
                                       GUID_ContainerFormatJpeg);
  }

  if (SUCCEEDED(hr)) {
    // Removes existing streams if available.
    hr = photo_sink_->RemoveAllStreams();
  }

  if (SUCCEEDED(hr)) {
    DWORD dwSinkStreamIndex;
    hr = photo_sink_->AddStream(
        (DWORD)MF_CAPTURE_ENGINE_PREFERRED_SOURCE_STREAM_FOR_PHOTO,
        photo_media_type.Get(), nullptr, &dwSinkStreamIndex);
  }

  if (SUCCEEDED(hr)) {
    hr = photo_sink_->SetOutputFileName(Utf16FromUtf8(filepath).c_str());
  }

  if (FAILED(hr)) {
    photo_sink_ = nullptr;
  }

  return hr;
}

HRESULT CaptureControllerImpl::InitRecordSink(const std::string &filepath) {
  HRESULT hr = S_OK;

  if (record_sink_) {
    // If record sink already exists, only update output filename.
    hr = record_sink_->SetOutputFileName(Utf16FromUtf8(filepath).c_str());

    if (FAILED(hr)) {
      record_sink_ = nullptr;
    }

    return hr;
  }

  ComPtr<IMFMediaType> video_record_media_type;
  ComPtr<IMFCaptureSink> capture_sink;

  // Gets sink with record type.
  hr = capture_engine_->GetSink(MF_CAPTURE_ENGINE_SINK_TYPE_RECORD,
                                &capture_sink);

  if (SUCCEEDED(hr)) {
    hr = capture_sink.As(&record_sink_);
  }

  if (SUCCEEDED(hr) && !base_capture_media_type_) {
    hr = FindBaseMediaTypes();
  }

  if (SUCCEEDED(hr)) {
    // Removes existing streams if available.
    hr = record_sink_->RemoveAllStreams();
  }

  if (SUCCEEDED(hr)) {
    hr = BuildMediaTypeForVideoCapture(base_capture_media_type_.Get(),
                                       video_record_media_type.GetAddressOf(),
                                       MFVideoFormat_H264);
  }

  if (SUCCEEDED(hr)) {
    DWORD video_record_sink_stream_index;
    hr = record_sink_->AddStream(
        (DWORD)MF_CAPTURE_ENGINE_PREFERRED_SOURCE_STREAM_FOR_VIDEO_RECORD,
        video_record_media_type.Get(), nullptr,
        &video_record_sink_stream_index);
  }

  ComPtr<IMFMediaType> audio_record_media_type;
  if (SUCCEEDED(hr) && enable_audio_record_) {
    HRESULT audio_capture_hr = S_OK;
    audio_capture_hr =
        BuildMediaTypeForAudioCapture(audio_record_media_type.GetAddressOf());

    if (SUCCEEDED(audio_capture_hr)) {
      DWORD audio_record_sink_stream_index;
      hr = record_sink_->AddStream(
          (DWORD)MF_CAPTURE_ENGINE_PREFERRED_SOURCE_STREAM_FOR_AUDIO,
          audio_record_media_type.Get(), nullptr,
          &audio_record_sink_stream_index);
    }
  }

  if (SUCCEEDED(hr)) {
    hr = record_sink_->SetOutputFileName(Utf16FromUtf8(filepath).c_str());
  }

  if (FAILED(hr)) {
    record_sink_ = nullptr;
  }

  return hr;
}

// Starts recording.
// Check MF_CAPTURE_ENGINE_RECORD_STARTED event handling for response process.
void CaptureControllerImpl::StartRecord(const std::string &filepath,
                                        int64_t max_video_duration_ms) {
  assert(capture_controller_listener_);
  if (!initialized_) {
    return capture_controller_listener_->OnStartRecordFailed(
        "Camera not initialized. Camera should be disposed and reinitialized.");
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

// Stops recording.
// Check MF_CAPTURE_ENGINE_RECORD_STOPPED event handling for response process.
void CaptureControllerImpl::StopRecord() {
  assert(capture_controller_listener_);

  if (!initialized_) {
    return capture_controller_listener_->OnStopRecordFailed(
        "Camera not initialized. Camera should be disposed and reinitialized.");
  } else if (!recording_ && !record_start_pending_) {
    return capture_controller_listener_->OnStopRecordFailed("Not recording");
  } else if (record_stop_pending_) {
    return capture_controller_listener_->OnStopRecordFailed(
        "Stop already requested");
  }

  // Request to stop recording.
  record_stop_pending_ = true;
  HRESULT hr = capture_engine_->StopRecord(true, false);

  if (FAILED(hr)) {
    record_stop_pending_ = false;
    recording_ = false;
    return capture_controller_listener_->OnStopRecordFailed(
        "Failed to stop recording");
  }
}

// Stops timed recording. Called internally when requested time is passed.
// Check MF_CAPTURE_ENGINE_RECORD_STOPPED event handling for response process.
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
    return capture_controller_listener_->OnVideoRecordFailed(
        "Failed to record video");
  }
}

// Starts capturing preview frames using preview sink
// After first frame is captured, OnPreviewStarted is called
void CaptureControllerImpl::StartPreview() {
  assert(capture_controller_listener_);

  if (!initialized_) {
    return OnPreviewStarted(
        false,
        "Camera not initialized. Camera should be disposed and reinitialized.");
  }

  if (previewing_) {
    // Return success if preview already started
    return OnPreviewStarted(true, "");
  }

  HRESULT hr = InitPreviewSink();

  if (SUCCEEDED(hr)) {
    preview_pending_ = true;

    // Requests to start preview.
    hr = capture_engine_->StartPreview();
  }

  if (FAILED(hr)) {
    return OnPreviewStarted(false, "Failed to start preview");
  }
}

// Stops preview. Called by destructor
// Use PausePreview and ResumePreview methods to for
// pausing and resuming the preview.
// Check MF_CAPTURE_ENGINE_PREVIEW_STOPPED event handling for response process.
void CaptureControllerImpl::StopPreview() {
  assert(capture_controller_listener_);

  if (!initialized_ && (!previewing_ && !preview_pending_)) {
    return;
  }

  // Requests to stop preview.
  capture_engine_->StopPreview();
}

// Marks preview as paused.
// When preview is paused, captured frames are not processed for preview
// and flutter texture is not updated
void CaptureControllerImpl::PausePreview() {
  if (!previewing_) {
    preview_paused_ = false;

    if (capture_controller_listener_) {
      return capture_controller_listener_->OnPausePreviewFailed(
          "Preview not started");
    }
  }
  preview_paused_ = true;

  if (capture_controller_listener_) {
    capture_controller_listener_->OnPausePreviewSucceeded();
  }
}

// Marks preview as not paused.
// When preview is not paused, captured frames are processed for preview
// and flutter texture is updated.
void CaptureControllerImpl::ResumePreview() {
  preview_paused_ = false;
  if (capture_controller_listener_) {
    capture_controller_listener_->OnResumePreviewSucceeded();
  }
}

// Handles capture engine events.
// Called via IMFCaptureEngineOnEventCallback implementation.
// Implements CaptureEngineObserver::OnEvent.
void CaptureControllerImpl::OnEvent(IMFMediaEvent *event) {
  if (!initialized_ && !capture_engine_initialization_pending_) {
    return;
  }

  HRESULT event_hr;
  HRESULT hr = event->GetStatus(&event_hr);

  GUID extended_type_guid;
  if (SUCCEEDED(hr)) {
    hr = event->GetExtendedType(&extended_type_guid);
  }

  if (SUCCEEDED(hr)) {
    std::string error;
    if (FAILED(event_hr)) {
      error = std::system_category().message(event_hr);
    }

    if (extended_type_guid == MF_CAPTURE_ENGINE_ERROR) {
      OnCaptureEngineError(event_hr, error);
    } else if (extended_type_guid == MF_CAPTURE_ENGINE_INITIALIZED) {
      OnCaptureEngineInitialized(SUCCEEDED(event_hr), error);
    } else if (extended_type_guid == MF_CAPTURE_ENGINE_PREVIEW_STARTED) {
      // Preview is marked as started after first frame is captured.
      // This is because, CaptureEngine might inform that preview is started
      // even if error is thrown right after.
    } else if (extended_type_guid == MF_CAPTURE_ENGINE_PREVIEW_STOPPED) {
      OnPreviewStopped(SUCCEEDED(event_hr), error);
    } else if (extended_type_guid == MF_CAPTURE_ENGINE_RECORD_STARTED) {
      OnRecordStarted(SUCCEEDED(event_hr), error);
    } else if (extended_type_guid == MF_CAPTURE_ENGINE_RECORD_STOPPED) {
      OnRecordStopped(SUCCEEDED(event_hr), error);
    } else if (extended_type_guid == MF_CAPTURE_ENGINE_PHOTO_TAKEN) {
      OnPicture(SUCCEEDED(event_hr), error);
    } else if (extended_type_guid == MF_CAPTURE_ENGINE_CAMERA_STREAM_BLOCKED) {
      // TODO: Inform capture state to flutter.
    } else if (extended_type_guid ==
               MF_CAPTURE_ENGINE_CAMERA_STREAM_UNBLOCKED) {
      // TODO: Inform capture state to flutter.
    }
  }
}

// Handles Picture event and informs CaptureControllerListener.
void CaptureControllerImpl::OnPicture(bool success, const std::string &error) {
  if (capture_controller_listener_) {
    if (success && !pending_picture_path_.empty()) {
      capture_controller_listener_->OnTakePictureSucceeded(
          pending_picture_path_);
    } else {
      capture_controller_listener_->OnTakePictureFailed(error);
    }
  }
  pending_image_capture_ = false;
  pending_picture_path_ = std::string();
}

// Handles CaptureEngineInitialized event and informs CaptureControllerListener.
void CaptureControllerImpl::OnCaptureEngineInitialized(
    bool success, const std::string &error) {
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
      texture_ = nullptr;
      texture_id_ = -1;
      capture_controller_listener_->OnCreateCaptureEngineFailed(
          "Failed to create texture_id");
      initialized_ = false;
    }
  }

  capture_engine_initialization_pending_ = false;
}

// Handles CaptureEngineError event and informs CaptureControllerListener.
void CaptureControllerImpl::OnCaptureEngineError(HRESULT hr,
                                                 const std::string &error) {
  if (capture_controller_listener_) {
    capture_controller_listener_->OnCaptureError(error);
  }

  // TODO: If MF_CAPTURE_ENGINE_ERROR is returned,
  // should capture controller be reinitialized automatically?
}

// Handles PreviewStarted event and informs CaptureControllerListener.
void CaptureControllerImpl::OnPreviewStarted(bool success,
                                             const std::string &error) {
  if (capture_controller_listener_) {
    if (success && preview_frame_width_ > 0 && preview_frame_height_ > 0) {
      capture_controller_listener_->OnStartPreviewSucceeded(
          preview_frame_width_, preview_frame_height_);
    } else {
      capture_controller_listener_->OnStartPreviewFailed(error);
    }
  }

  // update state
  preview_pending_ = false;
  previewing_ = success;
};

// Handles PreviewStopped event.
void CaptureControllerImpl::OnPreviewStopped(bool success,
                                             const std::string &error) {
  // update state
  previewing_ = false;
};

// Handles RecordStarted event and informs CaptureControllerListener.
void CaptureControllerImpl::OnRecordStarted(bool success,
                                            const std::string &error) {
  if (capture_controller_listener_) {
    if (success) {
      capture_controller_listener_->OnStartRecordSucceeded();
    } else {
      capture_controller_listener_->OnStartRecordFailed(error);
    }
  }

  // update state
  record_start_pending_ = false;
  recording_ = success;
};

// Handles RecordStopped event and informs CaptureControllerListener.
void CaptureControllerImpl::OnRecordStopped(bool success,
                                            const std::string &error) {
  if (capture_controller_listener_) {
    // Always call stop record handlers,
    // to handle separate stop record request for timed records.
    if (success && !pending_record_path_.empty()) {
      capture_controller_listener_->OnStopRecordSucceeded(pending_record_path_);
    } else {
      capture_controller_listener_->OnStopRecordFailed(error);
    }

    if (recording_type_ == RecordingType::RECORDING_TYPE_TIMED) {
      if (success && !pending_record_path_.empty()) {
        capture_controller_listener_->OnVideoRecordSucceeded(
            pending_record_path_, (recording_duration_us_ / 1000));

      } else {
        capture_controller_listener_->OnVideoRecordFailed(error);
      }
    }
  }

  // update state
  recording_ = false;
  record_stop_pending_ = false;
  recording_type_ = RecordingType::RECORDING_TYPE_NOT_SET;
  pending_record_path_ = std::string();
}

// Returns pointer to databuffer.
// Called via IMFCaptureEngineOnSampleCallback implementation.
// Implements CaptureEngineObserver::GetSourceBuffer.
uint8_t *CaptureControllerImpl::GetSourceBuffer(uint32_t current_length) {
  if (this->source_buffer_data_ == nullptr ||
      this->source_buffer_size_ != current_length) {
    // Update source buffer size.
    this->source_buffer_data_ = nullptr;
    this->source_buffer_data_ = std::make_unique<uint8_t[]>(current_length);
    this->source_buffer_size_ = current_length;
  }
  return this->source_buffer_data_.get();
}

// Marks texture frame available after buffer is updated.
// Called via IMFCaptureEngineOnSampleCallback implementation.
// Implements CaptureEngineObserver::OnBufferUpdated.
void CaptureControllerImpl::OnBufferUpdated() {
  if (this->texture_registrar_ && this->texture_id_ >= 0) {
    this->texture_registrar_->MarkTextureFrameAvailable(this->texture_id_);
  }
}

// Handles capture time update from each processed frame.
// Stops timed recordings if requested recording duration has passed.
// Called via IMFCaptureEngineOnSampleCallback implementation.
// Implements CaptureEngineObserver::UpdateCaptureTime.
void CaptureControllerImpl::UpdateCaptureTime(uint64_t capture_time_us) {
  if (!initialized_) {
    return;
  }

  if (preview_pending_) {
    // Informs that first frame is captured succeffully and preview has started.
    OnPreviewStarted(true, "");
  }

  // Checks if max_video_duration_ms is passed.
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

}  // namespace camera_windows
