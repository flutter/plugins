// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <UserConsentVerifierInterop.h>
#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <pplawait.h>
#include <ppltasks.h>

// Include prior to C++/WinRT Headers
#include <wil/cppwinrt.h>
#include <wil/win32_helpers.h>
#include <windows.h>
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.Security.Credentials.UI.h>

#include <map>
#include <memory>
#include <sstream>

#include "messages.g.h"

namespace local_auth_windows {

// Abstract class that is used to determine whether a user
// has given consent to a particular action, and if the system
// supports asking this question.
class UserConsentVerifier {
 public:
  UserConsentVerifier() {}
  virtual ~UserConsentVerifier() = default;

  // Abstract method that request the user's verification
  // given the provided reason.
  virtual winrt::Windows::Foundation::IAsyncOperation<
      winrt::Windows::Security::Credentials::UI::UserConsentVerificationResult>
  RequestVerificationForWindowAsync(std::wstring localized_reason) = 0;

  // Abstract method that returns weather the system supports Windows Hello.
  virtual winrt::Windows::Foundation::IAsyncOperation<
      winrt::Windows::Security::Credentials::UI::
          UserConsentVerifierAvailability>
  CheckAvailabilityAsync() = 0;

  // Disallow copy and move.
  UserConsentVerifier(const UserConsentVerifier&) = delete;
  UserConsentVerifier& operator=(const UserConsentVerifier&) = delete;
};

class LocalAuthPlugin : public flutter::Plugin, public LocalAuthApi {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  // Creates a plugin instance that will create the dialog and associate
  // it with the HWND returned from the provided function.
  LocalAuthPlugin(std::function<HWND()> window_provider);

  // Creates a plugin instance with the given UserConsentVerifier instance.
  // Exists for unit testing with mock implementations.
  LocalAuthPlugin(std::unique_ptr<UserConsentVerifier> user_consent_verifier);

  virtual ~LocalAuthPlugin();

  // LocalAuthApi:
  void IsDeviceSupported(
      std::function<void(ErrorOr<bool> reply)> result) override;
  void Authenticate(const std::string& localized_reason,
                    std::function<void(ErrorOr<bool> reply)> result) override;

 private:
  std::unique_ptr<UserConsentVerifier> user_consent_verifier_;

  // Starts authentication process.
  winrt::fire_and_forget AuthenticateCoroutine(
      const std::string& localized_reason,
      std::function<void(ErrorOr<bool> reply)> result);

  // Returns whether the system supports Windows Hello.
  winrt::fire_and_forget IsDeviceSupportedCoroutine(
      std::function<void(ErrorOr<bool> reply)> result);
};

}  // namespace local_auth_windows
