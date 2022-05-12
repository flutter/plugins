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
#include <windows.h>
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.Security.Credentials.UI.h>
#include <winstring.h>

#include <map>
#include <memory>
#include <sstream>

namespace local_auth_windows {

class UserConsentVerifier {
 public:
  UserConsentVerifier() {}
  virtual ~UserConsentVerifier() = default;

  virtual winrt::Windows::Foundation::IAsyncOperation<
      winrt::Windows::Security::Credentials::UI::UserConsentVerificationResult>
  RequestVerificationForWindowAsync(std::wstring localized_reason) = 0;
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

  LocalAuthPlugin(std::function<HWND()> window_provider);
  LocalAuthPlugin(std::unique_ptr<UserConsentVerifier> user_consent_verifier);

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  virtual ~LocalAuthPlugin();

 private:
  std::unique_ptr<UserConsentVerifier> user_consent_verifier_;

  winrt::fire_and_forget Authenticate(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  winrt::fire_and_forget GetEnrolledBiometrics(
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  winrt::fire_and_forget IsDeviceSupported(
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace local_auth_windows