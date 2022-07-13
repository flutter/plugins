// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAPTURE_ENGINE_LISTENER_H_
#define PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_CAPTURE_ENGINE_LISTENER_H_

#include <mfcaptureengine.h>

#include <cassert>
#include <functional>

namespace camera_windows {

// A class that implements callbacks for events from a |CaptureEngineListener|.
class CaptureEngineObserver {
 public:
  virtual ~CaptureEngineObserver() = default;

  // Returns true if sample can be processed.
  virtual bool IsReadyForSample() const = 0;

  // Handles Capture Engine media events.
  virtual void OnEvent(IMFMediaEvent* event) = 0;

  // Updates texture buffer
  virtual bool UpdateBuffer(uint8_t* data, uint32_t new_length) = 0;

  // Handles capture timestamps updates.
  // Used to stop timed recordings when recorded time is exceeded.
  virtual void UpdateCaptureTime(uint64_t capture_time) = 0;
};

// Listener for Windows Media Foundation capture engine events and samples.
//
// Events are redirected to observers for processing. Samples are preprosessed
// and sent to the associated observer if it is ready to process samples.
class CaptureEngineListener : public IMFCaptureEngineOnSampleCallback,
                              public IMFCaptureEngineOnEventCallback {
 public:
  CaptureEngineListener(CaptureEngineObserver* observer) : observer_(observer) {
    assert(observer);
  }

  ~CaptureEngineListener() {}

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
