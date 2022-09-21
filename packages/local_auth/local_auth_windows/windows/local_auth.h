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

#include "include/local_auth_windows/local_auth_plugin.h"

// Include prior to C++/WinRT Headers
#include <wil/cppwinrt.h>
#include <wil/win32_helpers.h>
#include <windows.h>
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.Security.Credentials.UI.h>

#include <map>
#include <memory>
#include <sstream>

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

class LocalAuthPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  // Creates a plugin instance that will create the dialog and associate
  // it with the HWND returned from the provided function.
  LocalAuthPlugin(std::function<HWND()> window_provider);

  // Creates a plugin instance with the given UserConsentVerifier instance.
  // Exists for unit testing with mock implementations.
  LocalAuthPlugin(std::unique_ptr<UserConsentVerifier> user_consent_verifier);

  // Handles method calls from Dart on this plugin's channel.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  virtual ~LocalAuthPlugin();

 private:
  std::unique_ptr<UserConsentVerifier> user_consent_verifier_;

  // Starts authentication process.
  winrt::fire_and_forget Authenticate(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  // Returns enrolled biometric types available on device.
  winrt::fire_and_forget GetEnrolledBiometrics(
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  // Returns whether the system supports Windows Hello.
  winrt::fire_and_forget IsDeviceSupported(
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace local_auth_windows