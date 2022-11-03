// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "record_handler.h"

#include <mfapi.h>
#include <mfcaptureengine.h>

#include <cassert>

#include "string_utils.h"

namespace camera_windows {

using Microsoft::WRL::ComPtr;

// Initializes media type for video capture.
HRESULT BuildMediaTypeForVideoCapture(IMFMediaType* src_media_type,
                                      IMFMediaType** video_record_media_type,
                                      GUID capture_format) {
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

  hr = new_media_type->SetGUID(MF_MT_SUBTYPE, capture_format);
  if (FAILED(hr)) {
    return hr;
  }

  new_media_type.CopyTo(video_record_media_type);
  return S_OK;
}

// Queries interface object from collection.
template <class Q>
HRESULT GetCollectionObject(IMFCollection* pCollection, DWORD index,
                            Q** ppObj) {
  ComPtr<IUnknown> pUnk;
  HRESULT hr = pCollection->GetElement(index, pUnk.GetAddressOf());
  if (FAILED(hr)) {
    return hr;
  }
  return pUnk->QueryInterface(IID_PPV_ARGS(ppObj));
}

// Initializes media type for audo capture.
HRESULT BuildMediaTypeForAudioCapture(IMFMediaType** audio_record_media_type) {
  ComPtr<IMFAttributes> audio_output_attributes;
  ComPtr<IMFMediaType> src_media_type;
  ComPtr<IMFMediaType> new_media_type;
  ComPtr<IMFCollection> available_output_types;
  DWORD mt_count = 0;

  HRESULT hr = MFCreateAttributes(&audio_output_attributes, 1);
  if (FAILED(hr)) {
    return hr;
  }

  // Enumerates only low latency audio outputs.
  hr = audio_output_attributes->SetUINT32(MF_LOW_LATENCY, TRUE);
  if (FAILED(hr)) {
    return hr;
  }

  DWORD mft_flags = (MFT_ENUM_FLAG_ALL & (~MFT_ENUM_FLAG_FIELDOFUSE)) |
                    MFT_ENUM_FLAG_SORTANDFILTER;

  hr = MFTranscodeGetAudioOutputAvailableTypes(
      MFAudioFormat_AAC, mft_flags, audio_output_attributes.Get(),
      available_output_types.GetAddressOf());
  if (FAILED(hr)) {
    return hr;
  }

  hr = GetCollectionObject(available_output_types.Get(), 0,
                           src_media_type.GetAddressOf());
  if (FAILED(hr)) {
    return hr;
  }

  hr = available_output_types->GetElementCount(&mt_count);
  if (FAILED(hr)) {
    return hr;
  }

  if (mt_count == 0) {
    // No sources found, mark process as failure.
    return E_FAIL;
  }

  // Create new media type to copy original media type to.
  hr = MFCreateMediaType(&new_media_type);
  if (FAILED(hr)) {
    return hr;
  }

  hr = src_media_type->CopyAllItems(new_media_type.Get());
  if (FAILED(hr)) {
    return hr;
  }

  new_media_type.CopyTo(audio_record_media_type);
  return hr;
}

HRESULT RecordHandler::InitRecordSink(IMFCaptureEngine* capture_engine,
                                      IMFMediaType* base_media_type) {
  assert(!file_path_.empty());
  assert(capture_engine);
  assert(base_media_type);

  HRESULT hr = S_OK;
  if (record_sink_) {
    // If record sink already exists, only update output filename.
    hr = record_sink_->SetOutputFileName(Utf16FromUtf8(file_path_).c_str());

    if (FAILED(hr)) {
      record_sink_ = nullptr;
    }
    return hr;
  }

  ComPtr<IMFMediaType> video_record_media_type;
  ComPtr<IMFCaptureSink> capture_sink;

  // Gets sink from capture engine with record type.

  hr = capture_engine->GetSink(MF_CAPTURE_ENGINE_SINK_TYPE_RECORD,
                               &capture_sink);
  if (FAILED(hr)) {
    return hr;
  }

  hr = capture_sink.As(&record_sink_);
  if (FAILED(hr)) {
    return hr;
  }

  // Removes existing streams if available.
  hr = record_sink_->RemoveAllStreams();
  if (FAILED(hr)) {
    return hr;
  }

  hr = BuildMediaTypeForVideoCapture(base_media_type,
                                     video_record_media_type.GetAddressOf(),
                                     MFVideoFormat_H264);
  if (FAILED(hr)) {
    return hr;
  }

  DWORD video_record_sink_stream_index;
  hr = record_sink_->AddStream(
      (DWORD)MF_CAPTURE_ENGINE_PREFERRED_SOURCE_STREAM_FOR_VIDEO_RECORD,
      video_record_media_type.Get(), nullptr, &video_record_sink_stream_index);
  if (FAILED(hr)) {
    return hr;
  }

  if (record_audio_) {
    ComPtr<IMFMediaType> audio_record_media_type;
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

    if (FAILED(hr)) {
      return hr;
    }
  }

  hr = record_sink_->SetOutputFileName(Utf16FromUtf8(file_path_).c_str());

  return hr;
}

HRESULT RecordHandler::StartRecord(const std::string& file_path,
                                   int64_t max_duration,
                                   IMFCaptureEngine* capture_engine,
                                   IMFMediaType* base_media_type) {
  assert(!file_path.empty());
  assert(capture_engine);
  assert(base_media_type);

  type_ = max_duration < 0 ? RecordingType::kContinuous : RecordingType::kTimed;
  max_video_duration_ms_ = max_duration;
  file_path_ = file_path;
  recording_start_timestamp_us_ = -1;
  recording_duration_us_ = 0;

  HRESULT hr = InitRecordSink(capture_engine, base_media_type);
  if (FAILED(hr)) {
    return hr;
  }

  recording_state_ = RecordState::kStarting;
  return capture_engine->StartRecord();
}

HRESULT RecordHandler::StopRecord(IMFCaptureEngine* capture_engine) {
  if (recording_state_ == RecordState::kRunning) {
    recording_state_ = RecordState::kStopping;
    return capture_engine->StopRecord(true, false);
  }
  return E_FAIL;
}

void RecordHandler::OnRecordStarted() {
  if (recording_state_ == RecordState::kStarting) {
    recording_state_ = RecordState::kRunning;
  }
}

void RecordHandler::OnRecordStopped() {
  if (recording_state_ == RecordState::kStopping) {
    file_path_ = "";
    recording_start_timestamp_us_ = -1;
    recording_duration_us_ = 0;
    max_video_duration_ms_ = -1;
    recording_state_ = RecordState::kNotStarted;
    type_ = RecordingType::kNone;
  }
}

void RecordHandler::UpdateRecordingTime(uint64_t timestamp) {
  if (recording_start_timestamp_us_ < 0) {
    recording_start_timestamp_us_ = timestamp;
  }

  recording_duration_us_ = (timestamp - recording_start_timestamp_us_);
}

bool RecordHandler::ShouldStopTimedRecording() const {
  return type_ == RecordingType::kTimed &&
         recording_state_ == RecordState::kRunning &&
         max_video_duration_ms_ > 0 &&
         recording_duration_us_ >=
             (static_cast<uint64_t>(max_video_duration_ms_) * 1000);
}

}  // namespace camera_windows
