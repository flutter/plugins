// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "include/local_auth_windows/local_auth_plugin.h"

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
  ErrorOr<bool> result(false);
  plugin.IsDeviceSupported([&result](ErrorOr<bool> reply) { result = reply; });

  EXPECT_FALSE(result.has_error());
  EXPECT_TRUE(result.value());
}

TEST(LocalAuthPlugin, IsDeviceSupportedHandlerSuccessIfVerifierNotAvailable) {
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
  ErrorOr<bool> result(true);
  plugin.IsDeviceSupported([&result](ErrorOr<bool> reply) { result = reply; });

  EXPECT_FALSE(result.has_error());
  EXPECT_FALSE(result.value());
}

TEST(LocalAuthPlugin, AuthenticateHandlerWorksWhenAuthorized) {
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
  ErrorOr<bool> result(false);
  plugin.Authenticate("My Reason",
                      [&result](ErrorOr<bool> reply) { result = reply; });

  EXPECT_FALSE(result.has_error());
  EXPECT_TRUE(result.value());
}

TEST(LocalAuthPlugin, AuthenticateHandlerWorksWhenNotAuthorized) {
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
  ErrorOr<bool> result(true);
  plugin.Authenticate("My Reason",
                      [&result](ErrorOr<bool> reply) { result = reply; });

  EXPECT_FALSE(result.has_error());
  EXPECT_FALSE(result.value());
}

}  // namespace test
}  // namespace local_auth_windows
