// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "capture_controller.h"

#include <flutter/method_call.h>
#include <flutter/method_result_functions.h>
#include <flutter/standard_method_codec.h>
#include <flutter/texture_registrar.h>
#include <gmock/gmock.h>
#include <gtest/gtest.h>
#include <windows.h>
#include <wrl/client.h>

#include <functional>
#include <memory>
#include <string>

#include "mocks.h"
#include "string_utils.h"

namespace camera_windows {

namespace test {

using Microsoft::WRL::ComPtr;
using ::testing::_;
using ::testing::Eq;
using ::testing::Return;

void MockInitCaptureController(CaptureControllerImpl* capture_controller,
                               MockTextureRegistrar* texture_registrar,
                               MockCaptureEngine* engine, MockCamera* camera,
                               int64_t mock_texture_id) {
  ComPtr<MockMediaSource> video_source = new MockMediaSource();
  ComPtr<MockMediaSource> audio_source = new MockMediaSource();

  capture_controller->SetCaptureEngine(
      reinterpret_cast<IMFCaptureEngine*>(engine));
  capture_controller->SetVideoSource(
      reinterpret_cast<IMFMediaSource*>(video_source.Get()));
  capture_controller->SetAudioSource(
      reinterpret_cast<IMFMediaSource*>(audio_source.Get()));

  EXPECT_CALL(*texture_registrar, RegisterTexture)
      .Times(1)
      .WillOnce([reg = texture_registrar,
                 mock_texture_id](flutter::TextureVariant* texture) -> int64_t {
        EXPECT_TRUE(texture);
        reg->texture_ = texture;
        reg->texture_id_ = mock_texture_id;
        return reg->texture_id_;
      });
  EXPECT_CALL(*texture_registrar, UnregisterTexture(Eq(mock_texture_id)))
      .Times(1);
  EXPECT_CALL(*camera, OnCreateCaptureEngineFailed).Times(0);
  EXPECT_CALL(*camera, OnCreateCaptureEngineSucceeded(Eq(mock_texture_id)))
      .Times(1);
  EXPECT_CALL(*engine, Initialize).Times(1);

  bool result = capture_controller->InitCaptureDevice(
      texture_registrar, MOCK_DEVICE_ID, true, ResolutionPreset::kAuto);

  EXPECT_TRUE(result);

  // MockCaptureEngine::Initialize is called
  EXPECT_TRUE(engine->initialized_);

  engine->CreateFakeEvent(S_OK, MF_CAPTURE_ENGINE_INITIALIZED);
}

void MockAvailableMediaTypes(MockCaptureEngine* engine,
                             MockCaptureSource* capture_source,
                             uint32_t mock_preview_width,
                             uint32_t mock_preview_height) {
  EXPECT_CALL(*engine, GetSource)
      .Times(1)
      .WillOnce(
          [src_source = capture_source](IMFCaptureSource** target_source) {
            *target_source = src_source;
            src_source->AddRef();
            return S_OK;
          });

  EXPECT_CALL(
      *capture_source,
      GetAvailableDeviceMediaType(
          Eq((DWORD)
                 MF_CAPTURE_ENGINE_PREFERRED_SOURCE_STREAM_FOR_VIDEO_PREVIEW),
          _, _))
      .WillRepeatedly([mock_preview_width, mock_preview_height](
                          DWORD stream_index, DWORD media_type_index,
                          IMFMediaType** media_type) {
        // We give only one media type to loop through
        if (media_type_index != 0) return MF_E_NO_MORE_TYPES;
        *media_type =
            new FakeMediaType(MFMediaType_Video, MFVideoFormat_RGB32,
                              mock_preview_width, mock_preview_height);
        (*media_type)->AddRef();
        return S_OK;
      });

  EXPECT_CALL(
      *capture_source,
      GetAvailableDeviceMediaType(
          Eq((DWORD)MF_CAPTURE_ENGINE_PREFERRED_SOURCE_STREAM_FOR_VIDEO_RECORD),
          _, _))
      .WillRepeatedly([mock_preview_width, mock_preview_height](
                          DWORD stream_index, DWORD media_type_index,
                          IMFMediaType** media_type) {
        // We give only one media type to loop through
        if (media_type_index != 0) return MF_E_NO_MORE_TYPES;
        *media_type =
            new FakeMediaType(MFMediaType_Video, MFVideoFormat_RGB32,
                              mock_preview_width, mock_preview_height);
        (*media_type)->AddRef();
        return S_OK;
      });
}

void MockStartPreview(CaptureControllerImpl* capture_controller,
                      MockCapturePreviewSink* preview_sink,
                      MockTextureRegistrar* texture_registrar,
                      MockCaptureEngine* engine, MockCamera* camera,
                      std::unique_ptr<uint8_t[]> mock_source_buffer,
                      uint32_t mock_source_buffer_size,
                      uint32_t mock_preview_width, uint32_t mock_preview_height,
                      int64_t mock_texture_id) {
  EXPECT_CALL(*engine, GetSink(MF_CAPTURE_ENGINE_SINK_TYPE_PREVIEW, _))
      .Times(1)
      .WillOnce([src_sink = preview_sink](MF_CAPTURE_ENGINE_SINK_TYPE sink_type,
                                          IMFCaptureSink** target_sink) {
        *target_sink = src_sink;
        src_sink->AddRef();
        return S_OK;
      });

  EXPECT_CALL(*preview_sink, RemoveAllStreams).Times(1).WillOnce(Return(S_OK));
  EXPECT_CALL(*preview_sink, AddStream).Times(1).WillOnce(Return(S_OK));
  EXPECT_CALL(*preview_sink, SetSampleCallback)
      .Times(1)
      .WillOnce([sink = preview_sink](
                    DWORD dwStreamSinkIndex,
                    IMFCaptureEngineOnSampleCallback* pCallback) -> HRESULT {
        sink->sample_callback_ = pCallback;
        return S_OK;
      });

  ComPtr<MockCaptureSource> capture_source = new MockCaptureSource();
  MockAvailableMediaTypes(engine, capture_source.Get(), mock_preview_width,
                          mock_preview_height);

  EXPECT_CALL(*engine, StartPreview()).Times(1).WillOnce(Return(S_OK));

  // Called by destructor
  EXPECT_CALL(*engine, StopPreview()).Times(1).WillOnce(Return(S_OK));

  // Called after first processed sample
  EXPECT_CALL(*camera,
              OnStartPreviewSucceeded(mock_preview_width, mock_preview_height))
      .Times(1);
  EXPECT_CALL(*camera, OnStartPreviewFailed).Times(0);
  EXPECT_CALL(*texture_registrar, MarkTextureFrameAvailable(mock_texture_id))
      .Times(1);

  capture_controller->StartPreview();

  EXPECT_EQ(capture_controller->GetPreviewHeight(), mock_preview_height);
  EXPECT_EQ(capture_controller->GetPreviewWidth(), mock_preview_width);

  // Capture engine is now started and will first send event of started preview
  engine->CreateFakeEvent(S_OK, MF_CAPTURE_ENGINE_PREVIEW_STARTED);

  // SendFake sample
  preview_sink->SendFakeSample(mock_source_buffer.get(),
                               mock_source_buffer_size);
}

void MockPhotoSink(MockCaptureEngine* engine,
                   MockCapturePhotoSink* photo_sink) {
  EXPECT_CALL(*engine, GetSink(MF_CAPTURE_ENGINE_SINK_TYPE_PHOTO, _))
      .Times(1)
      .WillOnce([src_sink = photo_sink](MF_CAPTURE_ENGINE_SINK_TYPE sink_type,
                                        IMFCaptureSink** target_sink) {
        *target_sink = src_sink;
        src_sink->AddRef();
        return S_OK;
      });
  EXPECT_CALL(*photo_sink, RemoveAllStreams).Times(1).WillOnce(Return(S_OK));
  EXPECT_CALL(*photo_sink, AddStream).Times(1).WillOnce(Return(S_OK));
  EXPECT_CALL(*photo_sink, SetOutputFileName).Times(1).WillOnce(Return(S_OK));
}

void MockRecordStart(CaptureControllerImpl* capture_controller,
                     MockCaptureEngine* engine,
                     MockCaptureRecordSink* record_sink, MockCamera* camera,
                     const std::string& mock_path_to_video) {
  EXPECT_CALL(*engine, StartRecord()).Times(1).WillOnce(Return(S_OK));

  EXPECT_CALL(*engine, GetSink(MF_CAPTURE_ENGINE_SINK_TYPE_RECORD, _))
      .Times(1)
      .WillOnce([src_sink = record_sink](MF_CAPTURE_ENGINE_SINK_TYPE sink_type,
                                         IMFCaptureSink** target_sink) {
        *target_sink = src_sink;
        src_sink->AddRef();
        return S_OK;
      });

  EXPECT_CALL(*record_sink, RemoveAllStreams).Times(1).WillOnce(Return(S_OK));
  EXPECT_CALL(*record_sink, AddStream).Times(2).WillRepeatedly(Return(S_OK));
  EXPECT_CALL(*record_sink, SetOutputFileName).Times(1).WillOnce(Return(S_OK));

  capture_controller->StartRecord(mock_path_to_video, -1);

  EXPECT_CALL(*camera, OnStartRecordSucceeded()).Times(1);
  engine->CreateFakeEvent(S_OK, MF_CAPTURE_ENGINE_RECORD_STARTED);
}

TEST(CaptureController,
     InitCaptureEngineCallsOnCreateCaptureEngineSucceededWithTextureId) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  int64_t mock_texture_id = 1234;

  // Init capture controller with mocks and tests
  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  capture_controller = nullptr;
  camera = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
}

TEST(CaptureController, InitCaptureEngineCanOnlyBeCalledOnce) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  int64_t mock_texture_id = 1234;

  // Init capture controller once with mocks and tests
  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  // Init capture controller a second time.
  EXPECT_CALL(*camera, OnCreateCaptureEngineFailed).Times(1);

  bool result = capture_controller->InitCaptureDevice(
      texture_registrar.get(), MOCK_DEVICE_ID, true, ResolutionPreset::kAuto);

  EXPECT_FALSE(result);

  capture_controller = nullptr;
  camera = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
}

TEST(CaptureController, InitCaptureEngineReportsFailure) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  ComPtr<MockMediaSource> video_source = new MockMediaSource();
  ComPtr<MockMediaSource> audio_source = new MockMediaSource();

  capture_controller->SetCaptureEngine(
      reinterpret_cast<IMFCaptureEngine*>(engine.Get()));
  capture_controller->SetVideoSource(
      reinterpret_cast<IMFMediaSource*>(video_source.Get()));
  capture_controller->SetAudioSource(
      reinterpret_cast<IMFMediaSource*>(audio_source.Get()));

  // Cause initialization to fail
  EXPECT_CALL(*engine.Get(), Initialize).Times(1).WillOnce(Return(E_FAIL));

  EXPECT_CALL(*texture_registrar, RegisterTexture).Times(0);
  EXPECT_CALL(*texture_registrar, UnregisterTexture(_)).Times(0);
  EXPECT_CALL(*camera, OnCreateCaptureEngineSucceeded).Times(0);
  EXPECT_CALL(*camera,
              OnCreateCaptureEngineFailed(Eq(CameraResult::kError),
                                          Eq("Failed to create camera")))
      .Times(1);

  bool result = capture_controller->InitCaptureDevice(
      texture_registrar.get(), MOCK_DEVICE_ID, true, ResolutionPreset::kAuto);

  EXPECT_FALSE(result);
  EXPECT_FALSE(engine->initialized_);

  capture_controller = nullptr;
  camera = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
}

TEST(CaptureController, InitCaptureEngineReportsAccessDenied) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  ComPtr<MockMediaSource> video_source = new MockMediaSource();
  ComPtr<MockMediaSource> audio_source = new MockMediaSource();

  capture_controller->SetCaptureEngine(
      reinterpret_cast<IMFCaptureEngine*>(engine.Get()));
  capture_controller->SetVideoSource(
      reinterpret_cast<IMFMediaSource*>(video_source.Get()));
  capture_controller->SetAudioSource(
      reinterpret_cast<IMFMediaSource*>(audio_source.Get()));

  // Cause initialization to fail
  EXPECT_CALL(*engine.Get(), Initialize)
      .Times(1)
      .WillOnce(Return(E_ACCESSDENIED));

  EXPECT_CALL(*texture_registrar, RegisterTexture).Times(0);
  EXPECT_CALL(*texture_registrar, UnregisterTexture(_)).Times(0);
  EXPECT_CALL(*camera, OnCreateCaptureEngineSucceeded).Times(0);
  EXPECT_CALL(*camera,
              OnCreateCaptureEngineFailed(Eq(CameraResult::kAccessDenied),
                                          Eq("Failed to create camera")))
      .Times(1);

  bool result = capture_controller->InitCaptureDevice(
      texture_registrar.get(), MOCK_DEVICE_ID, true, ResolutionPreset::kAuto);

  EXPECT_FALSE(result);
  EXPECT_FALSE(engine->initialized_);

  capture_controller = nullptr;
  camera = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
}

TEST(CaptureController, ReportsInitializedErrorEvent) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  int64_t mock_texture_id = 1234;

  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  EXPECT_CALL(*camera, OnCreateCaptureEngineFailed(
                           Eq(CameraResult::kError),
                           Eq("Failed to initialize capture engine")))
      .Times(1);
  EXPECT_CALL(*camera, OnCreateCaptureEngineSucceeded).Times(0);

  // Send initialization failed event
  engine->CreateFakeEvent(E_FAIL, MF_CAPTURE_ENGINE_INITIALIZED);

  capture_controller = nullptr;
  camera = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
}

TEST(CaptureController, ReportsInitializedAccessDeniedEvent) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  int64_t mock_texture_id = 1234;

  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  EXPECT_CALL(*camera, OnCreateCaptureEngineFailed(
                           Eq(CameraResult::kAccessDenied),
                           Eq("Failed to initialize capture engine")))
      .Times(1);
  EXPECT_CALL(*camera, OnCreateCaptureEngineSucceeded).Times(0);

  // Send initialization failed event
  engine->CreateFakeEvent(E_ACCESSDENIED, MF_CAPTURE_ENGINE_INITIALIZED);

  capture_controller = nullptr;
  camera = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
}

TEST(CaptureController, ReportsCaptureEngineErrorEvent) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  int64_t mock_texture_id = 1234;

  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  EXPECT_CALL(*(camera.get()),
              OnCaptureError(Eq(CameraResult::kError), Eq("Unspecified error")))
      .Times(1);

  // Send error event.
  engine->CreateFakeEvent(E_FAIL, MF_CAPTURE_ENGINE_ERROR);

  capture_controller = nullptr;
  camera = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
}

TEST(CaptureController, ReportsCaptureEngineAccessDeniedEvent) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  int64_t mock_texture_id = 1234;

  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  EXPECT_CALL(*(camera.get()), OnCaptureError(Eq(CameraResult::kAccessDenied),
                                              Eq("Access is denied.")))
      .Times(1);

  // Send error event.
  engine->CreateFakeEvent(E_ACCESSDENIED, MF_CAPTURE_ENGINE_ERROR);

  capture_controller = nullptr;
  camera = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
}

TEST(CaptureController, StartPreviewStartsProcessingSamples) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  int64_t mock_texture_id = 1234;

  // Initialize capture controller to be able to start preview
  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  ComPtr<MockCapturePreviewSink> preview_sink = new MockCapturePreviewSink();

  // Let's keep these small for mock texture data. Two pixels should be
  // enough.
  uint32_t mock_preview_width = 2;
  uint32_t mock_preview_height = 1;
  uint32_t pixels_total = mock_preview_width * mock_preview_height;
  uint32_t pixel_size = 4;

  // Build mock texture
  uint32_t mock_texture_data_size = pixels_total * pixel_size;

  std::unique_ptr<uint8_t[]> mock_source_buffer =
      std::make_unique<uint8_t[]>(mock_texture_data_size);

  uint8_t mock_red_pixel = 0x11;
  uint8_t mock_green_pixel = 0x22;
  uint8_t mock_blue_pixel = 0x33;
  MFVideoFormatRGB32Pixel* mock_source_buffer_data =
      (MFVideoFormatRGB32Pixel*)mock_source_buffer.get();

  for (uint32_t i = 0; i < pixels_total; i++) {
    mock_source_buffer_data[i].r = mock_red_pixel;
    mock_source_buffer_data[i].g = mock_green_pixel;
    mock_source_buffer_data[i].b = mock_blue_pixel;
  }

  // Start preview and run preview tests
  MockStartPreview(capture_controller.get(), preview_sink.Get(),
                   texture_registrar.get(), engine.Get(), camera.get(),
                   std::move(mock_source_buffer), mock_texture_data_size,
                   mock_preview_width, mock_preview_height, mock_texture_id);

  // Test texture processing
  EXPECT_TRUE(texture_registrar->texture_);
  if (texture_registrar->texture_) {
    auto pixel_buffer_texture =
        std::get_if<flutter::PixelBufferTexture>(texture_registrar->texture_);
    EXPECT_TRUE(pixel_buffer_texture);

    if (pixel_buffer_texture) {
      auto converted_buffer =
          pixel_buffer_texture->CopyPixelBuffer((size_t)100, (size_t)100);

      EXPECT_TRUE(converted_buffer);
      if (converted_buffer) {
        EXPECT_EQ(converted_buffer->height, mock_preview_height);
        EXPECT_EQ(converted_buffer->width, mock_preview_width);

        FlutterDesktopPixel* converted_buffer_data =
            (FlutterDesktopPixel*)(converted_buffer->buffer);

        for (uint32_t i = 0; i < pixels_total; i++) {
          EXPECT_EQ(converted_buffer_data[i].r, mock_red_pixel);
          EXPECT_EQ(converted_buffer_data[i].g, mock_green_pixel);
          EXPECT_EQ(converted_buffer_data[i].b, mock_blue_pixel);
        }

        // Call release callback to get mutex lock unlocked.
        converted_buffer->release_callback(converted_buffer->release_context);
      }
      converted_buffer = nullptr;
    }
    pixel_buffer_texture = nullptr;
  }

  capture_controller = nullptr;
  engine = nullptr;
  camera = nullptr;
  texture_registrar = nullptr;
}

TEST(CaptureController, ReportsStartPreviewError) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  int64_t mock_texture_id = 1234;

  // Initialize capture controller to be able to start preview
  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  ComPtr<MockCaptureSource> capture_source = new MockCaptureSource();
  MockAvailableMediaTypes(engine.Get(), capture_source.Get(), 1, 1);

  // Cause start preview to fail
  EXPECT_CALL(*engine.Get(), GetSink(MF_CAPTURE_ENGINE_SINK_TYPE_PREVIEW, _))
      .Times(1)
      .WillOnce(Return(E_FAIL));

  EXPECT_CALL(*engine.Get(), StartPreview).Times(0);
  EXPECT_CALL(*engine.Get(), StopPreview).Times(0);
  EXPECT_CALL(*camera, OnStartPreviewSucceeded).Times(0);
  EXPECT_CALL(*camera,
              OnStartPreviewFailed(Eq(CameraResult::kError),
                                   Eq("Failed to start video preview")))
      .Times(1);

  capture_controller->StartPreview();

  capture_controller = nullptr;
  engine = nullptr;
  camera = nullptr;
  texture_registrar = nullptr;
}

// TODO(loic-sharma): Test duplicate calls to start preview.

TEST(CaptureController, IgnoresStartPreviewErrorEvent) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  int64_t mock_texture_id = 1234;

  // Initialize capture controller to be able to start preview
  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  EXPECT_CALL(*camera, OnStartPreviewFailed).Times(0);
  EXPECT_CALL(*camera, OnCreateCaptureEngineSucceeded).Times(0);

  // Send a start preview error event
  engine->CreateFakeEvent(E_FAIL, MF_CAPTURE_ENGINE_PREVIEW_STARTED);

  capture_controller = nullptr;
  camera = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
}

TEST(CaptureController, ReportsStartPreviewAccessDenied) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  int64_t mock_texture_id = 1234;

  // Initialize capture controller to be able to start preview
  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  ComPtr<MockCaptureSource> capture_source = new MockCaptureSource();
  MockAvailableMediaTypes(engine.Get(), capture_source.Get(), 1, 1);

  // Cause start preview to fail
  EXPECT_CALL(*engine.Get(), GetSink(MF_CAPTURE_ENGINE_SINK_TYPE_PREVIEW, _))
      .Times(1)
      .WillOnce(Return(E_ACCESSDENIED));

  EXPECT_CALL(*engine.Get(), StartPreview).Times(0);
  EXPECT_CALL(*engine.Get(), StopPreview).Times(0);
  EXPECT_CALL(*camera, OnStartPreviewSucceeded).Times(0);
  EXPECT_CALL(*camera,
              OnStartPreviewFailed(Eq(CameraResult::kAccessDenied),
                                   Eq("Failed to start video preview")))
      .Times(1);

  capture_controller->StartPreview();

  capture_controller = nullptr;
  engine = nullptr;
  camera = nullptr;
  texture_registrar = nullptr;
}

TEST(CaptureController, StartRecordSuccess) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  int64_t mock_texture_id = 1234;

  // Initialize capture controller to be able to start preview
  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  ComPtr<MockCaptureSource> capture_source = new MockCaptureSource();

  // Prepare fake media types
  MockAvailableMediaTypes(engine.Get(), capture_source.Get(), 1, 1);

  // Start record
  ComPtr<MockCaptureRecordSink> record_sink = new MockCaptureRecordSink();
  std::string mock_path_to_video = "mock_path_to_video";
  MockRecordStart(capture_controller.get(), engine.Get(), record_sink.Get(),
                  camera.get(), mock_path_to_video);

  // Called by destructor
  EXPECT_CALL(*(engine.Get()), StopRecord(true, false))
      .Times(1)
      .WillOnce(Return(S_OK));

  capture_controller = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
  camera = nullptr;
  record_sink = nullptr;
}

TEST(CaptureController, ReportsStartRecordError) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  int64_t mock_texture_id = 1234;

  // Initialize capture controller to be able to start preview
  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  ComPtr<MockCaptureSource> capture_source = new MockCaptureSource();

  // Prepare fake media types
  MockAvailableMediaTypes(engine.Get(), capture_source.Get(), 1, 1);

  // Cause start record to fail
  EXPECT_CALL(*engine.Get(), GetSink(MF_CAPTURE_ENGINE_SINK_TYPE_RECORD, _))
      .Times(1)
      .WillOnce(Return(E_FAIL));

  EXPECT_CALL(*engine.Get(), StartRecord).Times(0);
  EXPECT_CALL(*engine.Get(), StopRecord).Times(0);
  EXPECT_CALL(*camera, OnStartRecordSucceeded).Times(0);
  EXPECT_CALL(*camera,
              OnStartRecordFailed(Eq(CameraResult::kError),
                                  Eq("Failed to start video recording")))
      .Times(1);

  capture_controller->StartRecord("mock_path", -1);

  capture_controller = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
  camera = nullptr;
}

TEST(CaptureController, ReportsStartRecordAccessDenied) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  int64_t mock_texture_id = 1234;

  // Initialize capture controller to be able to start preview
  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  ComPtr<MockCaptureSource> capture_source = new MockCaptureSource();

  // Prepare fake media types
  MockAvailableMediaTypes(engine.Get(), capture_source.Get(), 1, 1);

  // Cause start record to fail
  EXPECT_CALL(*engine.Get(), GetSink(MF_CAPTURE_ENGINE_SINK_TYPE_RECORD, _))
      .Times(1)
      .WillOnce(Return(E_ACCESSDENIED));

  EXPECT_CALL(*engine.Get(), StartRecord).Times(0);
  EXPECT_CALL(*engine.Get(), StopRecord).Times(0);
  EXPECT_CALL(*camera, OnStartRecordSucceeded).Times(0);
  EXPECT_CALL(*camera,
              OnStartRecordFailed(Eq(CameraResult::kAccessDenied),
                                  Eq("Failed to start video recording")))
      .Times(1);

  capture_controller->StartRecord("mock_path", -1);

  capture_controller = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
  camera = nullptr;
}

TEST(CaptureController, ReportsStartRecordErrorEvent) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  int64_t mock_texture_id = 1234;

  // Initialize capture controller to be able to start preview
  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  ComPtr<MockCaptureSource> capture_source = new MockCaptureSource();

  // Prepare fake media types
  MockAvailableMediaTypes(engine.Get(), capture_source.Get(), 1, 1);

  // Start record
  ComPtr<MockCaptureRecordSink> record_sink = new MockCaptureRecordSink();
  std::string mock_path_to_video = "mock_path_to_video";

  EXPECT_CALL(*engine.Get(), StartRecord()).Times(1).WillOnce(Return(S_OK));

  EXPECT_CALL(*engine.Get(), GetSink(MF_CAPTURE_ENGINE_SINK_TYPE_RECORD, _))
      .Times(1)
      .WillOnce([src_sink = record_sink](MF_CAPTURE_ENGINE_SINK_TYPE sink_type,
                                         IMFCaptureSink** target_sink) {
        *target_sink = src_sink.Get();
        src_sink->AddRef();
        return S_OK;
      });

  EXPECT_CALL(*record_sink.Get(), RemoveAllStreams)
      .Times(1)
      .WillOnce(Return(S_OK));
  EXPECT_CALL(*record_sink.Get(), AddStream)
      .Times(2)
      .WillRepeatedly(Return(S_OK));
  EXPECT_CALL(*record_sink.Get(), SetOutputFileName)
      .Times(1)
      .WillOnce(Return(S_OK));

  capture_controller->StartRecord(mock_path_to_video, -1);

  // Send a start record failed event
  EXPECT_CALL(*camera, OnStartRecordSucceeded).Times(0);
  EXPECT_CALL(*camera, OnStartRecordFailed(Eq(CameraResult::kError),
                                           Eq("Unspecified error")))
      .Times(1);

  engine->CreateFakeEvent(E_FAIL, MF_CAPTURE_ENGINE_RECORD_STARTED);

  // Destructor shouldn't attempt to stop the recording that failed to start.
  EXPECT_CALL(*engine.Get(), StopRecord).Times(0);

  capture_controller = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
  camera = nullptr;
  record_sink = nullptr;
}

TEST(CaptureController, ReportsStartRecordAccessDeniedEvent) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  int64_t mock_texture_id = 1234;

  // Initialize capture controller to be able to start preview
  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  ComPtr<MockCaptureSource> capture_source = new MockCaptureSource();

  // Prepare fake media types
  MockAvailableMediaTypes(engine.Get(), capture_source.Get(), 1, 1);

  // Start record
  ComPtr<MockCaptureRecordSink> record_sink = new MockCaptureRecordSink();
  std::string mock_path_to_video = "mock_path_to_video";

  EXPECT_CALL(*engine.Get(), StartRecord()).Times(1).WillOnce(Return(S_OK));

  EXPECT_CALL(*engine.Get(), GetSink(MF_CAPTURE_ENGINE_SINK_TYPE_RECORD, _))
      .Times(1)
      .WillOnce([src_sink = record_sink](MF_CAPTURE_ENGINE_SINK_TYPE sink_type,
                                         IMFCaptureSink** target_sink) {
        *target_sink = src_sink.Get();
        src_sink->AddRef();
        return S_OK;
      });

  EXPECT_CALL(*record_sink.Get(), RemoveAllStreams)
      .Times(1)
      .WillOnce(Return(S_OK));
  EXPECT_CALL(*record_sink.Get(), AddStream)
      .Times(2)
      .WillRepeatedly(Return(S_OK));
  EXPECT_CALL(*record_sink.Get(), SetOutputFileName)
      .Times(1)
      .WillOnce(Return(S_OK));

  // Send a start record failed event
  capture_controller->StartRecord(mock_path_to_video, -1);

  EXPECT_CALL(*camera, OnStartRecordSucceeded).Times(0);
  EXPECT_CALL(*camera, OnStartRecordFailed(Eq(CameraResult::kAccessDenied),
                                           Eq("Access is denied.")))
      .Times(1);

  engine->CreateFakeEvent(E_ACCESSDENIED, MF_CAPTURE_ENGINE_RECORD_STARTED);

  // Destructor shouldn't attempt to stop the recording that failed to start.
  EXPECT_CALL(*engine.Get(), StopRecord).Times(0);

  capture_controller = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
  camera = nullptr;
  record_sink = nullptr;
}

TEST(CaptureController, StopRecordSuccess) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  int64_t mock_texture_id = 1234;

  // Initialize capture controller to be able to start preview
  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  ComPtr<MockCaptureSource> capture_source = new MockCaptureSource();

  // Prepare fake media types
  MockAvailableMediaTypes(engine.Get(), capture_source.Get(), 1, 1);

  // Start record
  ComPtr<MockCaptureRecordSink> record_sink = new MockCaptureRecordSink();
  std::string mock_path_to_video = "mock_path_to_video";
  MockRecordStart(capture_controller.get(), engine.Get(), record_sink.Get(),
                  camera.get(), mock_path_to_video);

  // Request to stop record
  EXPECT_CALL(*(engine.Get()), StopRecord(true, false))
      .Times(1)
      .WillOnce(Return(S_OK));
  capture_controller->StopRecord();

  // OnStopRecordSucceeded should be called with mocked file path
  EXPECT_CALL(*camera, OnStopRecordSucceeded(Eq(mock_path_to_video))).Times(1);
  EXPECT_CALL(*camera, OnStopRecordFailed).Times(0);

  engine->CreateFakeEvent(S_OK, MF_CAPTURE_ENGINE_RECORD_STOPPED);

  capture_controller = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
  camera = nullptr;
  record_sink = nullptr;
}

TEST(CaptureController, ReportsStopRecordError) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  int64_t mock_texture_id = 1234;

  // Initialize capture controller to be able to start preview
  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  ComPtr<MockCaptureSource> capture_source = new MockCaptureSource();

  // Prepare fake media types
  MockAvailableMediaTypes(engine.Get(), capture_source.Get(), 1, 1);

  // Start record
  ComPtr<MockCaptureRecordSink> record_sink = new MockCaptureRecordSink();
  MockRecordStart(capture_controller.get(), engine.Get(), record_sink.Get(),
                  camera.get(), "mock_path_to_video");

  // Cause stop record to fail
  EXPECT_CALL(*(engine.Get()), StopRecord(true, false))
      .Times(1)
      .WillOnce(Return(E_FAIL));

  EXPECT_CALL(*camera, OnStopRecordSucceeded).Times(0);
  EXPECT_CALL(*camera, OnStopRecordFailed(Eq(CameraResult::kError),
                                          Eq("Failed to stop video recording")))
      .Times(1);

  capture_controller->StopRecord();

  capture_controller = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
  camera = nullptr;
  record_sink = nullptr;
}

TEST(CaptureController, ReportsStopRecordAccessDenied) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  int64_t mock_texture_id = 1234;

  // Initialize capture controller to be able to start preview
  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  ComPtr<MockCaptureSource> capture_source = new MockCaptureSource();

  // Prepare fake media types
  MockAvailableMediaTypes(engine.Get(), capture_source.Get(), 1, 1);

  // Start record
  ComPtr<MockCaptureRecordSink> record_sink = new MockCaptureRecordSink();
  MockRecordStart(capture_controller.get(), engine.Get(), record_sink.Get(),
                  camera.get(), "mock_path_to_video");

  // Cause stop record to fail
  EXPECT_CALL(*(engine.Get()), StopRecord(true, false))
      .Times(1)
      .WillOnce(Return(E_ACCESSDENIED));

  EXPECT_CALL(*camera, OnStopRecordSucceeded).Times(0);
  EXPECT_CALL(*camera, OnStopRecordFailed(Eq(CameraResult::kAccessDenied),
                                          Eq("Failed to stop video recording")))
      .Times(1);

  capture_controller->StopRecord();

  capture_controller = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
  camera = nullptr;
  record_sink = nullptr;
}

TEST(CaptureController, ReportsStopRecordErrorEvent) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  int64_t mock_texture_id = 1234;

  // Initialize capture controller to be able to start preview
  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  ComPtr<MockCaptureSource> capture_source = new MockCaptureSource();

  // Prepare fake media types
  MockAvailableMediaTypes(engine.Get(), capture_source.Get(), 1, 1);

  // Start record
  ComPtr<MockCaptureRecordSink> record_sink = new MockCaptureRecordSink();
  std::string mock_path_to_video = "mock_path_to_video";
  MockRecordStart(capture_controller.get(), engine.Get(), record_sink.Get(),
                  camera.get(), mock_path_to_video);

  // Send a stop record failure event
  EXPECT_CALL(*camera, OnStopRecordSucceeded).Times(0);
  EXPECT_CALL(*camera, OnStopRecordFailed(Eq(CameraResult::kError),
                                          Eq("Unspecified error")))
      .Times(1);

  engine->CreateFakeEvent(E_FAIL, MF_CAPTURE_ENGINE_RECORD_STOPPED);

  capture_controller = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
  camera = nullptr;
  record_sink = nullptr;
}

TEST(CaptureController, ReportsStopRecordAccessDeniedEvent) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  int64_t mock_texture_id = 1234;

  // Initialize capture controller to be able to start preview
  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  ComPtr<MockCaptureSource> capture_source = new MockCaptureSource();

  // Prepare fake media types
  MockAvailableMediaTypes(engine.Get(), capture_source.Get(), 1, 1);

  // Start record
  ComPtr<MockCaptureRecordSink> record_sink = new MockCaptureRecordSink();
  std::string mock_path_to_video = "mock_path_to_video";
  MockRecordStart(capture_controller.get(), engine.Get(), record_sink.Get(),
                  camera.get(), mock_path_to_video);

  // Send a stop record failure event
  EXPECT_CALL(*camera, OnStopRecordSucceeded).Times(0);
  EXPECT_CALL(*camera, OnStopRecordFailed(Eq(CameraResult::kAccessDenied),
                                          Eq("Access is denied.")))
      .Times(1);

  engine->CreateFakeEvent(E_ACCESSDENIED, MF_CAPTURE_ENGINE_RECORD_STOPPED);

  capture_controller = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
  camera = nullptr;
  record_sink = nullptr;
}

TEST(CaptureController, TakePictureSuccess) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  int64_t mock_texture_id = 1234;

  // Initialize capture controller to be able to take picture
  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  ComPtr<MockCaptureSource> capture_source = new MockCaptureSource();

  // Prepare fake media types
  MockAvailableMediaTypes(engine.Get(), capture_source.Get(), 1, 1);

  ComPtr<MockCapturePhotoSink> photo_sink = new MockCapturePhotoSink();

  // Initialize photo sink
  MockPhotoSink(engine.Get(), photo_sink.Get());

  // Request photo
  std::string mock_path_to_photo = "mock_path_to_photo";
  EXPECT_CALL(*(engine.Get()), TakePhoto()).Times(1).WillOnce(Return(S_OK));
  capture_controller->TakePicture(mock_path_to_photo);

  // OnTakePictureSucceeded should be called with mocked file path
  EXPECT_CALL(*camera, OnTakePictureSucceeded(Eq(mock_path_to_photo))).Times(1);
  EXPECT_CALL(*camera, OnTakePictureFailed).Times(0);
  engine->CreateFakeEvent(S_OK, MF_CAPTURE_ENGINE_PHOTO_TAKEN);

  capture_controller = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
  camera = nullptr;
  photo_sink = nullptr;
}

TEST(CaptureController, ReportsTakePictureError) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  int64_t mock_texture_id = 1234;

  // Initialize capture controller to be able to take picture
  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  ComPtr<MockCaptureSource> capture_source = new MockCaptureSource();

  // Prepare fake media types
  MockAvailableMediaTypes(engine.Get(), capture_source.Get(), 1, 1);

  ComPtr<MockCapturePhotoSink> photo_sink = new MockCapturePhotoSink();

  // Initialize photo sink
  MockPhotoSink(engine.Get(), photo_sink.Get());

  // Cause take picture to fail
  EXPECT_CALL(*(engine.Get()), TakePhoto).Times(1).WillOnce(Return(E_FAIL));

  EXPECT_CALL(*camera, OnTakePictureSucceeded).Times(0);
  EXPECT_CALL(*camera, OnTakePictureFailed(Eq(CameraResult::kError),
                                           Eq("Failed to take photo")))
      .Times(1);

  capture_controller->TakePicture("mock_path_to_photo");

  capture_controller = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
  camera = nullptr;
  photo_sink = nullptr;
}

TEST(CaptureController, ReportsTakePictureAccessDenied) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  int64_t mock_texture_id = 1234;

  // Initialize capture controller to be able to take picture
  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  ComPtr<MockCaptureSource> capture_source = new MockCaptureSource();

  // Prepare fake media types
  MockAvailableMediaTypes(engine.Get(), capture_source.Get(), 1, 1);

  ComPtr<MockCapturePhotoSink> photo_sink = new MockCapturePhotoSink();

  // Initialize photo sink
  MockPhotoSink(engine.Get(), photo_sink.Get());

  // Cause take picture to fail.
  EXPECT_CALL(*(engine.Get()), TakePhoto)
      .Times(1)
      .WillOnce(Return(E_ACCESSDENIED));

  EXPECT_CALL(*camera, OnTakePictureSucceeded).Times(0);
  EXPECT_CALL(*camera, OnTakePictureFailed(Eq(CameraResult::kAccessDenied),
                                           Eq("Failed to take photo")))
      .Times(1);

  capture_controller->TakePicture("mock_path_to_photo");

  capture_controller = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
  camera = nullptr;
  photo_sink = nullptr;
}

TEST(CaptureController, ReportsPhotoTakenErrorEvent) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  int64_t mock_texture_id = 1234;

  // Initialize capture controller to be able to take picture
  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  ComPtr<MockCaptureSource> capture_source = new MockCaptureSource();

  // Prepare fake media types
  MockAvailableMediaTypes(engine.Get(), capture_source.Get(), 1, 1);

  ComPtr<MockCapturePhotoSink> photo_sink = new MockCapturePhotoSink();

  // Initialize photo sink
  MockPhotoSink(engine.Get(), photo_sink.Get());

  // Request photo
  std::string mock_path_to_photo = "mock_path_to_photo";
  EXPECT_CALL(*(engine.Get()), TakePhoto()).Times(1).WillOnce(Return(S_OK));
  capture_controller->TakePicture(mock_path_to_photo);

  // Send take picture failed event
  EXPECT_CALL(*camera, OnTakePictureSucceeded).Times(0);
  EXPECT_CALL(*camera, OnTakePictureFailed(Eq(CameraResult::kError),
                                           Eq("Unspecified error")))
      .Times(1);

  engine->CreateFakeEvent(E_FAIL, MF_CAPTURE_ENGINE_PHOTO_TAKEN);

  capture_controller = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
  camera = nullptr;
  photo_sink = nullptr;
}

TEST(CaptureController, ReportsPhotoTakenAccessDeniedEvent) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  int64_t mock_texture_id = 1234;

  // Initialize capture controller to be able to take picture
  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  ComPtr<MockCaptureSource> capture_source = new MockCaptureSource();

  // Prepare fake media types
  MockAvailableMediaTypes(engine.Get(), capture_source.Get(), 1, 1);

  ComPtr<MockCapturePhotoSink> photo_sink = new MockCapturePhotoSink();

  // Initialize photo sink
  MockPhotoSink(engine.Get(), photo_sink.Get());

  // Request photo
  std::string mock_path_to_photo = "mock_path_to_photo";
  EXPECT_CALL(*(engine.Get()), TakePhoto()).Times(1).WillOnce(Return(S_OK));
  capture_controller->TakePicture(mock_path_to_photo);

  // Send take picture failed event
  EXPECT_CALL(*camera, OnTakePictureSucceeded).Times(0);
  EXPECT_CALL(*camera, OnTakePictureFailed(Eq(CameraResult::kAccessDenied),
                                           Eq("Access is denied.")))
      .Times(1);

  engine->CreateFakeEvent(E_ACCESSDENIED, MF_CAPTURE_ENGINE_PHOTO_TAKEN);

  capture_controller = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
  camera = nullptr;
  photo_sink = nullptr;
}

TEST(CaptureController, PauseResumePreviewSuccess) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  int64_t mock_texture_id = 1234;

  // Initialize capture controller to be able to start preview
  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  ComPtr<MockCapturePreviewSink> preview_sink = new MockCapturePreviewSink();

  std::unique_ptr<uint8_t[]> mock_source_buffer =
      std::make_unique<uint8_t[]>(0);

  // Start preview to be able to start record
  MockStartPreview(capture_controller.get(), preview_sink.Get(),
                   texture_registrar.get(), engine.Get(), camera.get(),
                   std::move(mock_source_buffer), 0, 1, 1, mock_texture_id);

  EXPECT_CALL(*camera, OnPausePreviewSucceeded()).Times(1);
  capture_controller->PausePreview();

  EXPECT_CALL(*camera, OnResumePreviewSucceeded()).Times(1);
  capture_controller->ResumePreview();

  capture_controller = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
  camera = nullptr;
}

TEST(CaptureController, PausePreviewFailsIfPreviewNotStarted) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();
  int64_t mock_texture_id = 1234;

  // Initialize capture controller to be able to start preview
  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  // Pause preview fails if not started
  EXPECT_CALL(*camera, OnPausePreviewFailed(Eq(CameraResult::kError),
                                            Eq("Preview not started")))
      .Times(1);

  capture_controller->PausePreview();

  capture_controller = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
  camera = nullptr;
}

TEST(CaptureController, ResumePreviewFailsIfPreviewNotStarted) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();
  int64_t mock_texture_id = 1234;

  // Initialize capture controller to be able to start preview
  MockInitCaptureController(capture_controller.get(), texture_registrar.get(),
                            engine.Get(), camera.get(), mock_texture_id);

  // Resume preview fails if not started.
  EXPECT_CALL(*camera, OnResumePreviewFailed(Eq(CameraResult::kError),
                                             Eq("Preview not started")))
      .Times(1);

  capture_controller->ResumePreview();

  capture_controller = nullptr;
  texture_registrar = nullptr;
  engine = nullptr;
  camera = nullptr;
}

}  // namespace test
}  // namespace camera_windows
