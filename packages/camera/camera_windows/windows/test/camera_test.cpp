// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "camera.h"

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
using ::testing::_;
using ::testing::Eq;
using ::testing::NiceMock;
using ::testing::Pointee;
using ::testing::Return;

namespace test {

TEST(Camera, InitCameraCreatesCaptureController) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockCaptureControllerFactory> capture_controller_factory =
      std::make_unique<MockCaptureControllerFactory>();

  EXPECT_CALL(*capture_controller_factory, CreateCaptureController)
      .Times(1)
      .WillOnce([]() {
        std::unique_ptr<NiceMock<MockCaptureController>> capture_controller =
            std::make_unique<NiceMock<MockCaptureController>>();

        EXPECT_CALL(*capture_controller, InitCaptureDevice)
            .Times(1)
            .WillOnce(Return(true));

        return capture_controller;
      });

  EXPECT_TRUE(camera->GetCaptureController() == nullptr);

  // Init camera with mock capture controller factory
  bool result =
      camera->InitCamera(std::move(capture_controller_factory),
                         std::make_unique<MockTextureRegistrar>().get(),
                         std::make_unique<MockBinaryMessenger>().get(), false,
                         ResolutionPreset::kAuto);
  EXPECT_TRUE(result);
  EXPECT_TRUE(camera->GetCaptureController() != nullptr);
}

TEST(Camera, InitCameraReportsFailure) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockCaptureControllerFactory> capture_controller_factory =
      std::make_unique<MockCaptureControllerFactory>();

  EXPECT_CALL(*capture_controller_factory, CreateCaptureController)
      .Times(1)
      .WillOnce([]() {
        std::unique_ptr<NiceMock<MockCaptureController>> capture_controller =
            std::make_unique<NiceMock<MockCaptureController>>();

        EXPECT_CALL(*capture_controller, InitCaptureDevice)
            .Times(1)
            .WillOnce(Return(false));

        return capture_controller;
      });

  EXPECT_TRUE(camera->GetCaptureController() == nullptr);

  // Init camera with mock capture controller factory
  bool result =
      camera->InitCamera(std::move(capture_controller_factory),
                         std::make_unique<MockTextureRegistrar>().get(),
                         std::make_unique<MockBinaryMessenger>().get(), false,
                         ResolutionPreset::kAuto);
  EXPECT_FALSE(result);
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

  camera->AddPendingResult(PendingResultType::kCreateCamera,
                           std::move(first_pending_result));

  // This should fail
  camera->AddPendingResult(PendingResultType::kCreateCamera,
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

  camera->AddPendingResult(PendingResultType::kCreateCamera, std::move(result));

  camera->OnCreateCaptureEngineSucceeded(texture_id);
}

TEST(Camera, CreateCaptureEngineReportsError) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  const std::string error_text = "error_text";

  EXPECT_CALL(*result, SuccessInternal).Times(0);
  EXPECT_CALL(*result, ErrorInternal(Eq("camera_error"), Eq(error_text), _));

  camera->AddPendingResult(PendingResultType::kCreateCamera, std::move(result));

  camera->OnCreateCaptureEngineFailed(CameraResult::kError, error_text);
}

TEST(Camera, CreateCaptureEngineReportsAccessDenied) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  const std::string error_text = "error_text";

  EXPECT_CALL(*result, SuccessInternal).Times(0);
  EXPECT_CALL(*result,
              ErrorInternal(Eq("CameraAccessDenied"), Eq(error_text), _));

  camera->AddPendingResult(PendingResultType::kCreateCamera, std::move(result));

  camera->OnCreateCaptureEngineFailed(CameraResult::kAccessDenied, error_text);
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

  camera->AddPendingResult(PendingResultType::kInitialize, std::move(result));

  camera->OnStartPreviewSucceeded(width, height);
}

TEST(Camera, StartPreviewReportsError) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  const std::string error_text = "error_text";

  EXPECT_CALL(*result, SuccessInternal).Times(0);
  EXPECT_CALL(*result, ErrorInternal(Eq("camera_error"), Eq(error_text), _));

  camera->AddPendingResult(PendingResultType::kInitialize, std::move(result));

  camera->OnStartPreviewFailed(CameraResult::kError, error_text);
}

TEST(Camera, StartPreviewReportsAccessDenied) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  const std::string error_text = "error_text";

  EXPECT_CALL(*result, SuccessInternal).Times(0);
  EXPECT_CALL(*result,
              ErrorInternal(Eq("CameraAccessDenied"), Eq(error_text), _));

  camera->AddPendingResult(PendingResultType::kInitialize, std::move(result));

  camera->OnStartPreviewFailed(CameraResult::kAccessDenied, error_text);
}

TEST(Camera, OnPausePreviewSucceededReturnsSuccess) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  EXPECT_CALL(*result, ErrorInternal).Times(0);
  EXPECT_CALL(*result, SuccessInternal(nullptr));

  camera->AddPendingResult(PendingResultType::kPausePreview, std::move(result));

  camera->OnPausePreviewSucceeded();
}

TEST(Camera, PausePreviewReportsError) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  const std::string error_text = "error_text";

  EXPECT_CALL(*result, SuccessInternal).Times(0);
  EXPECT_CALL(*result, ErrorInternal(Eq("camera_error"), Eq(error_text), _));

  camera->AddPendingResult(PendingResultType::kPausePreview, std::move(result));

  camera->OnPausePreviewFailed(CameraResult::kError, error_text);
}

TEST(Camera, PausePreviewReportsAccessDenied) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  const std::string error_text = "error_text";

  EXPECT_CALL(*result, SuccessInternal).Times(0);
  EXPECT_CALL(*result,
              ErrorInternal(Eq("CameraAccessDenied"), Eq(error_text), _));

  camera->AddPendingResult(PendingResultType::kPausePreview, std::move(result));

  camera->OnPausePreviewFailed(CameraResult::kAccessDenied, error_text);
}

TEST(Camera, OnResumePreviewSucceededReturnsSuccess) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  EXPECT_CALL(*result, ErrorInternal).Times(0);
  EXPECT_CALL(*result, SuccessInternal(nullptr));

  camera->AddPendingResult(PendingResultType::kResumePreview,
                           std::move(result));

  camera->OnResumePreviewSucceeded();
}

TEST(Camera, ResumePreviewReportsError) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  const std::string error_text = "error_text";

  EXPECT_CALL(*result, SuccessInternal).Times(0);
  EXPECT_CALL(*result, ErrorInternal(Eq("camera_error"), Eq(error_text), _));

  camera->AddPendingResult(PendingResultType::kResumePreview,
                           std::move(result));

  camera->OnResumePreviewFailed(CameraResult::kError, error_text);
}

TEST(Camera, OnResumePreviewPermissionFailureReturnsError) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  const std::string error_text = "error_text";

  EXPECT_CALL(*result, SuccessInternal).Times(0);
  EXPECT_CALL(*result,
              ErrorInternal(Eq("CameraAccessDenied"), Eq(error_text), _));

  camera->AddPendingResult(PendingResultType::kResumePreview,
                           std::move(result));

  camera->OnResumePreviewFailed(CameraResult::kAccessDenied, error_text);
}

TEST(Camera, OnStartRecordSucceededReturnsSuccess) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  EXPECT_CALL(*result, ErrorInternal).Times(0);
  EXPECT_CALL(*result, SuccessInternal(nullptr));

  camera->AddPendingResult(PendingResultType::kStartRecord, std::move(result));

  camera->OnStartRecordSucceeded();
}

TEST(Camera, StartRecordReportsError) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  const std::string error_text = "error_text";

  EXPECT_CALL(*result, SuccessInternal).Times(0);
  EXPECT_CALL(*result, ErrorInternal(Eq("camera_error"), Eq(error_text), _));

  camera->AddPendingResult(PendingResultType::kStartRecord, std::move(result));

  camera->OnStartRecordFailed(CameraResult::kError, error_text);
}

TEST(Camera, StartRecordReportsAccessDenied) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  const std::string error_text = "error_text";

  EXPECT_CALL(*result, SuccessInternal).Times(0);
  EXPECT_CALL(*result,
              ErrorInternal(Eq("CameraAccessDenied"), Eq(error_text), _));

  camera->AddPendingResult(PendingResultType::kStartRecord, std::move(result));

  camera->OnStartRecordFailed(CameraResult::kAccessDenied, error_text);
}

TEST(Camera, OnStopRecordSucceededReturnsSuccess) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  const std::string file_path = "C:\temp\filename.mp4";

  EXPECT_CALL(*result, ErrorInternal).Times(0);
  EXPECT_CALL(*result, SuccessInternal(Pointee(EncodableValue(file_path))));

  camera->AddPendingResult(PendingResultType::kStopRecord, std::move(result));

  camera->OnStopRecordSucceeded(file_path);
}

TEST(Camera, StopRecordReportsError) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  const std::string error_text = "error_text";

  EXPECT_CALL(*result, SuccessInternal).Times(0);
  EXPECT_CALL(*result, ErrorInternal(Eq("camera_error"), Eq(error_text), _));

  camera->AddPendingResult(PendingResultType::kStopRecord, std::move(result));

  camera->OnStopRecordFailed(CameraResult::kError, error_text);
}

TEST(Camera, StopRecordReportsAccessDenied) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  const std::string error_text = "error_text";

  EXPECT_CALL(*result, SuccessInternal).Times(0);
  EXPECT_CALL(*result,
              ErrorInternal(Eq("CameraAccessDenied"), Eq(error_text), _));

  camera->AddPendingResult(PendingResultType::kStopRecord, std::move(result));

  camera->OnStopRecordFailed(CameraResult::kAccessDenied, error_text);
}

TEST(Camera, OnTakePictureSucceededReturnsSuccess) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  const std::string file_path = "C:\\temp\\filename.jpeg";

  EXPECT_CALL(*result, ErrorInternal).Times(0);
  EXPECT_CALL(*result, SuccessInternal(Pointee(EncodableValue(file_path))));

  camera->AddPendingResult(PendingResultType::kTakePicture, std::move(result));

  camera->OnTakePictureSucceeded(file_path);
}

TEST(Camera, TakePictureReportsError) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  const std::string error_text = "error_text";

  EXPECT_CALL(*result, SuccessInternal).Times(0);
  EXPECT_CALL(*result, ErrorInternal(Eq("camera_error"), Eq(error_text), _));

  camera->AddPendingResult(PendingResultType::kTakePicture, std::move(result));

  camera->OnTakePictureFailed(CameraResult::kError, error_text);
}

TEST(Camera, TakePictureReportsAccessDenied) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  const std::string error_text = "error_text";

  EXPECT_CALL(*result, SuccessInternal).Times(0);
  EXPECT_CALL(*result,
              ErrorInternal(Eq("CameraAccessDenied"), Eq(error_text), _));

  camera->AddPendingResult(PendingResultType::kTakePicture, std::move(result));

  camera->OnTakePictureFailed(CameraResult::kAccessDenied, error_text);
}

TEST(Camera, OnVideoRecordSucceededInvokesCameraChannelEvent) {
  std::unique_ptr<CameraImpl> camera =
      std::make_unique<CameraImpl>(MOCK_DEVICE_ID);
  std::unique_ptr<MockCaptureControllerFactory> capture_controller_factory =
      std::make_unique<MockCaptureControllerFactory>();

  std::unique_ptr<MockBinaryMessenger> binary_messenger =
      std::make_unique<MockBinaryMessenger>();

  const std::string file_path = "C:\\temp\\filename.mp4";
  const int64_t camera_id = 12345;
  std::string camera_channel =
      std::string("plugins.flutter.io/camera_windows/camera") +
      std::to_string(camera_id);
  const int64_t video_duration = 1000000;

  EXPECT_CALL(*capture_controller_factory, CreateCaptureController)
      .Times(1)
      .WillOnce(
          []() { return std::make_unique<NiceMock<MockCaptureController>>(); });

  // TODO: test binary content.
  // First time is video record success message,
  // and second is camera closing message.
  EXPECT_CALL(*binary_messenger, Send(Eq(camera_channel), _, _, _)).Times(2);

  // Init camera with mock capture controller factory
  camera->InitCamera(std::move(capture_controller_factory),
                     std::make_unique<MockTextureRegistrar>().get(),
                     binary_messenger.get(), false, ResolutionPreset::kAuto);

  // Pass camera id for camera
  camera->OnCreateCaptureEngineSucceeded(camera_id);

  camera->OnVideoRecordSucceeded(file_path, video_duration);

  // Dispose camera before message channel.
  camera = nullptr;
}

}  // namespace test
}  // namespace camera_windows
