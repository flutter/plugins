// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_TEST_MOCKS_H_
#define PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_TEST_MOCKS_H_

#include <flutter/method_call.h>
#include <flutter/method_result_functions.h>
#include <flutter/standard_method_codec.h>
#include <flutter/texture_registrar.h>
#include <gmock/gmock.h>
#include <gtest/gtest.h>
#include <mfcaptureengine.h>

#include "camera.h"
#include "camera_plugin.h"
#include "capture_controller.h"
#include "capture_controller_listener.h"
#include "capture_engine_listener.h"

namespace camera_windows {
namespace test {

namespace {

using flutter::EncodableMap;
using flutter::EncodableValue;
using ::testing::_;
using ::testing::ByMove;
using ::testing::DoAll;
using ::testing::EndsWith;
using ::testing::Eq;
using ::testing::NiceMock;
using ::testing::Pointee;
using ::testing::Return;
using ::testing::SetArgPointee;

class MockMethodResult : public flutter::MethodResult<> {
 public:
  MOCK_METHOD(void, SuccessInternal, (const EncodableValue* result),
              (override));
  MOCK_METHOD(void, ErrorInternal,
              (const std::string& error_code, const std::string& error_message,
               const EncodableValue* details),
              (override));
  MOCK_METHOD(void, NotImplementedInternal, (), (override));
};

class MockBinaryMessenger : public flutter::BinaryMessenger {
 public:
  MOCK_METHOD(void, Send,
              (const std::string& channel, const uint8_t* message,
               size_t message_size, flutter::BinaryReply reply),
              (const));

  MOCK_METHOD(void, SetMessageHandler,
              (const std::string& channel,
               flutter::BinaryMessageHandler handler),
              ());
};

class MockTextureRegistrar : public flutter::TextureRegistrar {
 public:
  MockTextureRegistrar() {
    // TODO: create separate fake implementation
    ON_CALL(*this, RegisterTexture)
        .WillByDefault([this](flutter::TextureVariant* texture) -> int64_t {
          EXPECT_TRUE(texture);
          this->texture_id = 1000;
          return this->texture_id;
        });
    ON_CALL(*this, UnregisterTexture)
        .WillByDefault([this](int64_t tid) -> bool {
          if (tid == this->texture_id) {
            this->texture_id = -1;
            return true;
          }
          return false;
        });
    ON_CALL(*this, MarkTextureFrameAvailable)
        .WillByDefault([this](int64_t tid) -> bool {
          if (tid == this->texture_id) {
            return true;
          }
          return false;
        });
  }
  MOCK_METHOD(int64_t, RegisterTexture, (flutter::TextureVariant * texture),
              (override));

  MOCK_METHOD(bool, UnregisterTexture, (int64_t), (override));
  MOCK_METHOD(bool, MarkTextureFrameAvailable, (int64_t), (override));
  int64_t texture_id = -1;
};

class MockCameraFactory : public CameraFactory {
 public:
  MockCameraFactory() {
    ON_CALL(*this, CreateCamera).WillByDefault([this]() {
      assert(this->pending_camera_);
      return std::move(this->pending_camera_);
    });
  }

  MOCK_METHOD(std::unique_ptr<Camera>, CreateCamera,
              (const std::string& device_id), (override));

  std::unique_ptr<Camera> pending_camera_;
};

class MockCamera : public Camera {
 public:
  MockCamera(const std::string& device_id)
      : device_id_(device_id), Camera(device_id){};
  ~MockCamera() = default;

  MockCamera(const MockCamera&) = delete;
  MockCamera& operator=(const MockCamera&) = delete;

  MOCK_METHOD(void, OnCreateCaptureEngineSucceeded, (int64_t texture_id),
              (override));
  MOCK_METHOD(std::unique_ptr<flutter::MethodResult<>>, GetPendingResultByType,
              (PendingResultType type));
  MOCK_METHOD(void, OnCreateCaptureEngineFailed, (const std::string& error),
              (override));

  MOCK_METHOD(void, OnStartPreviewSucceeded, (int32_t width, int32_t height),
              (override));
  MOCK_METHOD(void, OnStartPreviewFailed, (const std::string& error),
              (override));

  MOCK_METHOD(void, OnResumePreviewSucceeded, (), (override));
  MOCK_METHOD(void, OnResumePreviewFailed, (const std::string& error),
              (override));

  MOCK_METHOD(void, OnPausePreviewSucceeded, (), (override));
  MOCK_METHOD(void, OnPausePreviewFailed, (const std::string& error),
              (override));

  MOCK_METHOD(void, OnStartRecordSucceeded, (), (override));
  MOCK_METHOD(void, OnStartRecordFailed, (const std::string& error),
              (override));

  MOCK_METHOD(void, OnStopRecordSucceeded, (const std::string& filepath),
              (override));
  MOCK_METHOD(void, OnStopRecordFailed, (const std::string& error), (override));

  MOCK_METHOD(void, OnPictureSuccess, (const std::string& filepath),
              (override));
  MOCK_METHOD(void, OnPictureFailed, (const std::string& error), (override));

  MOCK_METHOD(void, OnVideoRecordedSuccess,
              (const std::string& filepath, int64_t video_duration),
              (override));
  MOCK_METHOD(void, OnVideoRecordedFailed, (const std::string& error),
              (override));
  MOCK_METHOD(void, OnCaptureError, (const std::string& error), (override));

  MOCK_METHOD(bool, HasDeviceId, (std::string & device_id), (override));
  MOCK_METHOD(bool, HasCameraId, (int64_t camera_id), (override));

  MOCK_METHOD(bool, AddPendingResult,
              (PendingResultType type, std::unique_ptr<MethodResult<>> result),
              (override));
  MOCK_METHOD(bool, HasPendingResultByType, (PendingResultType type),
              (override));

  MOCK_METHOD(camera_windows::CaptureController*, GetCaptureController, (),
              (override));

  MOCK_METHOD(void, InitCamera,
              (flutter::TextureRegistrar * texture_registrar,
               flutter::BinaryMessenger* messenger, bool enable_audio,
               ResolutionPreset resolution_preset),
              (override));

  std::unique_ptr<CaptureController> capture_controller_;
  std::unique_ptr<MethodResult<>> pending_result_;
  std::string device_id_;
  int64_t camera_id_ = -1;
};

class MockCaptureControllerFactory : public CaptureControllerFactory {
 public:
  MockCaptureControllerFactory(){};
  virtual ~MockCaptureControllerFactory() = default;

  // Disallow copy and move.
  MockCaptureControllerFactory(const MockCaptureControllerFactory&) = delete;
  MockCaptureControllerFactory& operator=(const MockCaptureControllerFactory&) =
      delete;

  MOCK_METHOD(std::unique_ptr<CaptureController>, CreateCaptureController,
              (CaptureControllerListener * listener), (override));
};

class MockCaptureController : public CaptureController {
 public:
  MOCK_METHOD(void, InitCaptureDevice,
              (flutter::TextureRegistrar * texture_registrar,
               const std::string& device_id, bool enable_audio,
               ResolutionPreset resolution_preset),
              (override));

  MOCK_METHOD(int64_t, GetTextureId, (), (override));
  MOCK_METHOD(uint32_t, GetPreviewWidth, (), (override));
  MOCK_METHOD(uint32_t, GetPreviewHeight, (), (override));

  // Actions
  MOCK_METHOD(void, StartPreview, (), (override));
  MOCK_METHOD(void, StopPreview, (), (override));
  MOCK_METHOD(void, ResumePreview, (), (override));
  MOCK_METHOD(void, PausePreview, (), (override));
  MOCK_METHOD(void, StartRecord,
              (const std::string& filepath, int64_t max_video_duration_ms),
              (override));
  MOCK_METHOD(void, StopRecord, (), (override));
  MOCK_METHOD(void, TakePicture, (const std::string filepath), (override));
};

// MockCameraPlugin extends CameraPlugin behaviour a bit to allow adding cameras
// without creating them first with create message handler and mocking static
// system calls
class MockCameraPlugin : public CameraPlugin {
 public:
  MockCameraPlugin(flutter::TextureRegistrar* texture_registrar,
                   flutter::BinaryMessenger* messenger)
      : CameraPlugin(texture_registrar, messenger){};

  // Creates a plugin instance with the given CameraFactory instance.
  // Exists for unit testing with mock implementations.
  MockCameraPlugin(flutter::TextureRegistrar* texture_registrar,
                   flutter::BinaryMessenger* messenger,
                   std::unique_ptr<CameraFactory> camera_factory)
      : CameraPlugin(texture_registrar, messenger, std::move(camera_factory)){};

  MockCameraPlugin(const MockCameraPlugin&) = delete;
  MockCameraPlugin& operator=(const MockCameraPlugin&) = delete;

  MOCK_METHOD(bool, EnumerateVideoCaptureDeviceSources,
              (IMFActivate * **devices, UINT32* count), (override));

  // Helper to add camera without creating it via CameraFactory for testing
  // purposes
  void AddCamera(std::unique_ptr<Camera> camera) {
    cameras_.push_back(std::move(camera));
  }
};

class MockCaptureEngineListener : public IMFCaptureEngineOnSampleCallback,
                                  public IMFCaptureEngineOnEventCallback {
  MockCaptureEngineListener(CaptureEngineObserver* observer)
      : ref_(1), observer_(observer) {}

  // IUnknown
  STDMETHODIMP_(ULONG) AddRef() { return InterlockedIncrement(&ref_); }

  // IUnknown
  STDMETHODIMP_(ULONG) Release() {
    LONG ref = InterlockedDecrement(&ref_);
    if (ref == 0) {
      delete this;
    }
    return ref;
  }

  // IUnknown
  STDMETHODIMP_(HRESULT) QueryInterface(const IID& riid, void** ppv) {
    *ppv = nullptr;

    if (riid == IID_IMFCaptureEngineOnEventCallback) {
      *ppv = static_cast<IMFCaptureEngineOnEventCallback*>(this);
      ((IUnknown*)*ppv)->AddRef();
      return S_OK;
    } else if (riid == IID_IMFCaptureEngineOnSampleCallback) {
      *ppv = static_cast<IMFCaptureEngineOnSampleCallback*>(this);
      ((IUnknown*)*ppv)->AddRef();
      return S_OK;
    }

    return E_NOINTERFACE;
  }

  MOCK_METHOD(HRESULT, OnEvent, (IMFMediaEvent * pEvent));
  MOCK_METHOD(HRESULT, OnSample, (IMFSample * pSample));

  CaptureEngineObserver* observer_;
  volatile ULONG ref_;
};
class MockCaptureControllerListener {};

// Uses IMFMediaSourceEx which has SetD3DManager method.
class FakeMediaSource : public IMFMediaSourceEx {
 public:
  FakeMediaSource() : ref_(0){};

  // IUnknown
  STDMETHODIMP_(ULONG) AddRef() { return InterlockedIncrement(&ref_); }

  // IUnknown
  STDMETHODIMP_(ULONG) Release() {
    LONG ref = InterlockedDecrement(&ref_);
    if (ref == 0) {
      delete this;
    }
    return ref;
  }

  // IUnknown
  STDMETHODIMP_(HRESULT) QueryInterface(const IID& riid, void** ppv) {
    *ppv = nullptr;

    if (riid == IID_IMFMediaSource) {
      *ppv = static_cast<IMFMediaSource*>(this);
      ((IUnknown*)*ppv)->AddRef();
      return S_OK;
    }

    return E_NOINTERFACE;
  }

  // IMFMediaSource
  HRESULT GetCharacteristics(DWORD* dwCharacteristics) override {
    return E_NOTIMPL;
  }
  // IMFMediaSource
  HRESULT CreatePresentationDescriptor(
      IMFPresentationDescriptor** presentationDescriptor) override {
    return E_NOTIMPL;
  }
  // IMFMediaSource
  HRESULT Start(IMFPresentationDescriptor* presentationDescriptor,
                const GUID* guidTimeFormat,
                const PROPVARIANT* varStartPosition) override {
    return E_NOTIMPL;
  }
  // IMFMediaSource
  HRESULT Stop(void) override { return E_NOTIMPL; }
  // IMFMediaSource
  HRESULT Pause(void) override { return E_NOTIMPL; }
  // IMFMediaSource
  HRESULT Shutdown(void) override { return E_NOTIMPL; }

  // IMFMediaEventGenerator
  HRESULT GetEvent(DWORD dwFlags, IMFMediaEvent** event) override {
    return E_NOTIMPL;
  }
  // IMFMediaEventGenerator
  HRESULT BeginGetEvent(IMFAsyncCallback* callback,
                        IUnknown* unkState) override {
    return E_NOTIMPL;
  }
  // IMFMediaEventGenerator
  HRESULT EndGetEvent(IMFAsyncResult* result, IMFMediaEvent** event) override {
    return E_NOTIMPL;
  }
  // IMFMediaEventGenerator
  HRESULT QueueEvent(MediaEventType met, REFGUID guidExtendedType,
                     HRESULT hrStatus, const PROPVARIANT* value) override {
    return E_NOTIMPL;
  }

  // IMFMediaSourceEx
  HRESULT GetSourceAttributes(IMFAttributes** attributes) { return E_NOTIMPL; }
  // IMFMediaSourceEx
  HRESULT GetStreamAttributes(DWORD stream_id, IMFAttributes** attributes) {
    return E_NOTIMPL;
  }
  // IMFMediaSourceEx
  HRESULT SetD3DManager(IUnknown* manager) { return S_OK; }

 private:
  ~FakeMediaSource() = default;
  volatile ULONG ref_;
};

class MockCaptureEngine : public IMFCaptureEngine {
 public:
  MockCaptureEngine() : ref_(0) {
    ON_CALL(*this, Initialize)
        .WillByDefault([this](IMFCaptureEngineOnEventCallback* callback,
                              IMFAttributes* attributes, IUnknown* audio_Source,
                              IUnknown* video_source) -> HRESULT {
          EXPECT_TRUE(callback);
          EXPECT_TRUE(attributes);
          EXPECT_TRUE(video_source);
          // audio_source is allowed to be nullptr;
          callback_ = callback;
          initialized_ = true;
          return S_OK;
        });
  };

  virtual ~MockCaptureEngine() = default;

  MOCK_METHOD(HRESULT, Initialize,
              (IMFCaptureEngineOnEventCallback * callback,
               IMFAttributes* attributes, IUnknown* audio_Source,
               IUnknown* video_source));
  MOCK_METHOD(HRESULT, StartPreview, ());
  MOCK_METHOD(HRESULT, StopPreview, ());
  MOCK_METHOD(HRESULT, StartRecord, ());
  MOCK_METHOD(HRESULT, StopRecord,
              (BOOL finalize, BOOL flushUnprocessedSamples));
  MOCK_METHOD(HRESULT, TakePhoto, ());
  MOCK_METHOD(HRESULT, GetSink,
              (MF_CAPTURE_ENGINE_SINK_TYPE type, IMFCaptureSink** sink));
  MOCK_METHOD(HRESULT, GetSource, (IMFCaptureSource * *ppSource));

  // IUnknown
  STDMETHODIMP_(ULONG) AddRef() { return InterlockedIncrement(&ref_); }

  // IUnknown
  STDMETHODIMP_(ULONG) Release() {
    LONG ref = InterlockedDecrement(&ref_);
    if (ref == 0) {
      delete this;
    }
    return ref;
  }

  // IUnknown
  STDMETHODIMP_(HRESULT) QueryInterface(const IID& riid, void** ppv) {
    *ppv = nullptr;

    if (riid == IID_IMFCaptureEngine) {
      *ppv = static_cast<IMFCaptureEngine*>(this);
      ((IUnknown*)*ppv)->AddRef();
      return S_OK;
    }

    return E_NOINTERFACE;
  }

  void CreateFakeEvent(HRESULT hrStatus, GUID event_type) {
    EXPECT_TRUE(initialized_);
    ComPtr<IMFMediaEvent> event;
    MFCreateMediaEvent(MEExtendedType, event_type, hrStatus, nullptr, &event);
    if (callback_) {
      callback_->OnEvent(event.Get());
    }
  }

  ComPtr<IMFCaptureEngineOnEventCallback> callback_;
  volatile ULONG ref_;
  bool initialized_ = false;
};

#define MOCK_DEVICE_ID "mock_device_id"
#define MOCK_CAMERA_NAME "mock_camera_name <" MOCK_DEVICE_ID ">"
#define MOCK_INVALID_CAMERA_NAME "invalid_camera_name"
}  // namespace
}  // namespace test
}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_TEST_MOCKS_H_
