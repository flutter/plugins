// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <UserConsentVerifierInterop.h>

#include "include/local_auth_windows/local_auth_plugin.h"

// This must be included before many other Windows headers.
#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <pplawait.h>
#include <ppltasks.h>
#include <windows.h>
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.Security.Credentials.UI.h>
#include <winstring.h>

#include <map>
#include <memory>
#include <sstream>

namespace local_auth_windows {

using namespace flutter;
using namespace winrt;

class UserConsentVerifier {
 public:
  UserConsentVerifier() {}
  virtual ~UserConsentVerifier() = default;

  virtual Windows::Foundation::IAsyncOperation<
      Windows::Security::Credentials::UI::UserConsentVerificationResult>
  RequestVerificationForWindowAsync(std::wstring localizedReason) = 0;
  virtual Windows::Foundation::IAsyncOperation<
      Windows::Security::Credentials::UI::UserConsentVerifierAvailability>
  CheckAvailabilityAsync() = 0;

  // Disallow copy and move.
  UserConsentVerifier(const UserConsentVerifier&) = delete;
  UserConsentVerifier& operator=(const UserConsentVerifier&) = delete;
};

class LocalAuthPlugin : public Plugin {
 public:
  static void RegisterWithRegistrar(PluginRegistrarWindows* registrar);

  LocalAuthPlugin(std::function<HWND()> window_provider);
  LocalAuthPlugin(std::unique_ptr<UserConsentVerifier> user_consent_verifier);

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(const MethodCall<EncodableValue>& method_call,
                        std::unique_ptr<MethodResult<EncodableValue>> result);

  virtual ~LocalAuthPlugin();

 private:
  std::unique_ptr<UserConsentVerifier> user_consent_verifier_;

  winrt::fire_and_forget Authenticate(
      const MethodCall<EncodableValue>& method_call,
      std::unique_ptr<MethodResult<EncodableValue>> result);
  winrt::fire_and_forget GetAvailableBiometrics(
      std::unique_ptr<MethodResult<EncodableValue>> result);
  winrt::fire_and_forget IsDeviceSupported(
      std::unique_ptr<MethodResult<EncodableValue>> result);
};

}  // namespace local_auth_windows