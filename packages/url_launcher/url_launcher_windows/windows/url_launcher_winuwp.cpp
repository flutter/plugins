// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.System.h>

#include <string>

#include "url_launcher_plugin_internal.h"

winrt::Windows::Foundation::IAsyncAction CanLaunchAsync(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> value,
    winrt::hstring url_string) {
  winrt::Windows::Foundation::Uri url_to_open(url_string);
  auto resturned_result =
      co_await winrt::Windows::System::Launcher::QueryUriSupportAsync(
          url_to_open, winrt::Windows::System::LaunchQuerySupportType::Uri);
  value->Success(flutter::EncodableValue(
      resturned_result ==
      winrt::Windows::System::LaunchQuerySupportStatus::Available));
}

winrt::Windows::Foundation::IAsyncAction OpenLinkAsync(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> value,
    winrt::hstring url_string) {
  winrt::Windows::Foundation::Uri url_to_open(url_string);
  auto resturned_result =
      co_await winrt::Windows::System::Launcher::LaunchUriAsync(url_to_open);
  value->Success(flutter::EncodableValue(resturned_result));
}

void CanLaunch(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> value,
    std::string url_string) {
  auto winrt_string = winrt::to_hstring(url_string);
  CanLaunchAsync(std::move(value), std::move(winrt_string));
}

void OpenLink(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> value,
    std::string url_string) {
  auto winrt_string = winrt::to_hstring(url_string);
  OpenLinkAsync(std::move(value), std::move(winrt_string));
}