// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#include "include/local_auth_windows/local_auth_plugin.h"

// This must be included before many other Windows headers.
#include <UserConsentVerifierInterop.h>
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

namespace {

using namespace flutter;
using namespace winrt;

template <typename T>
// Helper method for getting an argument from an EncodableValue
T GetArgument(const std::string arg, const EncodableValue* args, T fallback) {
  T result{fallback};
  const auto* arguments = std::get_if<EncodableMap>(args);
  if (arguments) {
    auto result_it = arguments->find(EncodableValue(arg));
    if (result_it != arguments->end()) {
      result = std::get<T>(result_it->second);
    }
  }
  return result;
}

// Returns the window's HWND for a given FlutterView
HWND GetRootWindow(flutter::FlutterView* view) {
  return ::GetAncestor(view->GetNativeWindow(), GA_ROOT);
}

// Converts the given UTF-8 string to UTF-16.
std::wstring s2ws(const std::string& s) {
  int len;
  int slength = (int)s.length() + 1;
  len = MultiByteToWideChar(CP_ACP, 0, s.c_str(), slength, 0, 0);
  std::wstring r(len, L'\0');
  MultiByteToWideChar(CP_ACP, 0, s.c_str(), slength, &r[0], len);
  return r;
}

class LocalAuthPlugin : public Plugin {
 public:
  static void RegisterWithRegistrar(PluginRegistrarWindows* registrar);

  LocalAuthPlugin(flutter::PluginRegistrarWindows* registrar);

  virtual ~LocalAuthPlugin();

 private:
  flutter::PluginRegistrarWindows* registrar_;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(const MethodCall<EncodableValue>& method_call,
                        std::unique_ptr<MethodResult<EncodableValue>> result);

  winrt::fire_and_forget Authenticate(
      const MethodCall<EncodableValue>& method_call,
      std::unique_ptr<MethodResult<EncodableValue>> result);
  winrt::fire_and_forget GetAvailableBiometrics(
      std::unique_ptr<MethodResult<EncodableValue>> result);
  winrt::fire_and_forget IsDeviceSupported(
      std::unique_ptr<MethodResult<EncodableValue>> result);
};

// static
void LocalAuthPlugin::RegisterWithRegistrar(PluginRegistrarWindows* registrar) {
  auto channel = std::make_unique<MethodChannel<EncodableValue>>(
      registrar->messenger(), "plugins.flutter.io/local_auth_windows",
      &StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<LocalAuthPlugin>(registrar);

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

// Default constructor for LocalAuthPlugin
LocalAuthPlugin::LocalAuthPlugin(flutter::PluginRegistrarWindows* registrar)
    : registrar_(registrar) {}

LocalAuthPlugin::~LocalAuthPlugin() {}

void LocalAuthPlugin::HandleMethodCall(
    const MethodCall<EncodableValue>& method_call,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  if (method_call.method_name().compare("authenticate") == 0) {
    Authenticate(method_call, std::move(result));
  } else if (method_call.method_name().compare("getAvailableBiometrics") == 0) {
    GetAvailableBiometrics(std::move(result));
  } else if (method_call.method_name().compare("isDeviceSupported") == 0) {
    IsDeviceSupported(std::move(result));
  } else {
    result->NotImplemented();
  }
}

// Starts authentication process
winrt::fire_and_forget LocalAuthPlugin::Authenticate(
    const MethodCall<EncodableValue>& method_call,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  auto reasonW = s2ws(GetArgument<std::string>(
      "localizedReason", method_call.arguments(), std::string()));

  auto biometricOnly =
      GetArgument<bool>("biometricOnly", method_call.arguments(), false);
  if (biometricOnly) {
    result->Error("biometricOnlyNotSupported",
                  "Windows doesn't support the biometricOnly parameter.");
    co_return;
  }

  auto ucvAvailability = co_await Windows::Security::Credentials::UI::
      UserConsentVerifier::CheckAvailabilityAsync();

  if (ucvAvailability ==
      Windows::Security::Credentials::UI::UserConsentVerifierAvailability::
          DeviceNotPresent) {
    result->Error("NoHardware", "No biometric hardware found");
    co_return;
  } else if (ucvAvailability ==
             Windows::Security::Credentials::UI::
                 UserConsentVerifierAvailability::NotConfiguredForUser) {
    result->Error("NotEnrolled", "No biometrics enrolled on this device.");
    co_return;
  } else if (ucvAvailability !=
             Windows::Security::Credentials::UI::
                 UserConsentVerifierAvailability::Available) {
    result->Error("NotAvailable", "Required security features not enabled");
    co_return;
  }

  auto userConsentVerifierInterop = winrt::get_activation_factory<
      Windows::Security::Credentials::UI::UserConsentVerifier,
      IUserConsentVerifierInterop>();

  auto hWnd = GetRootWindow(registrar_->GetView());

  HSTRING hReason;
  WindowsCreateString(reasonW.c_str(), (uint32_t)reasonW.size(), &hReason);

  try {
    auto consentResult =
        co_await winrt::capture<Windows::Foundation::IAsyncOperation<
            Windows::Security::Credentials::UI::UserConsentVerificationResult>>(
            userConsentVerifierInterop,
            &::IUserConsentVerifierInterop::RequestVerificationForWindowAsync,
            hWnd, hReason);

    result->Success(EncodableValue(
        consentResult == Windows::Security::Credentials::UI::
                             UserConsentVerificationResult::Verified));
  } catch (...) {
    result->Success(EncodableValue(false));
  }
  WindowsDeleteString(hReason);
}

// Returns biometric types available on device
winrt::fire_and_forget LocalAuthPlugin::GetAvailableBiometrics(
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  try {
    flutter::EncodableList biometrics;
    auto ucvAvailability = co_await Windows::Security::Credentials::UI::
        UserConsentVerifier::CheckAvailabilityAsync();
    if (ucvAvailability == Windows::Security::Credentials::UI::
                               UserConsentVerifierAvailability::Available) {
      biometrics.push_back(EncodableValue("fingerprint"));
      biometrics.push_back(EncodableValue("face"));
      biometrics.push_back(EncodableValue("iris"));
    }
    result->Success(biometrics);
  } catch (const std::exception& e) {
    result->Error("no_biometrics_available", e.what());
  }
}

// Returns whether the device supports Windows Hello or not
winrt::fire_and_forget LocalAuthPlugin::IsDeviceSupported(
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  auto ucvAvailability = co_await Windows::Security::Credentials::UI::
      UserConsentVerifier::CheckAvailabilityAsync();
  result->Success(EncodableValue(
      ucvAvailability == Windows::Security::Credentials::UI::
                             UserConsentVerifierAvailability::Available));
}

}  // namespace

void LocalAuthPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  LocalAuthPlugin::RegisterWithRegistrar(
      PluginRegistrarManager::GetInstance()
          ->GetRegistrar<PluginRegistrarWindows>(registrar));
}
