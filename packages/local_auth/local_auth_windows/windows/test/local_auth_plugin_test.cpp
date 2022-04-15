// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "local_auth_plugin.h"

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

namespace local_auth_windows {
namespace test {

using flutter::EncodableMap;
using flutter::EncodableValue;
using ::testing::_;
using ::testing::DoAll;
using ::testing::EndsWith;
using ::testing::Eq;
using ::testing::Pointee;
using ::testing::Return;

TEST(LocalAuthPlugin, AvailableLocalAuthsHandlerSuccessIfNoLocalAuths) {
  std::unique_ptr<MockTextureRegistrar> texture_registrar_ =
      std::make_unique<MockTextureRegistrar>();
  std::unique_ptr<MockBinaryMessenger> messenger_ =
      std::make_unique<MockBinaryMessenger>();
  std::unique_ptr<MockLocalAuthFactory> local_auth_factory_ =
      std::make_unique<MockLocalAuthFactory>();
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  MockLocalAuthPlugin plugin(texture_registrar_.get(), messenger_.get(),
                          std::move(local_auth_factory_));

  EXPECT_CALL(plugin, EnumerateVideoCaptureDeviceSources)
      .Times(1)
      .WillOnce([](IMFActivate*** devices, UINT32* count) {
        *count = 0U;
        *devices = static_cast<IMFActivate**>(
            CoTaskMemAlloc(sizeof(IMFActivate*) * (*count)));
        return true;
      });

  EXPECT_CALL(*result, ErrorInternal).Times(0);
  EXPECT_CALL(*result, SuccessInternal).Times(1);

  plugin.HandleMethodCall(
      flutter::MethodCall("availableLocalAuths",
                          std::make_unique<EncodableValue>()),
      std::move(result));
}

TEST(LocalAuthPlugin, AvailableLocalAuthsHandlerErrorIfFailsToEnumerateDevices) {
  std::unique_ptr<MockTextureRegistrar> texture_registrar_ =
      std::make_unique<MockTextureRegistrar>();
  std::unique_ptr<MockBinaryMessenger> messenger_ =
      std::make_unique<MockBinaryMessenger>();
  std::unique_ptr<MockLocalAuthFactory> local_auth_factory_ =
      std::make_unique<MockLocalAuthFactory>();
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  MockLocalAuthPlugin plugin(texture_registrar_.get(), messenger_.get(),
                          std::move(local_auth_factory_));

  EXPECT_CALL(plugin, EnumerateVideoCaptureDeviceSources)
      .Times(1)
      .WillOnce([](IMFActivate*** devices, UINT32* count) { return false; });

  EXPECT_CALL(*result, ErrorInternal).Times(1);
  EXPECT_CALL(*result, SuccessInternal).Times(0);

  plugin.HandleMethodCall(
      flutter::MethodCall("availableLocalAuths",
                          std::make_unique<EncodableValue>()),
      std::move(result));
}

TEST(LocalAuthPlugin, CreateHandlerCallsInitLocalAuth) {
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();
  std::unique_ptr<MockTextureRegistrar> texture_registrar_ =
      std::make_unique<MockTextureRegistrar>();
  std::unique_ptr<MockBinaryMessenger> messenger_ =
      std::make_unique<MockBinaryMessenger>();
  std::unique_ptr<MockLocalAuthFactory> local_auth_factory_ =
      std::make_unique<MockLocalAuthFactory>();
  std::unique_ptr<MockLocalAuth> local_auth =
      std::make_unique<MockLocalAuth>(MOCK_DEVICE_ID);

  EXPECT_CALL(*local_auth,
              HasPendingResultByType(Eq(PendingResultType::kCreateLocalAuth)))
      .Times(1)
      .WillOnce(Return(false));

  EXPECT_CALL(*local_auth,
              AddPendingResult(Eq(PendingResultType::kCreateLocalAuth), _))
      .Times(1)
      .WillOnce([cam = local_auth.get()](PendingResultType type,
                                     std::unique_ptr<MethodResult<>> result) {
        cam->pending_result_ = std::move(result);
        return true;
      });
  EXPECT_CALL(*local_auth, InitLocalAuth)
      .Times(1)
      .WillOnce([cam = local_auth.get()](
                    flutter::TextureRegistrar* texture_registrar,
                    flutter::BinaryMessenger* messenger, bool record_audio,
                    ResolutionPreset resolution_preset) {
        assert(cam->pending_result_);
        return cam->pending_result_->Success(EncodableValue(1));
      });

  // Move mocked local_auth to the factory to be passed
  // for plugin with CreateLocalAuth function.
  local_auth_factory_->pending_local_auth_ = std::move(local_auth);

  EXPECT_CALL(*local_auth_factory_, CreateLocalAuth(MOCK_DEVICE_ID));

  EXPECT_CALL(*result, ErrorInternal).Times(0);
  EXPECT_CALL(*result, SuccessInternal(Pointee(EncodableValue(1))));

  LocalAuthPlugin plugin(texture_registrar_.get(), messenger_.get(),
                      std::move(local_auth_factory_));
  EncodableMap args = {
      {EncodableValue("local_authName"), EncodableValue(MOCK_CAMERA_NAME)},
      {EncodableValue("resolutionPreset"), EncodableValue(nullptr)},
      {EncodableValue("enableAudio"), EncodableValue(true)},
  };

  plugin.HandleMethodCall(
      flutter::MethodCall("create",
                          std::make_unique<EncodableValue>(EncodableMap(args))),
      std::move(result));
}

TEST(LocalAuthPlugin, CreateHandlerErrorOnInvalidDeviceId) {
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();
  std::unique_ptr<MockTextureRegistrar> texture_registrar_ =
      std::make_unique<MockTextureRegistrar>();
  std::unique_ptr<MockBinaryMessenger> messenger_ =
      std::make_unique<MockBinaryMessenger>();
  std::unique_ptr<MockLocalAuthFactory> local_auth_factory_ =
      std::make_unique<MockLocalAuthFactory>();

  LocalAuthPlugin plugin(texture_registrar_.get(), messenger_.get(),
                      std::move(local_auth_factory_));
  EncodableMap args = {
      {EncodableValue("local_authName"), EncodableValue(MOCK_INVALID_CAMERA_NAME)},
      {EncodableValue("resolutionPreset"), EncodableValue(nullptr)},
      {EncodableValue("enableAudio"), EncodableValue(true)},
  };

  EXPECT_CALL(*result, ErrorInternal).Times(1);

  plugin.HandleMethodCall(
      flutter::MethodCall("create",
                          std::make_unique<EncodableValue>(EncodableMap(args))),
      std::move(result));
}

TEST(LocalAuthPlugin, CreateHandlerErrorOnExistingDeviceId) {
  std::unique_ptr<MockMethodResult> first_create_result =
      std::make_unique<MockMethodResult>();
  std::unique_ptr<MockMethodResult> second_create_result =
      std::make_unique<MockMethodResult>();
  std::unique_ptr<MockTextureRegistrar> texture_registrar_ =
      std::make_unique<MockTextureRegistrar>();
  std::unique_ptr<MockBinaryMessenger> messenger_ =
      std::make_unique<MockBinaryMessenger>();
  std::unique_ptr<MockLocalAuthFactory> local_auth_factory_ =
      std::make_unique<MockLocalAuthFactory>();
  std::unique_ptr<MockLocalAuth> local_auth =
      std::make_unique<MockLocalAuth>(MOCK_DEVICE_ID);

  EXPECT_CALL(*local_auth,
              HasPendingResultByType(Eq(PendingResultType::kCreateLocalAuth)))
      .Times(1)
      .WillOnce(Return(false));

  EXPECT_CALL(*local_auth,
              AddPendingResult(Eq(PendingResultType::kCreateLocalAuth), _))
      .Times(1)
      .WillOnce([cam = local_auth.get()](PendingResultType type,
                                     std::unique_ptr<MethodResult<>> result) {
        cam->pending_result_ = std::move(result);
        return true;
      });
  EXPECT_CALL(*local_auth, InitLocalAuth)
      .Times(1)
      .WillOnce([cam = local_auth.get()](
                    flutter::TextureRegistrar* texture_registrar,
                    flutter::BinaryMessenger* messenger, bool record_audio,
                    ResolutionPreset resolution_preset) {
        assert(cam->pending_result_);
        return cam->pending_result_->Success(EncodableValue(1));
      });

  EXPECT_CALL(*local_auth, HasDeviceId(Eq(MOCK_DEVICE_ID)))
      .Times(1)
      .WillOnce([cam = local_auth.get()](std::string& device_id) {
        return cam->device_id_ == device_id;
      });

  // Move mocked local_auth to the factory to be passed
  // for plugin with CreateLocalAuth function.
  local_auth_factory_->pending_local_auth_ = std::move(local_auth);

  EXPECT_CALL(*local_auth_factory_, CreateLocalAuth(MOCK_DEVICE_ID));

  EXPECT_CALL(*first_create_result, ErrorInternal).Times(0);
  EXPECT_CALL(*first_create_result,
              SuccessInternal(Pointee(EncodableValue(1))));

  LocalAuthPlugin plugin(texture_registrar_.get(), messenger_.get(),
                      std::move(local_auth_factory_));
  EncodableMap args = {
      {EncodableValue("local_authName"), EncodableValue(MOCK_CAMERA_NAME)},
      {EncodableValue("resolutionPreset"), EncodableValue(nullptr)},
      {EncodableValue("enableAudio"), EncodableValue(true)},
  };

  plugin.HandleMethodCall(
      flutter::MethodCall("create",
                          std::make_unique<EncodableValue>(EncodableMap(args))),
      std::move(first_create_result));

  EXPECT_CALL(*second_create_result, ErrorInternal).Times(1);
  EXPECT_CALL(*second_create_result, SuccessInternal).Times(0);

  plugin.HandleMethodCall(
      flutter::MethodCall("create",
                          std::make_unique<EncodableValue>(EncodableMap(args))),
      std::move(second_create_result));
}

TEST(LocalAuthPlugin, InitializeHandlerCallStartPreview) {
  int64_t mock_local_auth_id = 1234;

  std::unique_ptr<MockMethodResult> initialize_result =
      std::make_unique<MockMethodResult>();

  std::unique_ptr<MockLocalAuth> local_auth =
      std::make_unique<MockLocalAuth>(MOCK_DEVICE_ID);

  std::unique_ptr<MockCaptureController> capture_controller =
      std::make_unique<MockCaptureController>();

  EXPECT_CALL(*local_auth, HasLocalAuthId(Eq(mock_local_auth_id)))
      .Times(1)
      .WillOnce([cam = local_auth.get()](int64_t local_auth_id) {
        return cam->local_auth_id_ == local_auth_id;
      });

  EXPECT_CALL(*local_auth,
              HasPendingResultByType(Eq(PendingResultType::kInitialize)))
      .Times(1)
      .WillOnce(Return(false));

  EXPECT_CALL(*local_auth, AddPendingResult(Eq(PendingResultType::kInitialize), _))
      .Times(1)
      .WillOnce([cam = local_auth.get()](PendingResultType type,
                                     std::unique_ptr<MethodResult<>> result) {
        cam->pending_result_ = std::move(result);
        return true;
      });

  EXPECT_CALL(*local_auth, GetCaptureController)
      .Times(1)
      .WillOnce([cam = local_auth.get()]() {
        assert(cam->pending_result_);
        return cam->capture_controller_.get();
      });

  EXPECT_CALL(*capture_controller, StartPreview())
      .Times(1)
      .WillOnce([cam = local_auth.get()]() {
        assert(cam->pending_result_);
        return cam->pending_result_->Success();
      });

  local_auth->local_auth_id_ = mock_local_auth_id;
  local_auth->capture_controller_ = std::move(capture_controller);

  MockLocalAuthPlugin plugin(std::make_unique<MockTextureRegistrar>().get(),
                          std::make_unique<MockBinaryMessenger>().get(),
                          std::make_unique<MockLocalAuthFactory>());

  // Add mocked local_auth to plugins local_auth list.
  plugin.AddLocalAuth(std::move(local_auth));

  EXPECT_CALL(*initialize_result, ErrorInternal).Times(0);
  EXPECT_CALL(*initialize_result, SuccessInternal).Times(1);

  EncodableMap args = {
      {EncodableValue("local_authId"), EncodableValue(mock_local_auth_id)},
  };

  plugin.HandleMethodCall(
      flutter::MethodCall("initialize",
                          std::make_unique<EncodableValue>(EncodableMap(args))),
      std::move(initialize_result));
}

TEST(LocalAuthPlugin, InitializeHandlerErrorOnInvalidLocalAuthId) {
  int64_t mock_local_auth_id = 1234;
  int64_t missing_local_auth_id = 5678;

  std::unique_ptr<MockMethodResult> initialize_result =
      std::make_unique<MockMethodResult>();

  std::unique_ptr<MockLocalAuth> local_auth =
      std::make_unique<MockLocalAuth>(MOCK_DEVICE_ID);

  std::unique_ptr<MockCaptureController> capture_controller =
      std::make_unique<MockCaptureController>();

  EXPECT_CALL(*local_auth, HasLocalAuthId)
      .Times(1)
      .WillOnce([cam = local_auth.get()](int64_t local_auth_id) {
        return cam->local_auth_id_ == local_auth_id;
      });

  EXPECT_CALL(*local_auth, HasPendingResultByType).Times(0);
  EXPECT_CALL(*local_auth, AddPendingResult).Times(0);
  EXPECT_CALL(*local_auth, GetCaptureController).Times(0);
  EXPECT_CALL(*capture_controller, StartPreview).Times(0);

  local_auth->local_auth_id_ = mock_local_auth_id;

  MockLocalAuthPlugin plugin(std::make_unique<MockTextureRegistrar>().get(),
                          std::make_unique<MockBinaryMessenger>().get(),
                          std::make_unique<MockLocalAuthFactory>());

  // Add mocked local_auth to plugins local_auth list.
  plugin.AddLocalAuth(std::move(local_auth));

  EXPECT_CALL(*initialize_result, ErrorInternal).Times(1);
  EXPECT_CALL(*initialize_result, SuccessInternal).Times(0);

  EncodableMap args = {
      {EncodableValue("local_authId"), EncodableValue(missing_local_auth_id)},
  };

  plugin.HandleMethodCall(
      flutter::MethodCall("initialize",
                          std::make_unique<EncodableValue>(EncodableMap(args))),
      std::move(initialize_result));
}

TEST(LocalAuthPlugin, TakePictureHandlerCallsTakePictureWithPath) {
  int64_t mock_local_auth_id = 1234;

  std::unique_ptr<MockMethodResult> initialize_result =
      std::make_unique<MockMethodResult>();

  std::unique_ptr<MockLocalAuth> local_auth =
      std::make_unique<MockLocalAuth>(MOCK_DEVICE_ID);

  std::unique_ptr<MockCaptureController> capture_controller =
      std::make_unique<MockCaptureController>();

  EXPECT_CALL(*local_auth, HasLocalAuthId(Eq(mock_local_auth_id)))
      .Times(1)
      .WillOnce([cam = local_auth.get()](int64_t local_auth_id) {
        return cam->local_auth_id_ == local_auth_id;
      });

  EXPECT_CALL(*local_auth,
              HasPendingResultByType(Eq(PendingResultType::kTakePicture)))
      .Times(1)
      .WillOnce(Return(false));

  EXPECT_CALL(*local_auth, AddPendingResult(Eq(PendingResultType::kTakePicture), _))
      .Times(1)
      .WillOnce([cam = local_auth.get()](PendingResultType type,
                                     std::unique_ptr<MethodResult<>> result) {
        cam->pending_result_ = std::move(result);
        return true;
      });

  EXPECT_CALL(*local_auth, GetCaptureController)
      .Times(1)
      .WillOnce([cam = local_auth.get()]() {
        assert(cam->pending_result_);
        return cam->capture_controller_.get();
      });

  EXPECT_CALL(*capture_controller, TakePicture(EndsWith(".jpeg")))
      .Times(1)
      .WillOnce([cam = local_auth.get()](const std::string& file_path) {
        assert(cam->pending_result_);
        return cam->pending_result_->Success();
      });

  local_auth->local_auth_id_ = mock_local_auth_id;
  local_auth->capture_controller_ = std::move(capture_controller);

  MockLocalAuthPlugin plugin(std::make_unique<MockTextureRegistrar>().get(),
                          std::make_unique<MockBinaryMessenger>().get(),
                          std::make_unique<MockLocalAuthFactory>());

  // Add mocked local_auth to plugins local_auth list.
  plugin.AddLocalAuth(std::move(local_auth));

  EXPECT_CALL(*initialize_result, ErrorInternal).Times(0);
  EXPECT_CALL(*initialize_result, SuccessInternal).Times(1);

  EncodableMap args = {
      {EncodableValue("local_authId"), EncodableValue(mock_local_auth_id)},
  };

  plugin.HandleMethodCall(
      flutter::MethodCall("takePicture",
                          std::make_unique<EncodableValue>(EncodableMap(args))),
      std::move(initialize_result));
}

TEST(LocalAuthPlugin, TakePictureHandlerErrorOnInvalidLocalAuthId) {
  int64_t mock_local_auth_id = 1234;
  int64_t missing_local_auth_id = 5678;

  std::unique_ptr<MockMethodResult> initialize_result =
      std::make_unique<MockMethodResult>();

  std::unique_ptr<MockLocalAuth> local_auth =
      std::make_unique<MockLocalAuth>(MOCK_DEVICE_ID);

  std::unique_ptr<MockCaptureController> capture_controller =
      std::make_unique<MockCaptureController>();

  EXPECT_CALL(*local_auth, HasLocalAuthId)
      .Times(1)
      .WillOnce([cam = local_auth.get()](int64_t local_auth_id) {
        return cam->local_auth_id_ == local_auth_id;
      });

  EXPECT_CALL(*local_auth, HasPendingResultByType).Times(0);
  EXPECT_CALL(*local_auth, AddPendingResult).Times(0);
  EXPECT_CALL(*local_auth, GetCaptureController).Times(0);
  EXPECT_CALL(*capture_controller, TakePicture).Times(0);

  local_auth->local_auth_id_ = mock_local_auth_id;

  MockLocalAuthPlugin plugin(std::make_unique<MockTextureRegistrar>().get(),
                          std::make_unique<MockBinaryMessenger>().get(),
                          std::make_unique<MockLocalAuthFactory>());

  // Add mocked local_auth to plugins local_auth list.
  plugin.AddLocalAuth(std::move(local_auth));

  EXPECT_CALL(*initialize_result, ErrorInternal).Times(1);
  EXPECT_CALL(*initialize_result, SuccessInternal).Times(0);

  EncodableMap args = {
      {EncodableValue("local_authId"), EncodableValue(missing_local_auth_id)},
  };

  plugin.HandleMethodCall(
      flutter::MethodCall("takePicture",
                          std::make_unique<EncodableValue>(EncodableMap(args))),
      std::move(initialize_result));
}

TEST(LocalAuthPlugin, StartVideoRecordingHandlerCallsStartRecordWithPath) {
  int64_t mock_local_auth_id = 1234;

  std::unique_ptr<MockMethodResult> initialize_result =
      std::make_unique<MockMethodResult>();

  std::unique_ptr<MockLocalAuth> local_auth =
      std::make_unique<MockLocalAuth>(MOCK_DEVICE_ID);

  std::unique_ptr<MockCaptureController> capture_controller =
      std::make_unique<MockCaptureController>();

  EXPECT_CALL(*local_auth, HasLocalAuthId(Eq(mock_local_auth_id)))
      .Times(1)
      .WillOnce([cam = local_auth.get()](int64_t local_auth_id) {
        return cam->local_auth_id_ == local_auth_id;
      });

  EXPECT_CALL(*local_auth,
              HasPendingResultByType(Eq(PendingResultType::kStartRecord)))
      .Times(1)
      .WillOnce(Return(false));

  EXPECT_CALL(*local_auth, AddPendingResult(Eq(PendingResultType::kStartRecord), _))
      .Times(1)
      .WillOnce([cam = local_auth.get()](PendingResultType type,
                                     std::unique_ptr<MethodResult<>> result) {
        cam->pending_result_ = std::move(result);
        return true;
      });

  EXPECT_CALL(*local_auth, GetCaptureController)
      .Times(1)
      .WillOnce([cam = local_auth.get()]() {
        assert(cam->pending_result_);
        return cam->capture_controller_.get();
      });

  EXPECT_CALL(*capture_controller, StartRecord(EndsWith(".mp4"), -1))
      .Times(1)
      .WillOnce([cam = local_auth.get()](const std::string& file_path,
                                     int64_t max_video_duration_ms) {
        assert(cam->pending_result_);
        return cam->pending_result_->Success();
      });

  local_auth->local_auth_id_ = mock_local_auth_id;
  local_auth->capture_controller_ = std::move(capture_controller);

  MockLocalAuthPlugin plugin(std::make_unique<MockTextureRegistrar>().get(),
                          std::make_unique<MockBinaryMessenger>().get(),
                          std::make_unique<MockLocalAuthFactory>());

  // Add mocked local_auth to plugins local_auth list.
  plugin.AddLocalAuth(std::move(local_auth));

  EXPECT_CALL(*initialize_result, ErrorInternal).Times(0);
  EXPECT_CALL(*initialize_result, SuccessInternal).Times(1);

  EncodableMap args = {
      {EncodableValue("local_authId"), EncodableValue(mock_local_auth_id)},
  };

  plugin.HandleMethodCall(
      flutter::MethodCall("startVideoRecording",
                          std::make_unique<EncodableValue>(EncodableMap(args))),
      std::move(initialize_result));
}

TEST(LocalAuthPlugin,
     StartVideoRecordingHandlerCallsStartRecordWithPathAndCaptureDuration) {
  int64_t mock_local_auth_id = 1234;
  int32_t mock_video_duration = 100000;

  std::unique_ptr<MockMethodResult> initialize_result =
      std::make_unique<MockMethodResult>();

  std::unique_ptr<MockLocalAuth> local_auth =
      std::make_unique<MockLocalAuth>(MOCK_DEVICE_ID);

  std::unique_ptr<MockCaptureController> capture_controller =
      std::make_unique<MockCaptureController>();

  EXPECT_CALL(*local_auth, HasLocalAuthId(Eq(mock_local_auth_id)))
      .Times(1)
      .WillOnce([cam = local_auth.get()](int64_t local_auth_id) {
        return cam->local_auth_id_ == local_auth_id;
      });

  EXPECT_CALL(*local_auth,
              HasPendingResultByType(Eq(PendingResultType::kStartRecord)))
      .Times(1)
      .WillOnce(Return(false));

  EXPECT_CALL(*local_auth, AddPendingResult(Eq(PendingResultType::kStartRecord), _))
      .Times(1)
      .WillOnce([cam = local_auth.get()](PendingResultType type,
                                     std::unique_ptr<MethodResult<>> result) {
        cam->pending_result_ = std::move(result);
        return true;
      });

  EXPECT_CALL(*local_auth, GetCaptureController)
      .Times(1)
      .WillOnce([cam = local_auth.get()]() {
        assert(cam->pending_result_);
        return cam->capture_controller_.get();
      });

  EXPECT_CALL(*capture_controller,
              StartRecord(EndsWith(".mp4"), Eq(mock_video_duration)))
      .Times(1)
      .WillOnce([cam = local_auth.get()](const std::string& file_path,
                                     int64_t max_video_duration_ms) {
        assert(cam->pending_result_);
        return cam->pending_result_->Success();
      });

  local_auth->local_auth_id_ = mock_local_auth_id;
  local_auth->capture_controller_ = std::move(capture_controller);

  MockLocalAuthPlugin plugin(std::make_unique<MockTextureRegistrar>().get(),
                          std::make_unique<MockBinaryMessenger>().get(),
                          std::make_unique<MockLocalAuthFactory>());

  // Add mocked local_auth to plugins local_auth list.
  plugin.AddLocalAuth(std::move(local_auth));

  EXPECT_CALL(*initialize_result, ErrorInternal).Times(0);
  EXPECT_CALL(*initialize_result, SuccessInternal).Times(1);

  EncodableMap args = {
      {EncodableValue("local_authId"), EncodableValue(mock_local_auth_id)},
      {EncodableValue("maxVideoDuration"), EncodableValue(mock_video_duration)},
  };

  plugin.HandleMethodCall(
      flutter::MethodCall("startVideoRecording",
                          std::make_unique<EncodableValue>(EncodableMap(args))),
      std::move(initialize_result));
}

TEST(LocalAuthPlugin, StartVideoRecordingHandlerErrorOnInvalidLocalAuthId) {
  int64_t mock_local_auth_id = 1234;
  int64_t missing_local_auth_id = 5678;

  std::unique_ptr<MockMethodResult> initialize_result =
      std::make_unique<MockMethodResult>();

  std::unique_ptr<MockLocalAuth> local_auth =
      std::make_unique<MockLocalAuth>(MOCK_DEVICE_ID);

  std::unique_ptr<MockCaptureController> capture_controller =
      std::make_unique<MockCaptureController>();

  EXPECT_CALL(*local_auth, HasLocalAuthId)
      .Times(1)
      .WillOnce([cam = local_auth.get()](int64_t local_auth_id) {
        return cam->local_auth_id_ == local_auth_id;
      });

  EXPECT_CALL(*local_auth, HasPendingResultByType).Times(0);
  EXPECT_CALL(*local_auth, AddPendingResult).Times(0);
  EXPECT_CALL(*local_auth, GetCaptureController).Times(0);
  EXPECT_CALL(*capture_controller, StartRecord(_, -1)).Times(0);

  local_auth->local_auth_id_ = mock_local_auth_id;

  MockLocalAuthPlugin plugin(std::make_unique<MockTextureRegistrar>().get(),
                          std::make_unique<MockBinaryMessenger>().get(),
                          std::make_unique<MockLocalAuthFactory>());

  // Add mocked local_auth to plugins local_auth list.
  plugin.AddLocalAuth(std::move(local_auth));

  EXPECT_CALL(*initialize_result, ErrorInternal).Times(1);
  EXPECT_CALL(*initialize_result, SuccessInternal).Times(0);

  EncodableMap args = {
      {EncodableValue("local_authId"), EncodableValue(missing_local_auth_id)},
  };

  plugin.HandleMethodCall(
      flutter::MethodCall("startVideoRecording",
                          std::make_unique<EncodableValue>(EncodableMap(args))),
      std::move(initialize_result));
}

TEST(LocalAuthPlugin, StopVideoRecordingHandlerCallsStopRecord) {
  int64_t mock_local_auth_id = 1234;

  std::unique_ptr<MockMethodResult> initialize_result =
      std::make_unique<MockMethodResult>();

  std::unique_ptr<MockLocalAuth> local_auth =
      std::make_unique<MockLocalAuth>(MOCK_DEVICE_ID);

  std::unique_ptr<MockCaptureController> capture_controller =
      std::make_unique<MockCaptureController>();

  EXPECT_CALL(*local_auth, HasLocalAuthId(Eq(mock_local_auth_id)))
      .Times(1)
      .WillOnce([cam = local_auth.get()](int64_t local_auth_id) {
        return cam->local_auth_id_ == local_auth_id;
      });

  EXPECT_CALL(*local_auth,
              HasPendingResultByType(Eq(PendingResultType::kStopRecord)))
      .Times(1)
      .WillOnce(Return(false));

  EXPECT_CALL(*local_auth, AddPendingResult(Eq(PendingResultType::kStopRecord), _))
      .Times(1)
      .WillOnce([cam = local_auth.get()](PendingResultType type,
                                     std::unique_ptr<MethodResult<>> result) {
        cam->pending_result_ = std::move(result);
        return true;
      });

  EXPECT_CALL(*local_auth, GetCaptureController)
      .Times(1)
      .WillOnce([cam = local_auth.get()]() {
        assert(cam->pending_result_);
        return cam->capture_controller_.get();
      });

  EXPECT_CALL(*capture_controller, StopRecord)
      .Times(1)
      .WillOnce([cam = local_auth.get()]() {
        assert(cam->pending_result_);
        return cam->pending_result_->Success();
      });

  local_auth->local_auth_id_ = mock_local_auth_id;
  local_auth->capture_controller_ = std::move(capture_controller);

  MockLocalAuthPlugin plugin(std::make_unique<MockTextureRegistrar>().get(),
                          std::make_unique<MockBinaryMessenger>().get(),
                          std::make_unique<MockLocalAuthFactory>());

  // Add mocked local_auth to plugins local_auth list.
  plugin.AddLocalAuth(std::move(local_auth));

  EXPECT_CALL(*initialize_result, ErrorInternal).Times(0);
  EXPECT_CALL(*initialize_result, SuccessInternal).Times(1);

  EncodableMap args = {
      {EncodableValue("local_authId"), EncodableValue(mock_local_auth_id)},
  };

  plugin.HandleMethodCall(
      flutter::MethodCall("stopVideoRecording",
                          std::make_unique<EncodableValue>(EncodableMap(args))),
      std::move(initialize_result));
}

TEST(LocalAuthPlugin, StopVideoRecordingHandlerErrorOnInvalidLocalAuthId) {
  int64_t mock_local_auth_id = 1234;
  int64_t missing_local_auth_id = 5678;

  std::unique_ptr<MockMethodResult> initialize_result =
      std::make_unique<MockMethodResult>();

  std::unique_ptr<MockLocalAuth> local_auth =
      std::make_unique<MockLocalAuth>(MOCK_DEVICE_ID);

  std::unique_ptr<MockCaptureController> capture_controller =
      std::make_unique<MockCaptureController>();

  EXPECT_CALL(*local_auth, HasLocalAuthId)
      .Times(1)
      .WillOnce([cam = local_auth.get()](int64_t local_auth_id) {
        return cam->local_auth_id_ == local_auth_id;
      });

  EXPECT_CALL(*local_auth, HasPendingResultByType).Times(0);
  EXPECT_CALL(*local_auth, AddPendingResult).Times(0);
  EXPECT_CALL(*local_auth, GetCaptureController).Times(0);
  EXPECT_CALL(*capture_controller, StopRecord).Times(0);

  local_auth->local_auth_id_ = mock_local_auth_id;

  MockLocalAuthPlugin plugin(std::make_unique<MockTextureRegistrar>().get(),
                          std::make_unique<MockBinaryMessenger>().get(),
                          std::make_unique<MockLocalAuthFactory>());

  // Add mocked local_auth to plugins local_auth list.
  plugin.AddLocalAuth(std::move(local_auth));

  EXPECT_CALL(*initialize_result, ErrorInternal).Times(1);
  EXPECT_CALL(*initialize_result, SuccessInternal).Times(0);

  EncodableMap args = {
      {EncodableValue("local_authId"), EncodableValue(missing_local_auth_id)},
  };

  plugin.HandleMethodCall(
      flutter::MethodCall("stopVideoRecording",
                          std::make_unique<EncodableValue>(EncodableMap(args))),
      std::move(initialize_result));
}

TEST(LocalAuthPlugin, ResumePreviewHandlerCallsResumePreview) {
  int64_t mock_local_auth_id = 1234;

  std::unique_ptr<MockMethodResult> initialize_result =
      std::make_unique<MockMethodResult>();

  std::unique_ptr<MockLocalAuth> local_auth =
      std::make_unique<MockLocalAuth>(MOCK_DEVICE_ID);

  std::unique_ptr<MockCaptureController> capture_controller =
      std::make_unique<MockCaptureController>();

  EXPECT_CALL(*local_auth, HasLocalAuthId(Eq(mock_local_auth_id)))
      .Times(1)
      .WillOnce([cam = local_auth.get()](int64_t local_auth_id) {
        return cam->local_auth_id_ == local_auth_id;
      });

  EXPECT_CALL(*local_auth,
              HasPendingResultByType(Eq(PendingResultType::kResumePreview)))
      .Times(1)
      .WillOnce(Return(false));

  EXPECT_CALL(*local_auth,
              AddPendingResult(Eq(PendingResultType::kResumePreview), _))
      .Times(1)
      .WillOnce([cam = local_auth.get()](PendingResultType type,
                                     std::unique_ptr<MethodResult<>> result) {
        cam->pending_result_ = std::move(result);
        return true;
      });

  EXPECT_CALL(*local_auth, GetCaptureController)
      .Times(1)
      .WillOnce([cam = local_auth.get()]() {
        assert(cam->pending_result_);
        return cam->capture_controller_.get();
      });

  EXPECT_CALL(*capture_controller, ResumePreview)
      .Times(1)
      .WillOnce([cam = local_auth.get()]() {
        assert(cam->pending_result_);
        return cam->pending_result_->Success();
      });

  local_auth->local_auth_id_ = mock_local_auth_id;
  local_auth->capture_controller_ = std::move(capture_controller);

  MockLocalAuthPlugin plugin(std::make_unique<MockTextureRegistrar>().get(),
                          std::make_unique<MockBinaryMessenger>().get(),
                          std::make_unique<MockLocalAuthFactory>());

  // Add mocked local_auth to plugins local_auth list.
  plugin.AddLocalAuth(std::move(local_auth));

  EXPECT_CALL(*initialize_result, ErrorInternal).Times(0);
  EXPECT_CALL(*initialize_result, SuccessInternal).Times(1);

  EncodableMap args = {
      {EncodableValue("local_authId"), EncodableValue(mock_local_auth_id)},
  };

  plugin.HandleMethodCall(
      flutter::MethodCall("resumePreview",
                          std::make_unique<EncodableValue>(EncodableMap(args))),
      std::move(initialize_result));
}

TEST(LocalAuthPlugin, ResumePreviewHandlerErrorOnInvalidLocalAuthId) {
  int64_t mock_local_auth_id = 1234;
  int64_t missing_local_auth_id = 5678;

  std::unique_ptr<MockMethodResult> initialize_result =
      std::make_unique<MockMethodResult>();

  std::unique_ptr<MockLocalAuth> local_auth =
      std::make_unique<MockLocalAuth>(MOCK_DEVICE_ID);

  std::unique_ptr<MockCaptureController> capture_controller =
      std::make_unique<MockCaptureController>();

  EXPECT_CALL(*local_auth, HasLocalAuthId)
      .Times(1)
      .WillOnce([cam = local_auth.get()](int64_t local_auth_id) {
        return cam->local_auth_id_ == local_auth_id;
      });

  EXPECT_CALL(*local_auth, HasPendingResultByType).Times(0);
  EXPECT_CALL(*local_auth, AddPendingResult).Times(0);
  EXPECT_CALL(*local_auth, GetCaptureController).Times(0);
  EXPECT_CALL(*capture_controller, ResumePreview).Times(0);

  local_auth->local_auth_id_ = mock_local_auth_id;

  MockLocalAuthPlugin plugin(std::make_unique<MockTextureRegistrar>().get(),
                          std::make_unique<MockBinaryMessenger>().get(),
                          std::make_unique<MockLocalAuthFactory>());

  // Add mocked local_auth to plugins local_auth list.
  plugin.AddLocalAuth(std::move(local_auth));

  EXPECT_CALL(*initialize_result, ErrorInternal).Times(1);
  EXPECT_CALL(*initialize_result, SuccessInternal).Times(0);

  EncodableMap args = {
      {EncodableValue("local_authId"), EncodableValue(missing_local_auth_id)},
  };

  plugin.HandleMethodCall(
      flutter::MethodCall("resumePreview",
                          std::make_unique<EncodableValue>(EncodableMap(args))),
      std::move(initialize_result));
}

TEST(LocalAuthPlugin, PausePreviewHandlerCallsPausePreview) {
  int64_t mock_local_auth_id = 1234;

  std::unique_ptr<MockMethodResult> initialize_result =
      std::make_unique<MockMethodResult>();

  std::unique_ptr<MockLocalAuth> local_auth =
      std::make_unique<MockLocalAuth>(MOCK_DEVICE_ID);

  std::unique_ptr<MockCaptureController> capture_controller =
      std::make_unique<MockCaptureController>();

  EXPECT_CALL(*local_auth, HasLocalAuthId(Eq(mock_local_auth_id)))
      .Times(1)
      .WillOnce([cam = local_auth.get()](int64_t local_auth_id) {
        return cam->local_auth_id_ == local_auth_id;
      });

  EXPECT_CALL(*local_auth,
              HasPendingResultByType(Eq(PendingResultType::kPausePreview)))
      .Times(1)
      .WillOnce(Return(false));

  EXPECT_CALL(*local_auth,
              AddPendingResult(Eq(PendingResultType::kPausePreview), _))
      .Times(1)
      .WillOnce([cam = local_auth.get()](PendingResultType type,
                                     std::unique_ptr<MethodResult<>> result) {
        cam->pending_result_ = std::move(result);
        return true;
      });

  EXPECT_CALL(*local_auth, GetCaptureController)
      .Times(1)
      .WillOnce([cam = local_auth.get()]() {
        assert(cam->pending_result_);
        return cam->capture_controller_.get();
      });

  EXPECT_CALL(*capture_controller, PausePreview)
      .Times(1)
      .WillOnce([cam = local_auth.get()]() {
        assert(cam->pending_result_);
        return cam->pending_result_->Success();
      });

  local_auth->local_auth_id_ = mock_local_auth_id;
  local_auth->capture_controller_ = std::move(capture_controller);

  MockLocalAuthPlugin plugin(std::make_unique<MockTextureRegistrar>().get(),
                          std::make_unique<MockBinaryMessenger>().get(),
                          std::make_unique<MockLocalAuthFactory>());

  // Add mocked local_auth to plugins local_auth list.
  plugin.AddLocalAuth(std::move(local_auth));

  EXPECT_CALL(*initialize_result, ErrorInternal).Times(0);
  EXPECT_CALL(*initialize_result, SuccessInternal).Times(1);

  EncodableMap args = {
      {EncodableValue("local_authId"), EncodableValue(mock_local_auth_id)},
  };

  plugin.HandleMethodCall(
      flutter::MethodCall("pausePreview",
                          std::make_unique<EncodableValue>(EncodableMap(args))),
      std::move(initialize_result));
}

TEST(LocalAuthPlugin, PausePreviewHandlerErrorOnInvalidLocalAuthId) {
  int64_t mock_local_auth_id = 1234;
  int64_t missing_local_auth_id = 5678;

  std::unique_ptr<MockMethodResult> initialize_result =
      std::make_unique<MockMethodResult>();

  std::unique_ptr<MockLocalAuth> local_auth =
      std::make_unique<MockLocalAuth>(MOCK_DEVICE_ID);

  std::unique_ptr<MockCaptureController> capture_controller =
      std::make_unique<MockCaptureController>();

  EXPECT_CALL(*local_auth, HasLocalAuthId)
      .Times(1)
      .WillOnce([cam = local_auth.get()](int64_t local_auth_id) {
        return cam->local_auth_id_ == local_auth_id;
      });

  EXPECT_CALL(*local_auth, HasPendingResultByType).Times(0);
  EXPECT_CALL(*local_auth, AddPendingResult).Times(0);
  EXPECT_CALL(*local_auth, GetCaptureController).Times(0);
  EXPECT_CALL(*capture_controller, PausePreview).Times(0);

  local_auth->local_auth_id_ = mock_local_auth_id;

  MockLocalAuthPlugin plugin(std::make_unique<MockTextureRegistrar>().get(),
                          std::make_unique<MockBinaryMessenger>().get(),
                          std::make_unique<MockLocalAuthFactory>());

  // Add mocked local_auth to plugins local_auth list.
  plugin.AddLocalAuth(std::move(local_auth));

  EXPECT_CALL(*initialize_result, ErrorInternal).Times(1);
  EXPECT_CALL(*initialize_result, SuccessInternal).Times(0);

  EncodableMap args = {
      {EncodableValue("local_authId"), EncodableValue(missing_local_auth_id)},
  };

  plugin.HandleMethodCall(
      flutter::MethodCall("pausePreview",
                          std::make_unique<EncodableValue>(EncodableMap(args))),
      std::move(initialize_result));
}

}  // namespace test
}  // namespace local_auth_windows
