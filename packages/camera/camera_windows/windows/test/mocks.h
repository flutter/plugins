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

class MockMethodResult : public flutter::MethodResult<> {
 public:
  ~MockMethodResult() = default;

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
  ~MockBinaryMessenger() = default;

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
    ON_CALL(*this, RegisterTexture)
        .WillByDefault([this](flutter::TextureVariant* texture) -> int64_t {
          EXPECT_TRUE(texture);
          this->texture_ = texture;
          this->texture_id_ = 1000;
          return this->texture_id_;
        });

    // Deprecated pre-Flutter-3.4 version.
    ON_CALL(*this, UnregisterTexture(_))
        .WillByDefault([this](int64_t tid) -> bool {
          if (tid == this->texture_id_) {
            texture_ = nullptr;
            this->texture_id_ = -1;
            return true;
          }
          return false;
        });

    // Flutter 3.4+ version.
    ON_CALL(*this, UnregisterTexture(_, _))
        .WillByDefault(
            [this](int64_t tid, std::function<void()> callback) -> void {
              // Forward to the pre-3.4 implementation so that expectations can
              // be the same for all versions.
              this->UnregisterTexture(tid);
              if (callback) {
                callback();
              }
            });

    ON_CALL(*this, MarkTextureFrameAvailable)
        .WillByDefault([this](int64_t tid) -> bool {
          if (tid == this->texture_id_) {
            return true;
          }
          return false;
        });
  }

  ~MockTextureRegistrar() { texture_ = nullptr; }

  MOCK_METHOD(int64_t, RegisterTexture, (flutter::TextureVariant * texture),
              (override));

  // Pre-Flutter-3.4 version.
  MOCK_METHOD(bool, UnregisterTexture, (int64_t), (override));
  // Flutter 3.4+ version.
  // TODO(cbracken): Add an override annotation to this once 3.4+ is the
  // minimum version tested in CI.
  MOCK_METHOD(void, UnregisterTexture,
              (int64_t, std::function<void()> callback), ());
  MOCK_METHOD(bool, MarkTextureFrameAvailable, (int64_t), (override));

  int64_t texture_id_ = -1;
  flutter::TextureVariant* texture_ = nullptr;
};

class MockCameraFactory : public CameraFactory {
 public:
  MockCameraFactory() {
    ON_CALL(*this, CreateCamera).WillByDefault([this]() {
      assert(this->pending_camera_);
      return std::move(this->pending_camera_);
    });
  }

  ~MockCameraFactory() = default;

  // Disallow copy and move.
  MockCameraFactory(const MockCameraFactory&) = delete;
  MockCameraFactory& operator=(const MockCameraFactory&) = delete;

  MOCK_METHOD(std::unique_ptr<Camera>, CreateCamera,
              (const std::string& device_id), (override));

  std::unique_ptr<Camera> pending_camera_;
};

class MockCamera : public Camera {
 public:
  MockCamera(const std::string& device_id)
      : device_id_(device_id), Camera(device_id){};

  ~MockCamera() = default;

  // Disallow copy and move.
  MockCamera(const MockCamera&) = delete;
  MockCamera& operator=(const MockCamera&) = delete;

  MOCK_METHOD(void, OnCreateCaptureEngineSucceeded, (int64_t texture_id),
              (override));
  MOCK_METHOD(std::unique_ptr<flutter::MethodResult<>>, GetPendingResultByType,
              (PendingResultType type));
  MOCK_METHOD(void, OnCreateCaptureEngineFailed,
              (CameraResult result, const std::string& error), (override));

  MOCK_METHOD(void, OnStartPreviewSucceeded, (int32_t width, int32_t height),
              (override));
  MOCK_METHOD(void, OnStartPreviewFailed,
              (CameraResult result, const std::string& error), (override));

  MOCK_METHOD(void, OnResumePreviewSucceeded, (), (override));
  MOCK_METHOD(void, OnResumePreviewFailed,
              (CameraResult result, const std::string& error), (override));

  MOCK_METHOD(void, OnPausePreviewSucceeded, (), (override));
  MOCK_METHOD(void, OnPausePreviewFailed,
              (CameraResult result, const std::string& error), (override));

  MOCK_METHOD(void, OnStartRecordSucceeded, (), (override));
  MOCK_METHOD(void, OnStartRecordFailed,
              (CameraResult result, const std::string& error), (override));

  MOCK_METHOD(void, OnStopRecordSucceeded, (const std::string& file_path),
              (override));
  MOCK_METHOD(void, OnStopRecordFailed,
              (CameraResult result, const std::string& error), (override));

  MOCK_METHOD(void, OnTakePictureSucceeded, (const std::string& file_path),
              (override));
  MOCK_METHOD(void, OnTakePictureFailed,
              (CameraResult result, const std::string& error), (override));

  MOCK_METHOD(void, OnVideoRecordSucceeded,
              (const std::string& file_path, int64_t video_duration),
              (override));
  MOCK_METHOD(void, OnVideoRecordFailed,
              (CameraResult result, const std::string& error), (override));
  MOCK_METHOD(void, OnCaptureError,
              (CameraResult result, const std::string& error), (override));

  MOCK_METHOD(bool, HasDeviceId, (std::string & device_id), (const override));
  MOCK_METHOD(bool, HasCameraId, (int64_t camera_id), (const override));

  MOCK_METHOD(bool, AddPendingResult,
              (PendingResultType type, std::unique_ptr<MethodResult<>> result),
              (override));
  MOCK_METHOD(bool, HasPendingResultByType, (PendingResultType type),
              (const override));

  MOCK_METHOD(camera_windows::CaptureController*, GetCaptureController, (),
              (override));

  MOCK_METHOD(bool, InitCamera,
              (flutter::TextureRegistrar * texture_registrar,
               flutter::BinaryMessenger* messenger, bool record_audio,
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
  ~MockCaptureController() = default;

  MOCK_METHOD(bool, InitCaptureDevice,
              (flutter::TextureRegistrar * texture_registrar,
               const std::string& device_id, bool record_audio,
               ResolutionPreset resolution_preset),
              (override));

  MOCK_METHOD(uint32_t, GetPreviewWidth, (), (const override));
  MOCK_METHOD(uint32_t, GetPreviewHeight, (), (const override));

  // Actions
  MOCK_METHOD(void, StartPreview, (), (override));
  MOCK_METHOD(void, ResumePreview, (), (override));
  MOCK_METHOD(void, PausePreview, (), (override));
  MOCK_METHOD(void, StartRecord,
              (const std::string& file_path, int64_t max_video_duration_ms),
              (override));
  MOCK_METHOD(void, StopRecord, (), (override));
  MOCK_METHOD(void, TakePicture, (const std::string& file_path), (override));
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

  ~MockCameraPlugin() = default;

  // Disallow copy and move.
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

class MockCaptureSource : public IMFCaptureSource {
 public:
  MockCaptureSource(){};
  ~MockCaptureSource() = default;

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

    if (riid == IID_IMFCaptureSource) {
      *ppv = static_cast<IMFCaptureSource*>(this);
      ((IUnknown*)*ppv)->AddRef();
      return S_OK;
    }

    return E_NOINTERFACE;
  }

  MOCK_METHOD(HRESULT, GetCaptureDeviceSource,
              (MF_CAPTURE_ENGINE_DEVICE_TYPE mfCaptureEngineDeviceType,
               IMFMediaSource** ppMediaSource));
  MOCK_METHOD(HRESULT, GetCaptureDeviceActivate,
              (MF_CAPTURE_ENGINE_DEVICE_TYPE mfCaptureEngineDeviceType,
               IMFActivate** ppActivate));
  MOCK_METHOD(HRESULT, GetService,
              (REFIID rguidService, REFIID riid, IUnknown** ppUnknown));
  MOCK_METHOD(HRESULT, AddEffect,
              (DWORD dwSourceStreamIndex, IUnknown* pUnknown));

  MOCK_METHOD(HRESULT, RemoveEffect,
              (DWORD dwSourceStreamIndex, IUnknown* pUnknown));
  MOCK_METHOD(HRESULT, RemoveAllEffects, (DWORD dwSourceStreamIndex));
  MOCK_METHOD(HRESULT, GetAvailableDeviceMediaType,
              (DWORD dwSourceStreamIndex, DWORD dwMediaTypeIndex,
               IMFMediaType** ppMediaType));
  MOCK_METHOD(HRESULT, SetCurrentDeviceMediaType,
              (DWORD dwSourceStreamIndex, IMFMediaType* pMediaType));
  MOCK_METHOD(HRESULT, GetCurrentDeviceMediaType,
              (DWORD dwSourceStreamIndex, IMFMediaType** ppMediaType));
  MOCK_METHOD(HRESULT, GetDeviceStreamCount, (DWORD * pdwStreamCount));
  MOCK_METHOD(HRESULT, GetDeviceStreamCategory,
              (DWORD dwSourceStreamIndex,
               MF_CAPTURE_ENGINE_STREAM_CATEGORY* pStreamCategory));
  MOCK_METHOD(HRESULT, GetMirrorState,
              (DWORD dwStreamIndex, BOOL* pfMirrorState));
  MOCK_METHOD(HRESULT, SetMirrorState,
              (DWORD dwStreamIndex, BOOL fMirrorState));
  MOCK_METHOD(HRESULT, GetStreamIndexFromFriendlyName,
              (UINT32 uifriendlyName, DWORD* pdwActualStreamIndex));

 private:
  volatile ULONG ref_ = 0;
};

// Uses IMFMediaSourceEx which has SetD3DManager method.
class MockMediaSource : public IMFMediaSourceEx {
 public:
  MockMediaSource(){};
  ~MockMediaSource() = default;

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
  volatile ULONG ref_ = 0;
};

class MockCapturePreviewSink : public IMFCapturePreviewSink {
 public:
  // IMFCaptureSink
  MOCK_METHOD(HRESULT, GetOutputMediaType,
              (DWORD dwSinkStreamIndex, IMFMediaType** ppMediaType));

  // IMFCaptureSink
  MOCK_METHOD(HRESULT, GetService,
              (DWORD dwSinkStreamIndex, REFGUID rguidService, REFIID riid,
               IUnknown** ppUnknown));

  // IMFCaptureSink
  MOCK_METHOD(HRESULT, AddStream,
              (DWORD dwSourceStreamIndex, IMFMediaType* pMediaType,
               IMFAttributes* pAttributes, DWORD* pdwSinkStreamIndex));

  // IMFCaptureSink
  MOCK_METHOD(HRESULT, Prepare, ());

  // IMFCaptureSink
  MOCK_METHOD(HRESULT, RemoveAllStreams, ());

  // IMFCapturePreviewSink
  MOCK_METHOD(HRESULT, SetRenderHandle, (HANDLE handle));

  // IMFCapturePreviewSink
  MOCK_METHOD(HRESULT, SetRenderSurface, (IUnknown * pSurface));

  // IMFCapturePreviewSink
  MOCK_METHOD(HRESULT, UpdateVideo,
              (const MFVideoNormalizedRect* pSrc, const RECT* pDst,
               const COLORREF* pBorderClr));

  // IMFCapturePreviewSink
  MOCK_METHOD(HRESULT, SetSampleCallback,
              (DWORD dwStreamSinkIndex,
               IMFCaptureEngineOnSampleCallback* pCallback));

  // IMFCapturePreviewSink
  MOCK_METHOD(HRESULT, GetMirrorState, (BOOL * pfMirrorState));

  // IMFCapturePreviewSink
  MOCK_METHOD(HRESULT, SetMirrorState, (BOOL fMirrorState));

  // IMFCapturePreviewSink
  MOCK_METHOD(HRESULT, GetRotation,
              (DWORD dwStreamIndex, DWORD* pdwRotationValue));

  // IMFCapturePreviewSink
  MOCK_METHOD(HRESULT, SetRotation,
              (DWORD dwStreamIndex, DWORD dwRotationValue));

  // IMFCapturePreviewSink
  MOCK_METHOD(HRESULT, SetCustomSink, (IMFMediaSink * pMediaSink));

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

    if (riid == IID_IMFCapturePreviewSink) {
      *ppv = static_cast<IMFCapturePreviewSink*>(this);
      ((IUnknown*)*ppv)->AddRef();
      return S_OK;
    }

    return E_NOINTERFACE;
  }

  void SendFakeSample(uint8_t* src_buffer, uint32_t size) {
    assert(sample_callback_);
    ComPtr<IMFSample> sample;
    ComPtr<IMFMediaBuffer> buffer;
    HRESULT hr = MFCreateSample(&sample);

    if (SUCCEEDED(hr)) {
      hr = MFCreateMemoryBuffer(size, &buffer);
    }

    if (SUCCEEDED(hr)) {
      uint8_t* target_data;
      if (SUCCEEDED(buffer->Lock(&target_data, nullptr, nullptr))) {
        std::copy(src_buffer, src_buffer + size, target_data);
      }
      hr = buffer->Unlock();
    }

    if (SUCCEEDED(hr)) {
      hr = buffer->SetCurrentLength(size);
    }

    if (SUCCEEDED(hr)) {
      hr = sample->AddBuffer(buffer.Get());
    }

    if (SUCCEEDED(hr)) {
      sample_callback_->OnSample(sample.Get());
    }
  }

  ComPtr<IMFCaptureEngineOnSampleCallback> sample_callback_;

 private:
  ~MockCapturePreviewSink() = default;
  volatile ULONG ref_ = 0;
};

class MockCaptureRecordSink : public IMFCaptureRecordSink {
 public:
  // IMFCaptureSink
  MOCK_METHOD(HRESULT, GetOutputMediaType,
              (DWORD dwSinkStreamIndex, IMFMediaType** ppMediaType));

  // IMFCaptureSink
  MOCK_METHOD(HRESULT, GetService,
              (DWORD dwSinkStreamIndex, REFGUID rguidService, REFIID riid,
               IUnknown** ppUnknown));

  // IMFCaptureSink
  MOCK_METHOD(HRESULT, AddStream,
              (DWORD dwSourceStreamIndex, IMFMediaType* pMediaType,
               IMFAttributes* pAttributes, DWORD* pdwSinkStreamIndex));

  // IMFCaptureSink
  MOCK_METHOD(HRESULT, Prepare, ());

  // IMFCaptureSink
  MOCK_METHOD(HRESULT, RemoveAllStreams, ());

  // IMFCaptureRecordSink
  MOCK_METHOD(HRESULT, SetOutputByteStream,
              (IMFByteStream * pByteStream, REFGUID guidContainerType));

  // IMFCaptureRecordSink
  MOCK_METHOD(HRESULT, SetOutputFileName, (LPCWSTR fileName));

  // IMFCaptureRecordSink
  MOCK_METHOD(HRESULT, SetSampleCallback,
              (DWORD dwStreamSinkIndex,
               IMFCaptureEngineOnSampleCallback* pCallback));

  // IMFCaptureRecordSink
  MOCK_METHOD(HRESULT, SetCustomSink, (IMFMediaSink * pMediaSink));

  // IMFCaptureRecordSink
  MOCK_METHOD(HRESULT, GetRotation,
              (DWORD dwStreamIndex, DWORD* pdwRotationValue));

  // IMFCaptureRecordSink
  MOCK_METHOD(HRESULT, SetRotation,
              (DWORD dwStreamIndex, DWORD dwRotationValue));

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

    if (riid == IID_IMFCaptureRecordSink) {
      *ppv = static_cast<IMFCaptureRecordSink*>(this);
      ((IUnknown*)*ppv)->AddRef();
      return S_OK;
    }

    return E_NOINTERFACE;
  }

 private:
  ~MockCaptureRecordSink() = default;
  volatile ULONG ref_ = 0;
};

class MockCapturePhotoSink : public IMFCapturePhotoSink {
 public:
  // IMFCaptureSink
  MOCK_METHOD(HRESULT, GetOutputMediaType,
              (DWORD dwSinkStreamIndex, IMFMediaType** ppMediaType));

  // IMFCaptureSink
  MOCK_METHOD(HRESULT, GetService,
              (DWORD dwSinkStreamIndex, REFGUID rguidService, REFIID riid,
               IUnknown** ppUnknown));

  // IMFCaptureSink
  MOCK_METHOD(HRESULT, AddStream,
              (DWORD dwSourceStreamIndex, IMFMediaType* pMediaType,
               IMFAttributes* pAttributes, DWORD* pdwSinkStreamIndex));

  // IMFCaptureSink
  MOCK_METHOD(HRESULT, Prepare, ());

  // IMFCaptureSink
  MOCK_METHOD(HRESULT, RemoveAllStreams, ());

  // IMFCapturePhotoSink
  MOCK_METHOD(HRESULT, SetOutputFileName, (LPCWSTR fileName));

  // IMFCapturePhotoSink
  MOCK_METHOD(HRESULT, SetSampleCallback,
              (IMFCaptureEngineOnSampleCallback * pCallback));

  // IMFCapturePhotoSink
  MOCK_METHOD(HRESULT, SetOutputByteStream, (IMFByteStream * pByteStream));

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

    if (riid == IID_IMFCapturePhotoSink) {
      *ppv = static_cast<IMFCapturePhotoSink*>(this);
      ((IUnknown*)*ppv)->AddRef();
      return S_OK;
    }

    return E_NOINTERFACE;
  }

 private:
  ~MockCapturePhotoSink() = default;
  volatile ULONG ref_ = 0;
};

template <class T>
class FakeIMFAttributesBase : public T {
  static_assert(std::is_base_of<IMFAttributes, T>::value,
                "I must inherit from IMFAttributes");

  // IIMFAttributes
  HRESULT GetItem(REFGUID guidKey, PROPVARIANT* pValue) override {
    return E_NOTIMPL;
  }

  // IIMFAttributes
  HRESULT GetItemType(REFGUID guidKey, MF_ATTRIBUTE_TYPE* pType) override {
    return E_NOTIMPL;
  }

  // IIMFAttributes
  HRESULT CompareItem(REFGUID guidKey, REFPROPVARIANT Value,
                      BOOL* pbResult) override {
    return E_NOTIMPL;
  }

  // IIMFAttributes
  HRESULT Compare(IMFAttributes* pTheirs, MF_ATTRIBUTES_MATCH_TYPE MatchType,
                  BOOL* pbResult) override {
    return E_NOTIMPL;
  }

  // IIMFAttributes
  HRESULT GetUINT32(REFGUID guidKey, UINT32* punValue) override {
    return E_NOTIMPL;
  }

  // IIMFAttributes
  HRESULT GetUINT64(REFGUID guidKey, UINT64* punValue) override {
    return E_NOTIMPL;
  }

  // IIMFAttributes
  HRESULT GetDouble(REFGUID guidKey, double* pfValue) override {
    return E_NOTIMPL;
  }

  // IIMFAttributes
  HRESULT GetGUID(REFGUID guidKey, GUID* pguidValue) override {
    return E_NOTIMPL;
  }

  // IIMFAttributes
  HRESULT GetStringLength(REFGUID guidKey, UINT32* pcchLength) override {
    return E_NOTIMPL;
  }

  // IIMFAttributes
  HRESULT GetString(REFGUID guidKey, LPWSTR pwszValue, UINT32 cchBufSize,
                    UINT32* pcchLength) override {
    return E_NOTIMPL;
  }

  // IIMFAttributes
  HRESULT GetAllocatedString(REFGUID guidKey, LPWSTR* ppwszValue,
                             UINT32* pcchLength) override {
    return E_NOTIMPL;
  }

  // IIMFAttributes
  HRESULT GetBlobSize(REFGUID guidKey, UINT32* pcbBlobSize) override {
    return E_NOTIMPL;
  }

  // IIMFAttributes
  HRESULT GetBlob(REFGUID guidKey, UINT8* pBuf, UINT32 cbBufSize,
                  UINT32* pcbBlobSize) override {
    return E_NOTIMPL;
  }

  // IIMFAttributes
  HRESULT GetAllocatedBlob(REFGUID guidKey, UINT8** ppBuf,
                           UINT32* pcbSize) override {
    return E_NOTIMPL;
  }

  // IIMFAttributes
  HRESULT GetUnknown(REFGUID guidKey, REFIID riid,
                     __RPC__deref_out_opt LPVOID* ppv) override {
    return E_NOTIMPL;
  }

  // IIMFAttributes
  HRESULT SetItem(REFGUID guidKey, REFPROPVARIANT Value) override {
    return E_NOTIMPL;
  }

  // IIMFAttributes
  HRESULT DeleteItem(REFGUID guidKey) override { return E_NOTIMPL; }

  // IIMFAttributes
  HRESULT DeleteAllItems(void) override { return E_NOTIMPL; }

  // IIMFAttributes
  HRESULT SetUINT32(REFGUID guidKey, UINT32 unValue) override {
    return E_NOTIMPL;
  }

  // IIMFAttributes
  HRESULT SetUINT64(REFGUID guidKey, UINT64 unValue) override {
    return E_NOTIMPL;
  }

  // IIMFAttributes
  HRESULT SetDouble(REFGUID guidKey, double fValue) override {
    return E_NOTIMPL;
  }

  // IIMFAttributes
  HRESULT SetGUID(REFGUID guidKey, REFGUID guidValue) override {
    return E_NOTIMPL;
  }

  // IIMFAttributes
  HRESULT SetString(REFGUID guidKey, LPCWSTR wszValue) override {
    return E_NOTIMPL;
  }

  // IIMFAttributes
  HRESULT SetBlob(REFGUID guidKey, const UINT8* pBuf,
                  UINT32 cbBufSize) override {
    return E_NOTIMPL;
  }

  // IIMFAttributes
  HRESULT SetUnknown(REFGUID guidKey, IUnknown* pUnknown) override {
    return E_NOTIMPL;
  }

  // IIMFAttributes
  HRESULT LockStore(void) override { return E_NOTIMPL; }

  // IIMFAttributes
  HRESULT UnlockStore(void) override { return E_NOTIMPL; }

  // IIMFAttributes
  HRESULT GetCount(UINT32* pcItems) override { return E_NOTIMPL; }

  // IIMFAttributes
  HRESULT GetItemByIndex(UINT32 unIndex, GUID* pguidKey,
                         PROPVARIANT* pValue) override {
    return E_NOTIMPL;
  }

  // IIMFAttributes
  HRESULT CopyAllItems(IMFAttributes* pDest) override { return E_NOTIMPL; }
};

class FakeMediaType : public FakeIMFAttributesBase<IMFMediaType> {
 public:
  FakeMediaType(GUID major_type, GUID sub_type, int width, int height)
      : major_type_(major_type),
        sub_type_(sub_type),
        width_(width),
        height_(height){};

  // IMFAttributes
  HRESULT GetUINT64(REFGUID key, UINT64* value) override {
    if (key == MF_MT_FRAME_SIZE) {
      *value = (int64_t)width_ << 32 | (int64_t)height_;
      return S_OK;
    } else if (key == MF_MT_FRAME_RATE) {
      *value = (int64_t)frame_rate_ << 32 | 1;
      return S_OK;
    }
    return E_FAIL;
  };

  // IMFAttributes
  HRESULT GetGUID(REFGUID key, GUID* value) override {
    if (key == MF_MT_MAJOR_TYPE) {
      *value = major_type_;
      return S_OK;
    } else if (key == MF_MT_SUBTYPE) {
      *value = sub_type_;
      return S_OK;
    }
    return E_FAIL;
  }

  // IIMFAttributes
  HRESULT CopyAllItems(IMFAttributes* pDest) override {
    pDest->SetUINT64(MF_MT_FRAME_SIZE,
                     (int64_t)width_ << 32 | (int64_t)height_);
    pDest->SetUINT64(MF_MT_FRAME_RATE, (int64_t)frame_rate_ << 32 | 1);
    pDest->SetGUID(MF_MT_MAJOR_TYPE, major_type_);
    pDest->SetGUID(MF_MT_SUBTYPE, sub_type_);
    return S_OK;
  }

  // IMFMediaType
  HRESULT STDMETHODCALLTYPE GetMajorType(GUID* pguidMajorType) override {
    return E_NOTIMPL;
  };

  // IMFMediaType
  HRESULT STDMETHODCALLTYPE IsCompressedFormat(BOOL* pfCompressed) override {
    return E_NOTIMPL;
  }

  // IMFMediaType
  HRESULT STDMETHODCALLTYPE IsEqual(IMFMediaType* pIMediaType,
                                    DWORD* pdwFlags) override {
    return E_NOTIMPL;
  }

  // IMFMediaType
  HRESULT STDMETHODCALLTYPE GetRepresentation(
      GUID guidRepresentation, LPVOID* ppvRepresentation) override {
    return E_NOTIMPL;
  }

  // IMFMediaType
  HRESULT STDMETHODCALLTYPE FreeRepresentation(
      GUID guidRepresentation, LPVOID pvRepresentation) override {
    return E_NOTIMPL;
  }

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

    if (riid == IID_IMFMediaType) {
      *ppv = static_cast<IMFMediaType*>(this);
      ((IUnknown*)*ppv)->AddRef();
      return S_OK;
    }

    return E_NOINTERFACE;
  }

 private:
  ~FakeMediaType() = default;
  volatile ULONG ref_ = 0;
  const GUID major_type_;
  const GUID sub_type_;
  const int width_;
  const int height_;
  const int frame_rate_ = 30;
};

class MockCaptureEngine : public IMFCaptureEngine {
 public:
  MockCaptureEngine() {
    ON_CALL(*this, Initialize)
        .WillByDefault([this](IMFCaptureEngineOnEventCallback* callback,
                              IMFAttributes* attributes, IUnknown* audioSource,
                              IUnknown* videoSource) -> HRESULT {
          EXPECT_TRUE(callback);
          EXPECT_TRUE(attributes);
          EXPECT_TRUE(videoSource);
          // audioSource is allowed to be nullptr;
          callback_ = callback;
          videoSource_ = reinterpret_cast<IMFMediaSource*>(videoSource);
          audioSource_ = reinterpret_cast<IMFMediaSource*>(audioSource);
          initialized_ = true;
          return S_OK;
        });
  };

  virtual ~MockCaptureEngine() = default;

  MOCK_METHOD(HRESULT, Initialize,
              (IMFCaptureEngineOnEventCallback * callback,
               IMFAttributes* attributes, IUnknown* audioSource,
               IUnknown* videoSource));
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
  ComPtr<IMFMediaSource> videoSource_;
  ComPtr<IMFMediaSource> audioSource_;
  volatile ULONG ref_ = 0;
  bool initialized_ = false;
};

#define MOCK_DEVICE_ID "mock_device_id"
#define MOCK_CAMERA_NAME "mock_camera_name <" MOCK_DEVICE_ID ">"
#define MOCK_INVALID_CAMERA_NAME "invalid_camera_name"

}  // namespace
}  // namespace test
}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_TEST_MOCKS_H_
