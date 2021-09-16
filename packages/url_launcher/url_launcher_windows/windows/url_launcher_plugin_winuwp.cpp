// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.System.h>

#include <string>

#include "url_launcher_plugin.h"

namespace url_launcher_plugin {

namespace {

winrt::Windows::Foundation::IAsyncAction CanLaunchAsync(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result,
    winrt::hstring url_string) {
  winrt::Windows::Foundation::Uri url_to_open(url_string);
  auto returned_result =
      co_await winrt::Windows::System::Launcher::QueryUriSupportAsync(
          url_to_open, winrt::Windows::System::LaunchQuerySupportType::Uri);
  result->Success(flutter::EncodableValue(
      returned_result ==
      winrt::Windows::System::LaunchQuerySupportStatus::Available));
}

winrt::Windows::Foundation::IAsyncAction OpenLinkAsync(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result,
    winrt::hstring url_string) {
  winrt::Windows::Foundation::Uri url_to_open(url_string);
  auto returned_result =
      co_await winrt::Windows::System::Launcher::LaunchUriAsync(url_to_open);
  result->Success(flutter::EncodableValue(returned_result));
}

}  // namespace

void UrlLauncherPlugin::CanLaunchUrl(
    const std::string& url, std::unique_ptr<flutter::MethodResult<>> result) {
  auto winrt_string = winrt::to_hstring(url);
  CanLaunchAsync(std::move(result), std::move(winrt_string));
}

void UrlLauncherPlugin::CanLaunchUrl(
    const std::string& url, std::unique_ptr<flutter::MethodResult<>> result) {
  auto winrt_string = winrt::to_hstring(url);
  OpenLinkAsync(std::move(result), std::move(winrt_string));
}

}  // namespace url_launcher_plugin
