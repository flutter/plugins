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

using flutter::EncodableMap;
using flutter::EncodableValue;
using ::testing::_;
using ::testing::DoAll;
using ::testing::EndsWith;
using ::testing::Eq;
using ::testing::Pointee;
using ::testing::Return;

TEST(LocalAuthPlugin, AvailableLocalAuthsHandlerSuccessIfNoLocalAuths) {
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  std::unique_ptr<MockUserConsentVerifier> mockConsentVerifier =
      std::make_unique<MockUserConsentVerifier>();

  EXPECT_CALL(*mockConsentVerifier, CheckAvailabilityAsync)
      .Times(1)
      .WillOnce([]() -> Windows::Foundation::IAsyncOperation<
                         winrt::Windows::Security::Credentials::UI::
                             UserConsentVerifierAvailability> {
        co_return winrt::Windows::Security::Credentials::UI::
            UserConsentVerifierAvailability::Available;
      });

  LocalAuthPlugin plugin(std::move(mockConsentVerifier));

  EXPECT_CALL(*result, ErrorInternal).Times(0);
  EXPECT_CALL(*result, SuccessInternal).Times(1);

  plugin.HandleMethodCall(
      flutter::MethodCall("isDeviceSupported",
                          std::make_unique<EncodableValue>()),
      std::move(result));
}

}  // namespace test
}  // namespace local_auth_windows
