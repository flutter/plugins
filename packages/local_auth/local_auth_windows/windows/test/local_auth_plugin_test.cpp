// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "include/local_auth_windows/local_auth_plugin.h"

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

using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;
using ::testing::_;
using ::testing::DoAll;
using ::testing::EndsWith;
using ::testing::Eq;
using ::testing::Pointee;
using ::testing::Return;

TEST(LocalAuthPlugin, IsDeviceSupportedHandlerSuccessIfVerifierAvailable) {
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  std::unique_ptr<MockUserConsentVerifier> mockConsentVerifier =
      std::make_unique<MockUserConsentVerifier>();

  EXPECT_CALL(*mockConsentVerifier, CheckAvailabilityAsync)
      .Times(1)
      .WillOnce([]() -> winrt::Windows::Foundation::IAsyncOperation<
                         winrt::Windows::Security::Credentials::UI::
                             UserConsentVerifierAvailability> {
        co_return winrt::Windows::Security::Credentials::UI::
            UserConsentVerifierAvailability::Available;
      });

  LocalAuthPlugin plugin(std::move(mockConsentVerifier));

  EXPECT_CALL(*result, ErrorInternal).Times(0);
  EXPECT_CALL(*result, SuccessInternal(Pointee(EncodableValue(true))));

  plugin.HandleMethodCall(
      flutter::MethodCall("isDeviceSupported",
                          std::make_unique<EncodableValue>()),
      std::move(result));
}

TEST(LocalAuthPlugin, IsDeviceSupportedHandlerSuccessIfVerifierNotAvailable) {
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  std::unique_ptr<MockUserConsentVerifier> mockConsentVerifier =
      std::make_unique<MockUserConsentVerifier>();

  EXPECT_CALL(*mockConsentVerifier, CheckAvailabilityAsync)
      .Times(1)
      .WillOnce([]() -> winrt::Windows::Foundation::IAsyncOperation<
                         winrt::Windows::Security::Credentials::UI::
                             UserConsentVerifierAvailability> {
        co_return winrt::Windows::Security::Credentials::UI::
            UserConsentVerifierAvailability::DeviceNotPresent;
      });

  LocalAuthPlugin plugin(std::move(mockConsentVerifier));

  EXPECT_CALL(*result, ErrorInternal).Times(0);
  EXPECT_CALL(*result, SuccessInternal(Pointee(EncodableValue(false))));

  plugin.HandleMethodCall(
      flutter::MethodCall("isDeviceSupported",
                          std::make_unique<EncodableValue>()),
      std::move(result));
}

TEST(LocalAuthPlugin,
     GetEnrolledBiometricsHandlerReturnEmptyListIfVerifierNotAvailable) {
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  std::unique_ptr<MockUserConsentVerifier> mockConsentVerifier =
      std::make_unique<MockUserConsentVerifier>();

  EXPECT_CALL(*mockConsentVerifier, CheckAvailabilityAsync)
      .Times(1)
      .WillOnce([]() -> winrt::Windows::Foundation::IAsyncOperation<
                         winrt::Windows::Security::Credentials::UI::
                             UserConsentVerifierAvailability> {
        co_return winrt::Windows::Security::Credentials::UI::
            UserConsentVerifierAvailability::DeviceNotPresent;
      });

  LocalAuthPlugin plugin(std::move(mockConsentVerifier));

  EXPECT_CALL(*result, ErrorInternal).Times(0);
  EXPECT_CALL(*result, SuccessInternal(Pointee(EncodableList())));

  plugin.HandleMethodCall(
      flutter::MethodCall("getEnrolledBiometrics",
                          std::make_unique<EncodableValue>()),
      std::move(result));
}

TEST(LocalAuthPlugin,
     GetEnrolledBiometricsHandlerReturnNonEmptyListIfVerifierAvailable) {
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  std::unique_ptr<MockUserConsentVerifier> mockConsentVerifier =
      std::make_unique<MockUserConsentVerifier>();

  EXPECT_CALL(*mockConsentVerifier, CheckAvailabilityAsync)
      .Times(1)
      .WillOnce([]() -> winrt::Windows::Foundation::IAsyncOperation<
                         winrt::Windows::Security::Credentials::UI::
                             UserConsentVerifierAvailability> {
        co_return winrt::Windows::Security::Credentials::UI::
            UserConsentVerifierAvailability::Available;
      });

  LocalAuthPlugin plugin(std::move(mockConsentVerifier));

  EXPECT_CALL(*result, ErrorInternal).Times(0);
  EXPECT_CALL(*result,
              SuccessInternal(Pointee(EncodableList(
                  {EncodableValue("weak"), EncodableValue("strong")}))));

  plugin.HandleMethodCall(
      flutter::MethodCall("getEnrolledBiometrics",
                          std::make_unique<EncodableValue>()),
      std::move(result));
}

TEST(LocalAuthPlugin, AuthenticateHandlerDoesNotSupportBiometricOnly) {
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  std::unique_ptr<MockUserConsentVerifier> mockConsentVerifier =
      std::make_unique<MockUserConsentVerifier>();

  LocalAuthPlugin plugin(std::move(mockConsentVerifier));

  EXPECT_CALL(*result, ErrorInternal).Times(1);
  EXPECT_CALL(*result, SuccessInternal).Times(0);

  std::unique_ptr<EncodableValue> args =
      std::make_unique<EncodableValue>(EncodableMap({
          {"localizedReason", EncodableValue("My Reason")},
          {"biometricOnly", EncodableValue(true)},
      }));

  plugin.HandleMethodCall(flutter::MethodCall("authenticate", std::move(args)),
                          std::move(result));
}

TEST(LocalAuthPlugin, AuthenticateHandlerWorksWhenAuthorized) {
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  std::unique_ptr<MockUserConsentVerifier> mockConsentVerifier =
      std::make_unique<MockUserConsentVerifier>();

  EXPECT_CALL(*mockConsentVerifier, CheckAvailabilityAsync)
      .Times(1)
      .WillOnce([]() -> winrt::Windows::Foundation::IAsyncOperation<
                         winrt::Windows::Security::Credentials::UI::
                             UserConsentVerifierAvailability> {
        co_return winrt::Windows::Security::Credentials::UI::
            UserConsentVerifierAvailability::Available;
      });

  EXPECT_CALL(*mockConsentVerifier, RequestVerificationForWindowAsync)
      .Times(1)
      .WillOnce([](std::wstring localizedReason)
                    -> winrt::Windows::Foundation::IAsyncOperation<
                        winrt::Windows::Security::Credentials::UI::
                            UserConsentVerificationResult> {
        EXPECT_EQ(localizedReason, L"My Reason");
        co_return winrt::Windows::Security::Credentials::UI::
            UserConsentVerificationResult::Verified;
      });

  LocalAuthPlugin plugin(std::move(mockConsentVerifier));

  EXPECT_CALL(*result, ErrorInternal).Times(0);
  EXPECT_CALL(*result, SuccessInternal(Pointee(EncodableValue(true))));

  std::unique_ptr<EncodableValue> args =
      std::make_unique<EncodableValue>(EncodableMap({
          {"localizedReason", EncodableValue("My Reason")},
          {"biometricOnly", EncodableValue(false)},
      }));

  plugin.HandleMethodCall(flutter::MethodCall("authenticate", std::move(args)),
                          std::move(result));
}

TEST(LocalAuthPlugin, AuthenticateHandlerWorksWhenNotAuthorized) {
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  std::unique_ptr<MockUserConsentVerifier> mockConsentVerifier =
      std::make_unique<MockUserConsentVerifier>();

  EXPECT_CALL(*mockConsentVerifier, CheckAvailabilityAsync)
      .Times(1)
      .WillOnce([]() -> winrt::Windows::Foundation::IAsyncOperation<
                         winrt::Windows::Security::Credentials::UI::
                             UserConsentVerifierAvailability> {
        co_return winrt::Windows::Security::Credentials::UI::
            UserConsentVerifierAvailability::Available;
      });

  EXPECT_CALL(*mockConsentVerifier, RequestVerificationForWindowAsync)
      .Times(1)
      .WillOnce([](std::wstring localizedReason)
                    -> winrt::Windows::Foundation::IAsyncOperation<
                        winrt::Windows::Security::Credentials::UI::
                            UserConsentVerificationResult> {
        EXPECT_EQ(localizedReason, L"My Reason");
        co_return winrt::Windows::Security::Credentials::UI::
            UserConsentVerificationResult::Canceled;
      });

  LocalAuthPlugin plugin(std::move(mockConsentVerifier));

  EXPECT_CALL(*result, ErrorInternal).Times(0);
  EXPECT_CALL(*result, SuccessInternal(Pointee(EncodableValue(false))));

  std::unique_ptr<EncodableValue> args =
      std::make_unique<EncodableValue>(EncodableMap({
          {"localizedReason", EncodableValue("My Reason")},
          {"biometricOnly", EncodableValue(false)},
      }));

  plugin.HandleMethodCall(flutter::MethodCall("authenticate", std::move(args)),
                          std::move(result));
}

}  // namespace test
}  // namespace local_auth_windows
