// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "preview_handler.h"

#include <mfapi.h>
#include <mfcaptureengine.h>

#include <cassert>

#include "capture_engine_listener.h"
#include "string_utils.h"

namespace camera_windows {

using Microsoft::WRL::ComPtr;

// Initializes media type for video preview.
HRESULT BuildMediaTypeForVideoPreview(IMFMediaType* src_media_type,
                                      IMFMediaType** preview_media_type) {
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

  // Changes subtype to MFVideoFormat_RGB32.
  hr = new_media_type->SetGUID(MF_MT_SUBTYPE, MFVideoFormat_RGB32);
  if (FAILED(hr)) {
    return hr;
  }

  hr = new_media_type->SetUINT32(MF_MT_ALL_SAMPLES_INDEPENDENT, TRUE);
  if (FAILED(hr)) {
    return hr;
  }

  new_media_type.CopyTo(preview_media_type);

  return hr;
}

HRESULT PreviewHandler::InitPreviewSink(
    IMFCaptureEngine* capture_engine, IMFMediaType* base_media_type,
    CaptureEngineListener* sample_callback) {
  assert(capture_engine);
  assert(base_media_type);
  assert(sample_callback);

  HRESULT hr = S_OK;

  if (preview_sink_) {
    // Preview sink already initialized.
    return hr;
  }

  ComPtr<IMFMediaType> preview_media_type;
  ComPtr<IMFCaptureSink> capture_sink;

  // Get sink with preview type.
  hr = capture_engine->GetSink(MF_CAPTURE_ENGINE_SINK_TYPE_PREVIEW,
                               &capture_sink);
  if (FAILED(hr)) {
    return hr;
  }

  hr = capture_sink.As(&preview_sink_);
  if (FAILED(hr)) {
    preview_sink_ = nullptr;
    return hr;
  }

  hr = preview_sink_->RemoveAllStreams();
  if (FAILED(hr)) {
    preview_sink_ = nullptr;
    return hr;
  }

  hr = BuildMediaTypeForVideoPreview(base_media_type,
                                     preview_media_type.GetAddressOf());

  if (FAILED(hr)) {
    preview_sink_ = nullptr;
    return hr;
  }

  DWORD preview_sink_stream_index;
  hr = preview_sink_->AddStream(
      (DWORD)MF_CAPTURE_ENGINE_PREFERRED_SOURCE_STREAM_FOR_VIDEO_PREVIEW,
      preview_media_type.Get(), nullptr, &preview_sink_stream_index);

  if (FAILED(hr)) {
    return hr;
  }

  hr = preview_sink_->SetSampleCallback(preview_sink_stream_index,
                                        sample_callback);

  if (FAILED(hr)) {
    preview_sink_ = nullptr;
    return hr;
  }

  return hr;
}

HRESULT PreviewHandler::StartPreview(IMFCaptureEngine* capture_engine,
                                     IMFMediaType* base_media_type,
                                     CaptureEngineListener* sample_callback) {
  assert(capture_engine);
  assert(base_media_type);

  HRESULT hr =
      InitPreviewSink(capture_engine, base_media_type, sample_callback);

  if (FAILED(hr)) {
    return hr;
  }

  preview_state_ = PreviewState::kStarting;
  return capture_engine->StartPreview();
}

HRESULT PreviewHandler::StopPreview(IMFCaptureEngine* capture_engine) {
  if (preview_state_ == PreviewState::kStarting ||
      preview_state_ == PreviewState::kRunning ||
      preview_state_ == PreviewState::kPaused) {
    preview_state_ = PreviewState::kStopping;
    return capture_engine->StopPreview();
  }
  return E_FAIL;
}

bool PreviewHandler::PausePreview() {
  if (preview_state_ != PreviewState::kRunning) {
    return false;
  }
  preview_state_ = PreviewState::kPaused;
  return true;
}

bool PreviewHandler::ResumePreview() {
  if (preview_state_ != PreviewState::kPaused) {
    return false;
  }
  preview_state_ = PreviewState::kRunning;
  return true;
}

void PreviewHandler::OnPreviewStarted() {
  assert(preview_state_ == PreviewState::kStarting);
  if (preview_state_ == PreviewState::kStarting) {
    preview_state_ = PreviewState::kRunning;
  }
}

}  // namespace camera_windows
