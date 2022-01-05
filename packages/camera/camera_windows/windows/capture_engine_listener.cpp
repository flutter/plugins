
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "capture_engine_listener.h"

#include <system_error>

namespace camera_windows {

// Method from IUnknown
STDMETHODIMP_(ULONG) CaptureEngineListener::AddRef() {
  return InterlockedIncrement(&ref_);
}

// Method from IUnknown
STDMETHODIMP_(ULONG)
CaptureEngineListener::Release() {
  LONG ref = InterlockedDecrement(&ref_);
  if (ref == 0) {
    delete this;
  }
  return ref;
}

// Method from IUnknown
STDMETHODIMP_(HRESULT)
CaptureEngineListener::QueryInterface(const IID &riid, void **ppv) {
  HRESULT hr = E_NOINTERFACE;
  *ppv = nullptr;

  if (riid == IID_IMFCaptureEngineOnEventCallback) {
    *ppv = static_cast<IMFCaptureEngineOnEventCallback *>(this);
    ((IUnknown *)*ppv)->AddRef();
    hr = S_OK;
  } else if (riid == IID_IMFCaptureEngineOnSampleCallback) {
    *ppv = static_cast<IMFCaptureEngineOnSampleCallback *>(this);
    ((IUnknown *)*ppv)->AddRef();
    hr = S_OK;
  }

  return hr;
}

STDMETHODIMP CaptureEngineListener::OnEvent(IMFMediaEvent *event) {
  HRESULT event_hr;
  HRESULT hr = event->GetStatus(&event_hr);

  if (!observer_->IsReadyForEvents()) {
    // TODO: call observer_->OnCaptureEngineError()
    // with proper error message
    return event_hr;
  }

  if (SUCCEEDED(hr)) {
    GUID extended_type_guid;
    hr = event->GetExtendedType(&extended_type_guid);
    if (SUCCEEDED(hr)) {
      if (extended_type_guid == MF_CAPTURE_ENGINE_ERROR) {
        observer_->OnCaptureEngineError();
      } else if (extended_type_guid == MF_CAPTURE_ENGINE_INITIALIZED) {
        observer_->OnCaptureEngineInitialized(SUCCEEDED(event_hr));
      } else if (extended_type_guid == MF_CAPTURE_ENGINE_PREVIEW_STARTED) {
        observer_->OnPreviewStarted(SUCCEEDED(event_hr));
      } else if (extended_type_guid == MF_CAPTURE_ENGINE_PREVIEW_STOPPED) {
        observer_->OnPreviewStopped(SUCCEEDED(event_hr));
      } else if (extended_type_guid == MF_CAPTURE_ENGINE_RECORD_STARTED) {
        observer_->OnRecordStarted(SUCCEEDED(event_hr));
      } else if (extended_type_guid == MF_CAPTURE_ENGINE_RECORD_STOPPED) {
        observer_->OnRecordStopped(SUCCEEDED(event_hr));
      } else if (extended_type_guid == MF_CAPTURE_ENGINE_PHOTO_TAKEN) {
        observer_->OnPicture(SUCCEEDED(event_hr));
      }
    }
  }

  // TODO: pass this error directly to the handlers?
  if (FAILED(event_hr)) {
    std::string message = std::system_category().message(event_hr);

    printf("Got capture event error: %s\n", message.c_str());
    fflush(stdout);
  }

  return event_hr;
}

// Method from IMFCaptureEngineOnSampleCallback
HRESULT CaptureEngineListener::OnSample(IMFSample *sample) {
  HRESULT hr = S_OK;

  if (this->observer_ == nullptr || !this->observer_->IsReadyForSample()) {
    // No texture target available or not previewing, just return status
    return hr;
  }

  if (SUCCEEDED(hr) && sample) {
    IMFMediaBuffer *buffer = nullptr;
    hr = sample->ConvertToContiguousBuffer(&buffer);

    // Draw the frame.
    if (SUCCEEDED(hr)) {
      DWORD max_length = 0;
      DWORD current_length = 0;
      uint8_t *data;
      if (SUCCEEDED(buffer->Lock(&data, &max_length, &current_length))) {
        uint8_t *src_buffer = this->observer_->GetSourceBuffer(current_length);
        if (src_buffer) {
          CopyMemory(src_buffer, data, current_length);
        }
      }
      hr = buffer->Unlock();
      if (SUCCEEDED(hr)) {
        this->observer_->OnBufferUpdate();
      }
    }

    LONGLONG raw_time_stamp = 0;
    // Receives the presentation time, in 100-nanosecond units
    sample->GetSampleTime(&raw_time_stamp);

    // Report time in microseconds
    this->observer_->UpdateCaptureTime(
        static_cast<uint64_t>(raw_time_stamp / 10));

    if (buffer) {
      buffer->Release();
      buffer = nullptr;
    }
  }
  return hr;
}
}  // namespace camera_windows