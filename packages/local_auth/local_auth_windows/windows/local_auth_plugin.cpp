// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#include "local_auth.h"

namespace local_auth_windows {

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
std::wstring Utf16FromUtf8(const std::string& utf8_string) {
  if (utf8_string.empty()) {
    return std::wstring();
  }
  int target_length =
      ::MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, utf8_string.data(),
                            static_cast<int>(utf8_string.length()), nullptr, 0);
  if (target_length == 0) {
    return std::wstring();
  }
  std::wstring utf16_string;
  utf16_string.resize(target_length);
  int converted_length =
      ::MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, utf8_string.data(),
                            static_cast<int>(utf8_string.length()),
                            utf16_string.data(), target_length);
  if (converted_length == 0) {
    return std::wstring();
  }
  return utf16_string;
}

class UserConsentVerifierImpl : public UserConsentVerifier {
 public:
  explicit UserConsentVerifierImpl(std::function<HWND()> window_provider)
      : get_root_window_(std::move(window_provider)){};
  virtual ~UserConsentVerifierImpl() = default;

  Windows::Foundation::IAsyncOperation<
      Windows::Security::Credentials::UI::UserConsentVerificationResult>
  RequestVerificationForWindowAsync(std::wstring localizedReason) override {
    auto userConsentVerifierInterop = winrt::get_activation_factory<
        Windows::Security::Credentials::UI::UserConsentVerifier,
        IUserConsentVerifierInterop>();

    auto hWnd = get_root_window_();

    HSTRING hReason;
    if (WindowsCreateString(localizedReason.c_str(),
                            static_cast<uint32_t>(localizedReason.size()),
                            &hReason) != S_OK) {
      return Windows::Security::Credentials::UI::UserConsentVerificationResult::
          Canceled;
    }

    auto consentResult =
        co_await winrt::capture<Windows::Foundation::IAsyncOperation<
            Windows::Security::Credentials::UI::UserConsentVerificationResult>>(
            userConsentVerifierInterop,
            &::IUserConsentVerifierInterop::RequestVerificationForWindowAsync,
            hWnd, hReason);

    WindowsDeleteString(hReason);

    return consentResult;
  }

  Windows::Foundation::IAsyncOperation<
      Windows::Security::Credentials::UI::UserConsentVerifierAvailability>
  CheckAvailabilityAsync() override {
    return Windows::Security::Credentials::UI::UserConsentVerifier::
        CheckAvailabilityAsync();
  }

  // Disallow copy and move.
  UserConsentVerifierImpl(const UserConsentVerifierImpl&) = delete;
  UserConsentVerifierImpl& operator=(const UserConsentVerifierImpl&) = delete;

 private:
  // The provider for the root window to attach the dialog to.
  std::function<HWND()> get_root_window_;
};

// static
void LocalAuthPlugin::RegisterWithRegistrar(PluginRegistrarWindows* registrar) {
  auto channel = std::make_unique<MethodChannel<EncodableValue>>(
      registrar->messenger(), "plugins.flutter.io/local_auth_windows",
      &StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<LocalAuthPlugin>(
      [registrar]() { return GetRootWindow(registrar->GetView()); });

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

// Default constructor for LocalAuthPlugin
LocalAuthPlugin::LocalAuthPlugin(std::function<HWND()> window_provider)
    : user_consent_verifier_(std::make_unique<UserConsentVerifierImpl>(
          std::move(window_provider))) {}

LocalAuthPlugin::LocalAuthPlugin(
    std::unique_ptr<UserConsentVerifier> user_consent_verifier)
    : user_consent_verifier_(std::move(user_consent_verifier)) {}

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
  auto reasonW = Utf16FromUtf8(GetArgument<std::string>(
      "localizedReason", method_call.arguments(), std::string()));

  auto biometricOnly =
      GetArgument<bool>("biometricOnly", method_call.arguments(), false);
  if (biometricOnly) {
    result->Error("biometricOnlyNotSupported",
                  "Windows doesn't support the biometricOnly parameter.");
    co_return;
  }

  auto ucvAvailability =
      co_await user_consent_verifier_->CheckAvailabilityAsync();

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

  try {
    auto consentResult =
        co_await user_consent_verifier_->RequestVerificationForWindowAsync(
            reasonW);

    result->Success(EncodableValue(
        consentResult == Windows::Security::Credentials::UI::
                             UserConsentVerificationResult::Verified));
  } catch (...) {
    result->Success(EncodableValue(false));
  }
}

// Returns biometric types available on device
winrt::fire_and_forget LocalAuthPlugin::GetAvailableBiometrics(
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  try {
    flutter::EncodableList biometrics;
    auto ucvAvailability =
        co_await user_consent_verifier_->CheckAvailabilityAsync();
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
  auto ucvAvailability =
      co_await user_consent_verifier_->CheckAvailabilityAsync();
  result->Success(EncodableValue(
      ucvAvailability == Windows::Security::Credentials::UI::
                             UserConsentVerifierAvailability::Available));
}

}  // namespace local_auth_windows
