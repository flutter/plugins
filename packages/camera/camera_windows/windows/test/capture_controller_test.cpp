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
using ::testing::Eq;

TEST(CaptureController,
     InitCaptureEngineCallsCaptureControllerListenerWithTextureId) {
  ComPtr<MockCaptureEngine> engine = new MockCaptureEngine();
  std::unique_ptr<MockCamera> camera =
      std::make_unique<MockCamera>(MOCK_DEVICE_ID);
  std::unique_ptr<CaptureControllerImpl> capture_controller =
      std::make_unique<CaptureControllerImpl>(camera.get());
  std::unique_ptr<MockTextureRegistrar> texture_registrar =
      std::make_unique<MockTextureRegistrar>();

  ComPtr<FakeMediaSource> video_source = new FakeMediaSource();
  ComPtr<FakeMediaSource> audio_source = new FakeMediaSource();

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
        reg->texture_id = mock_texture_id;
        return reg->texture_id;
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

}  // namespace test
}  // namespace camera_windows
