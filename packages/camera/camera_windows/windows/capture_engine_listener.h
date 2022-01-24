// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAPTURE_ENGINE_LISTENER_H_
#define PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAPTURE_ENGINE_LISTENER_H_

#include <mfcaptureengine.h>

#include <functional>

namespace camera_windows {

class CaptureEngineObserver {
 public:
  virtual ~CaptureEngineObserver() = default;

  virtual bool IsReadyForSample() = 0;

  // Event functions
  virtual void OnEvent(IMFMediaEvent* event) = 0;

  // Sample functions
  virtual uint8_t* GetSourceBuffer(uint32_t current_length) = 0;
  virtual void OnBufferUpdated() = 0;
  virtual void UpdateCaptureTime(uint64_t capture_time) = 0;
};

class CaptureEngineListener : public IMFCaptureEngineOnSampleCallback,
                              public IMFCaptureEngineOnEventCallback {
 public:
  CaptureEngineListener(CaptureEngineObserver* observer)
      : observer_(observer) {}

  ~CaptureEngineListener(){};

  // Disallow copy and move.
  CaptureEngineListener(const CaptureEngineListener&) = delete;
  CaptureEngineListener& operator=(const CaptureEngineListener&) = delete;

  // IUnknown
  STDMETHODIMP_(ULONG) AddRef();
  STDMETHODIMP_(ULONG) Release();
  STDMETHODIMP_(HRESULT) QueryInterface(const IID& riid, void** ppv);

  // IMFCaptureEngineOnEventCallback
  STDMETHODIMP OnEvent(IMFMediaEvent* pEvent);

  // IMFCaptureEngineOnSampleCallback
  STDMETHODIMP_(HRESULT) OnSample(IMFSample* pSample);

 private:
  CaptureEngineObserver* observer_;
  volatile ULONG ref_ = 0;
};

}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAPTURE_ENGINE_LISTENER_H_
