// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <flutter/method_call.h>
#include <flutter/method_result_functions.h>
#include <flutter/standard_method_codec.h>
#include <flutter/texture_registrar.h>
#include <gmock/gmock.h>
#include <gtest/gtest.h>
#include <windows.h>

#include <functional>
#include <memory>
#include <string>

#include "mocks.h"

namespace camera_windows {
namespace test {

TEST(Camera, InitCameraCreatesCaptureController) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockCaptureControllerFactory> capture_controller_factory =
      std::make_unique<MockCaptureControllerFactory>();

  EXPECT_CALL(*capture_controller_factory, CreateCaptureController)
      .Times(1)
      .WillOnce(
          []() { return std::make_unique<NiceMock<MockCaptureController>>(); });

  EXPECT_TRUE(camera->GetCaptureController() == nullptr);

  // Init camera with mock capture controller factory
  camera->InitCamera(std::move(capture_controller_factory),
                     std::make_unique<MockTextureRegistrar>().get(),
                     std::make_unique<MockBinaryMessenger>().get(), false,
                     ResolutionPreset::RESOLUTION_PRESET_AUTO);

  EXPECT_TRUE(camera->GetCaptureController() != nullptr);
}

TEST(Camera, AddPendingResultReturnsErrorForDuplicates) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> first_pending_result =
      std::make_unique<MockMethodResult>();
  std::unique_ptr<MockMethodResult> second_pending_result =
      std::make_unique<MockMethodResult>();

  EXPECT_CALL(*first_pending_result, ErrorInternal).Times(0);
  EXPECT_CALL(*first_pending_result, SuccessInternal);
  EXPECT_CALL(*second_pending_result, ErrorInternal).Times(1);

  camera->AddPendingResult(PendingResultType::CREATE_CAMERA,
                           std::move(first_pending_result));

  // This should fail
  camera->AddPendingResult(PendingResultType::CREATE_CAMERA,
                           std::move(second_pending_result));

  // Mark pending result as succeeded
  camera->OnCreateCaptureEngineSucceeded(0);
}

TEST(Camera, OnCreateCaptureEngineSucceededReturnsCameraId) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  const int64_t texture_id = 12345;

  EXPECT_CALL(*result, ErrorInternal).Times(0);
  EXPECT_CALL(
      *result,
      SuccessInternal(Pointee(EncodableValue(EncodableMap(
          {{EncodableValue("cameraId"), EncodableValue(texture_id)}})))));

  camera->AddPendingResult(PendingResultType::CREATE_CAMERA, std::move(result));

  camera->OnCreateCaptureEngineSucceeded(texture_id);
}

TEST(Camera, OnCreateCaptureEngineFailedReturnsError) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  std::string error_text = "error_text";

  EXPECT_CALL(*result, SuccessInternal).Times(0);
  EXPECT_CALL(*result, ErrorInternal(_, Eq(error_text), _));

  camera->AddPendingResult(PendingResultType::CREATE_CAMERA, std::move(result));

  camera->OnCreateCaptureEngineFailed(error_text);
}

TEST(Camera, OnStartPreviewSucceededReturnsFrameSize) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  const int32_t width = 123;
  const int32_t height = 456;

  EXPECT_CALL(*result, ErrorInternal).Times(0);
  EXPECT_CALL(
      *result,
      SuccessInternal(Pointee(EncodableValue(EncodableMap({
          {EncodableValue("previewWidth"), EncodableValue((float)width)},
          {EncodableValue("previewHeight"), EncodableValue((float)height)},
      })))));

  camera->AddPendingResult(PendingResultType::INITIALIZE, std::move(result));

  camera->OnStartPreviewSucceeded(width, height);
}

TEST(Camera, OnStartPreviewFailedReturnsError) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  std::string error_text = "error_text";

  EXPECT_CALL(*result, SuccessInternal).Times(0);
  EXPECT_CALL(*result, ErrorInternal(_, Eq(error_text), _));

  camera->AddPendingResult(PendingResultType::INITIALIZE, std::move(result));

  camera->OnStartPreviewFailed(error_text);
}

TEST(Camera, OnPausePreviewSucceededReturnsSuccess) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  EXPECT_CALL(*result, ErrorInternal).Times(0);
  EXPECT_CALL(*result, SuccessInternal(nullptr));

  camera->AddPendingResult(PendingResultType::PAUSE_PREVIEW, std::move(result));

  camera->OnPausePreviewSucceeded();
}

TEST(Camera, OnPausePreviewFailedReturnsError) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  std::string error_text = "error_text";

  EXPECT_CALL(*result, SuccessInternal).Times(0);
  EXPECT_CALL(*result, ErrorInternal(_, Eq(error_text), _));

  camera->AddPendingResult(PendingResultType::PAUSE_PREVIEW, std::move(result));

  camera->OnPausePreviewFailed(error_text);
}

TEST(Camera, OnResumePreviewSucceededReturnsSuccess) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  EXPECT_CALL(*result, ErrorInternal).Times(0);
  EXPECT_CALL(*result, SuccessInternal(nullptr));

  camera->AddPendingResult(PendingResultType::RESUME_PREVIEW,
                           std::move(result));

  camera->OnResumePreviewSucceeded();
}

TEST(Camera, OnResumePreviewFailedReturnsError) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  std::string error_text = "error_text";

  EXPECT_CALL(*result, SuccessInternal).Times(0);
  EXPECT_CALL(*result, ErrorInternal(_, Eq(error_text), _));

  camera->AddPendingResult(PendingResultType::RESUME_PREVIEW,
                           std::move(result));

  camera->OnResumePreviewFailed(error_text);
}

TEST(Camera, OnStartRecordSucceededReturnsSuccess) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  EXPECT_CALL(*result, ErrorInternal).Times(0);
  EXPECT_CALL(*result, SuccessInternal(nullptr));

  camera->AddPendingResult(PendingResultType::START_RECORD, std::move(result));

  camera->OnStartRecordSucceeded();
}

TEST(Camera, OnStartRecordFailedReturnsError) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  std::string error_text = "error_text";

  EXPECT_CALL(*result, SuccessInternal).Times(0);
  EXPECT_CALL(*result, ErrorInternal(_, Eq(error_text), _));

  camera->AddPendingResult(PendingResultType::START_RECORD, std::move(result));

  camera->OnStartRecordFailed(error_text);
}

TEST(Camera, OnStopRecordSucceededReturnsSuccess) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  std::string filepath = "C:\temp\filename.mp4";

  EXPECT_CALL(*result, ErrorInternal).Times(0);
  EXPECT_CALL(*result, SuccessInternal(Pointee(EncodableValue(filepath))));

  camera->AddPendingResult(PendingResultType::STOP_RECORD, std::move(result));

  camera->OnStopRecordSucceeded(filepath);
}

TEST(Camera, OnStopRecordFailedReturnsError) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  std::string error_text = "error_text";

  EXPECT_CALL(*result, SuccessInternal).Times(0);
  EXPECT_CALL(*result, ErrorInternal(_, Eq(error_text), _));

  camera->AddPendingResult(PendingResultType::STOP_RECORD, std::move(result));

  camera->OnStopRecordFailed(error_text);
}

TEST(Camera, OnPictureSuccessReturnsSuccess) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  std::string filepath = "C:\temp\filename.jpeg";

  EXPECT_CALL(*result, ErrorInternal).Times(0);
  EXPECT_CALL(*result, SuccessInternal(Pointee(EncodableValue(filepath))));

  camera->AddPendingResult(PendingResultType::TAKE_PICTURE, std::move(result));

  camera->OnPictureSuccess(filepath);
}

TEST(Camera, OnPictureFailedReturnsError) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  std::string error_text = "error_text";

  EXPECT_CALL(*result, SuccessInternal).Times(0);
  EXPECT_CALL(*result, ErrorInternal(_, Eq(error_text), _));

  camera->AddPendingResult(PendingResultType::TAKE_PICTURE, std::move(result));

  camera->OnPictureFailed(error_text);
}

TEST(Camera, OnVideoRecordedSuccessInvokesCameraChannelEvent) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockCaptureControllerFactory> capture_controller_factory =
      std::make_unique<MockCaptureControllerFactory>();

  std::unique_ptr<MockBinaryMessenger> binary_messenger =
      std::make_unique<MockBinaryMessenger>();

  std::string filepath = "C:\temp\filename.mp4";
  int64_t camera_id = 12345;
  std::string camera_channel =
      std::string("flutter.io/cameraPlugin/camera") + std::to_string(camera_id);
  int64_t video_duration = 1000000;

  EXPECT_CALL(*capture_controller_factory, CreateCaptureController)
      .Times(1)
      .WillOnce(
          []() { return std::make_unique<NiceMock<MockCaptureController>>(); });

  // TODO: test binary content
  EXPECT_CALL(*binary_messenger, Send(Eq(camera_channel), _, _, _)).Times(1);

  // Init camera with mock capture controller factory
  camera->InitCamera(std::move(capture_controller_factory),
                     std::make_unique<MockTextureRegistrar>().get(),
                     binary_messenger.get(), false,
                     ResolutionPreset::RESOLUTION_PRESET_AUTO);

  // Pass camera id for camera
  camera->OnCreateCaptureEngineSucceeded(camera_id);

  camera->OnVideoRecordedSuccess(filepath, video_duration);
}

}  // namespace test
}  // namespace camera_windows
