// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "photo_handler.h"

#include <mfapi.h>
#include <mfcaptureengine.h>
#include <wincodec.h>

#include <cassert>

#include "capture_engine_listener.h"
#include "string_utils.h"

namespace camera_windows {

using Microsoft::WRL::ComPtr;

// Initializes media type for photo capture for jpeg images.
HRESULT BuildMediaTypeForPhotoCapture(IMFMediaType* src_media_type,
                                      IMFMediaType** photo_media_type,
                                      GUID image_format) {
  assert(src_media_type);
  ComPtr<IMFMediaType> new_media_type;

  HRESULT hr = MFCreateMediaType(&new_media_type);
  if (FAILED(hr)) {
    return hr;
  }

  // Clones everything from original media type.
  hr = src_media_type->CopyAllItems(new_media_type.Get());
  if (FAILED(hr)) {
    return hr;
  }

  hr = new_media_type->SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Image);
  if (FAILED(hr)) {
    return hr;
  }

  hr = new_media_type->SetGUID(MF_MT_SUBTYPE, image_format);
  if (FAILED(hr)) {
    return hr;
  }

  new_media_type.CopyTo(photo_media_type);
  return hr;
}

HRESULT PhotoHandler::InitPhotoSink(IMFCaptureEngine* capture_engine,
                                    IMFMediaType* base_media_type) {
  assert(capture_engine);
  assert(base_media_type);

  HRESULT hr = S_OK;

  if (photo_sink_) {
    // If photo sink already exists, only update output filename.
    hr = photo_sink_->SetOutputFileName(Utf16FromUtf8(file_path_).c_str());

    if (FAILED(hr)) {
      photo_sink_ = nullptr;
    }

    return hr;
  }

  ComPtr<IMFMediaType> photo_media_type;
  ComPtr<IMFCaptureSink> capture_sink;

  // Get sink with photo type.
  hr =
      capture_engine->GetSink(MF_CAPTURE_ENGINE_SINK_TYPE_PHOTO, &capture_sink);
  if (FAILED(hr)) {
    return hr;
  }

  hr = capture_sink.As(&photo_sink_);
  if (FAILED(hr)) {
    photo_sink_ = nullptr;
    return hr;
  }

  hr = photo_sink_->RemoveAllStreams();
  if (FAILED(hr)) {
    photo_sink_ = nullptr;
    return hr;
  }

  hr = BuildMediaTypeForPhotoCapture(base_media_type,
                                     photo_media_type.GetAddressOf(),
                                     GUID_ContainerFormatJpeg);

  if (FAILED(hr)) {
    photo_sink_ = nullptr;
    return hr;
  }

  DWORD photo_sink_stream_index;
  hr = photo_sink_->AddStream(
      (DWORD)MF_CAPTURE_ENGINE_PREFERRED_SOURCE_STREAM_FOR_PHOTO,
      photo_media_type.Get(), nullptr, &photo_sink_stream_index);
  if (FAILED(hr)) {
    photo_sink_ = nullptr;
    return hr;
  }

  hr = photo_sink_->SetOutputFileName(Utf16FromUtf8(file_path_).c_str());
  if (FAILED(hr)) {
    photo_sink_ = nullptr;
    return hr;
  }

  return hr;
}

HRESULT PhotoHandler::TakePhoto(const std::string& file_path,
                                IMFCaptureEngine* capture_engine,
                                IMFMediaType* base_media_type) {
  assert(!file_path.empty());
  assert(capture_engine);
  assert(base_media_type);

  file_path_ = file_path;

  HRESULT hr = InitPhotoSink(capture_engine, base_media_type);
  if (FAILED(hr)) {
    return hr;
  }

  photo_state_ = PhotoState::kTakingPhoto;

  return capture_engine->TakePhoto();
}

void PhotoHandler::OnPhotoTaken() {
  assert(photo_state_ == PhotoState::kTakingPhoto);
  photo_state_ = PhotoState::kIdle;
}

}  // namespace camera_windows
