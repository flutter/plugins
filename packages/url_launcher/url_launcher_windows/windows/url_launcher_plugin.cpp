// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#include "url_launcher_plugin.h"

#include <flutter/encodable_value.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <memory>
#include <string>

namespace url_launcher_plugin {

namespace {

using flutter::EncodableMap;
using flutter::EncodableValue;

// Returns the URL argument from |method_call| if it is present, otherwise
// returns an empty string.
std::string GetUrlArgument(const flutter::MethodCall<>& method_call) {
  std::string url;
  const auto* arguments = std::get_if<EncodableMap>(method_call.arguments());
  if (arguments) {
    auto url_it = arguments->find(EncodableValue("url"));
    if (url_it != arguments->end()) {
      url = std::get<std::string>(url_it->second);
    }
  }
  return url;
}

}  // namespace

// static
void UrlLauncherPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrar* registrar) {
  auto channel = std::make_unique<flutter::MethodChannel<>>(
      registrar->messenger(), "plugins.flutter.io/url_launcher",
      &flutter::StandardMethodCodec::GetInstance());

  std::unique_ptr<UrlLauncherPlugin> plugin =
      std::make_unique<UrlLauncherPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

UrlLauncherPlugin::UrlLauncherPlugin()
    : system_apis_(std::make_unique<SystemApisImpl>()) {}

UrlLauncherPlugin::UrlLauncherPlugin(std::unique_ptr<SystemApis> system_apis)
    : system_apis_(std::move(system_apis)) {}

UrlLauncherPlugin::~UrlLauncherPlugin() = default;

void UrlLauncherPlugin::HandleMethodCall(
    const flutter::MethodCall<>& method_call,
    std::unique_ptr<flutter::MethodResult<>> res) {
  if (method_call.method_name().compare("launch") == 0) {
    std::string url = GetUrlArgument(method_call);
    if (url.empty()) {
      res->Error("argument_error", "No URL provided");
      return;
    }

    LaunchUrl(url, std::move(res));
  } else if (method_call.method_name().compare("canLaunch") == 0) {
    std::string url = GetUrlArgument(method_call);
    if (url.empty()) {
      res->Error("argument_error", "No URL provided");
      return;
    }

    CanLaunchUrl(url, std::move(res));
  } else {
    res->NotImplemented();
  }
}

}  // namespace url_launcher_plugin
