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

namespace camera_windows {

namespace test {

using Microsoft::WRL::ComPtr;
using ::testing::_;
using ::testing::Eq;
using ::testing::Return;

void InitCaptureController(CaptureControllerImpl* capture_controller,
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

  capture_controller->InitCaptureDevice(
      texture_registrar, MOCK_DEVICE_ID, true,
      ResolutionPreset::RESOLUTION_PRESET_AUTO);

  // MockCaptureEngine::Initialize is called
  EXPECT_TRUE(engine->initialized_);

  engine->CreateFakeEvent(S_OK, MF_CAPTURE_ENGINE_INITIALIZED);
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

  ComPtr<MockMediaSource> video_source = new MockMediaSource();
  ComPtr<MockMediaSource> audio_source = new MockMediaSource();

  capture_controller->SetCaptureEngine(
      reinterpret_cast<IMFCaptureEngine*>(engine.Get()));
  capture_controller->SetVideoSource(
      reinterpret_cast<IMFMediaSource*>(video_source.Get()));
  capture_controller->SetAudioSource(
      reinterpret_cast<IMFMediaSource*>(audio_source.Get()));

  int64_t mock_texture_id = 1000;

  EXPECT_CALL(*texture_registrar, RegisterTexture)
      .Times(1)
      .WillOnce([reg = texture_registrar.get(),
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
  EXPECT_CALL(*(engine.Get()), Initialize).Times(1);

  capture_controller->InitCaptureDevice(
      texture_registrar.get(), MOCK_DEVICE_ID, true,
      ResolutionPreset::RESOLUTION_PRESET_AUTO);

  // MockCaptureEngine::Initialize is called
  EXPECT_TRUE(engine->initialized_);

  engine->CreateFakeEvent(S_OK, MF_CAPTURE_ENGINE_INITIALIZED);

  capture_controller = nullptr;
  camera = nullptr;
  texture_registrar = nullptr;
  video_source = nullptr;
  audio_source = nullptr;
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

  uint64_t mock_texture_id = 1234;
  // Init capture controller to be ready for testing
  InitCaptureController(capture_controller.get(), texture_registrar.get(),
                        engine.Get(), camera.get(), mock_texture_id);

  ComPtr<MockCapturePreviewSink> preview_sink = new MockCapturePreviewSink();
  ComPtr<MockCaptureSource> capture_source = new MockCaptureSource();

  // Let's keep these small for mock texture data. Two pixels should be enough.
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
  MFVideoFormat_RGB32_Pixel* mock_source_buffer_data =
      (MFVideoFormat_RGB32_Pixel*)mock_source_buffer.get();

  for (uint32_t i = 0; i < pixels_total; i++) {
    mock_source_buffer_data[i].r = mock_red_pixel;
    mock_source_buffer_data[i].g = mock_green_pixel;
    mock_source_buffer_data[i].b = mock_blue_pixel;
  }

  EXPECT_CALL(*(engine.Get()), GetSink(MF_CAPTURE_ENGINE_SINK_TYPE_PREVIEW, _))
      .Times(1)
      .WillOnce(
          [src_sink = preview_sink.Get()](MF_CAPTURE_ENGINE_SINK_TYPE sink_type,
                                          IMFCaptureSink** target_sink) {
            *target_sink = src_sink;
            src_sink->AddRef();
            return S_OK;
          });

  EXPECT_CALL(*(preview_sink.Get()), RemoveAllStreams)
      .Times(1)
      .WillOnce(Return(S_OK));
  EXPECT_CALL(*(preview_sink.Get()), AddStream).Times(1).WillOnce(Return(S_OK));
  EXPECT_CALL(*(preview_sink.Get()), SetSampleCallback)
      .Times(1)
      .WillOnce([sink = preview_sink.Get()](
                    DWORD dwStreamSinkIndex,
                    IMFCaptureEngineOnSampleCallback* pCallback) -> HRESULT {
        sink->sample_callback_ = pCallback;
        return S_OK;
      });

  EXPECT_CALL(*(engine.Get()), GetSource)
      .Times(1)
      .WillOnce([src_source =
                     capture_source.Get()](IMFCaptureSource** target_source) {
        *target_source = src_source;
        src_source->AddRef();
        return S_OK;
      });

  EXPECT_CALL(
      *(capture_source.Get()),
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

  EXPECT_CALL(*(engine.Get()), StartPreview()).Times(1).WillOnce(Return(S_OK));

  // Called by destructor
  EXPECT_CALL(*(engine.Get()), StopPreview()).Times(1).WillOnce(Return(S_OK));

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
                               mock_texture_data_size);

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

        FlutterDesktop_Pixel* converted_buffer_data =
            (FlutterDesktop_Pixel*)(converted_buffer->buffer);

        for (uint32_t i = 0; i < pixels_total; i++) {
          EXPECT_EQ(converted_buffer_data[i].r, mock_red_pixel);
          EXPECT_EQ(converted_buffer_data[i].g, mock_green_pixel);
          EXPECT_EQ(converted_buffer_data[i].b, mock_blue_pixel);
        }
      }
      converted_buffer = nullptr;
    }
    pixel_buffer_texture = nullptr;
  }

  capture_controller = nullptr;
  engine = nullptr;
  camera = nullptr;
  texture_registrar = nullptr;
  mock_source_buffer = nullptr;
}

}  // namespace test
}  // namespace camera_windows
