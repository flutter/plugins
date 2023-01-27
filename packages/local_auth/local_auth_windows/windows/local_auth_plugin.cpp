// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#include <winstring.h>

#include "local_auth.h"
#include "messages.g.h"

namespace {

// Returns the window's HWND for a given FlutterView.
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

}  // namespace

namespace local_auth_windows {

// Creates an instance of the UserConsentVerifier that
// calls the native Windows APIs to get the user's consent.
class UserConsentVerifierImpl : public UserConsentVerifier {
 public:
  explicit UserConsentVerifierImpl(std::function<HWND()> window_provider)
      : get_root_window_(std::move(window_provider)){};
  virtual ~UserConsentVerifierImpl() = default;

  // Calls the native Windows API to get the user's consent
  // with the provided reason.
  winrt::Windows::Foundation::IAsyncOperation<
      winrt::Windows::Security::Credentials::UI::UserConsentVerificationResult>
  RequestVerificationForWindowAsync(std::wstring localized_reason) override {
    winrt::impl::com_ref<IUserConsentVerifierInterop>
        user_consent_verifier_interop = winrt::get_activation_factory<
            winrt::Windows::Security::Credentials::UI::UserConsentVerifier,
            IUserConsentVerifierInterop>();

    HWND root_window_handle = get_root_window_();

    auto reason = wil::make_unique_string<wil::unique_hstring>(
        localized_reason.c_str(), localized_reason.size());

    winrt::Windows::Security::Credentials::UI::UserConsentVerificationResult
        consent_result = co_await winrt::capture<
            winrt::Windows::Foundation::IAsyncOperation<
                winrt::Windows::Security::Credentials::UI::
                    UserConsentVerificationResult>>(
            user_consent_verifier_interop,
            &::IUserConsentVerifierInterop::RequestVerificationForWindowAsync,
            root_window_handle, reason.get());

    return consent_result;
  }

  // Calls the native Windows API to check for the Windows Hello availability.
  winrt::Windows::Foundation::IAsyncOperation<
      winrt::Windows::Security::Credentials::UI::
          UserConsentVerifierAvailability>
  CheckAvailabilityAsync() override {
    return winrt::Windows::Security::Credentials::UI::UserConsentVerifier::
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
void LocalAuthPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<LocalAuthPlugin>(
      [registrar]() { return GetRootWindow(registrar->GetView()); });
  LocalAuthApi::SetUp(registrar->messenger(), plugin.get());
  registrar->AddPlugin(std::move(plugin));
}

// Default constructor for LocalAuthPlugin.
LocalAuthPlugin::LocalAuthPlugin(std::function<HWND()> window_provider)
    : user_consent_verifier_(std::make_unique<UserConsentVerifierImpl>(
          std::move(window_provider))) {}

LocalAuthPlugin::LocalAuthPlugin(
    std::unique_ptr<UserConsentVerifier> user_consent_verifier)
    : user_consent_verifier_(std::move(user_consent_verifier)) {}

LocalAuthPlugin::~LocalAuthPlugin() {}

void LocalAuthPlugin::IsDeviceSupported(
    std::function<void(ErrorOr<bool> reply)> result) {
  IsDeviceSupportedCoroutine(std::move(result));
}

void LocalAuthPlugin::Authenticate(
    const std::string& localized_reason,
    std::function<void(ErrorOr<bool> reply)> result) {
  AuthenticateCoroutine(localized_reason, std::move(result));
}

// Starts authentication process.
winrt::fire_and_forget LocalAuthPlugin::AuthenticateCoroutine(
    const std::string& localized_reason,
    std::function<void(ErrorOr<bool> reply)> result) {
  std::wstring reason = Utf16FromUtf8(localized_reason);

  winrt::Windows::Security::Credentials::UI::UserConsentVerifierAvailability
      ucv_availability =
          co_await user_consent_verifier_->CheckAvailabilityAsync();

  if (ucv_availability ==
      winrt::Windows::Security::Credentials::UI::
          UserConsentVerifierAvailability::DeviceNotPresent) {
    result(FlutterError("NoHardware", "No biometric hardware found"));
    co_return;
  } else if (ucv_availability ==
             winrt::Windows::Security::Credentials::UI::
                 UserConsentVerifierAvailability::NotConfiguredForUser) {
    result(
        FlutterError("NotEnrolled", "No biometrics enrolled on this device."));
    co_return;
  } else if (ucv_availability !=
             winrt::Windows::Security::Credentials::UI::
                 UserConsentVerifierAvailability::Available) {
    result(
        FlutterError("NotAvailable", "Required security features not enabled"));
    co_return;
  }

  try {
    winrt::Windows::Security::Credentials::UI::UserConsentVerificationResult
        consent_result =
            co_await user_consent_verifier_->RequestVerificationForWindowAsync(
                reason);

    result(consent_result == winrt::Windows::Security::Credentials::UI::
                                 UserConsentVerificationResult::Verified);
  } catch (...) {
    result(false);
  }
}

// Returns whether the device supports Windows Hello or not.
winrt::fire_and_forget LocalAuthPlugin::IsDeviceSupportedCoroutine(
    std::function<void(ErrorOr<bool> reply)> result) {
  winrt::Windows::Security::Credentials::UI::UserConsentVerifierAvailability
      ucv_availability =
          co_await user_consent_verifier_->CheckAvailabilityAsync();
  result(ucv_availability == winrt::Windows::Security::Credentials::UI::
                                 UserConsentVerifierAvailability::Available);
}

}  // namespace local_auth_windows
