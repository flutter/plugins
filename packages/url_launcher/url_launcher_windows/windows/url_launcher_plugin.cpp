// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#include "include/url_launcher_windows/url_launcher_plugin.h"


#include <windows.h>

#include <memory>
#include <sstream>
#include <string>

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

class UrlLauncherPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrar* registrar);

  virtual ~UrlLauncherPlugin();

 private:
  UrlLauncherPlugin();

  // Called when a method is called on plugin channel;
  void HandleMethodCall(const flutter::MethodCall<>& method_call,
                        std::unique_ptr<flutter::MethodResult<>> result);
};

// static
void UrlLauncherPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrar* registrar) {
  auto channel = std::make_unique<flutter::MethodChannel<>>(
      registrar->messenger(), "plugins.flutter.io/url_launcher",
      &flutter::StandardMethodCodec::GetInstance());

  // Uses new instead of make_unique due to private constructor.
  std::unique_ptr<UrlLauncherPlugin> plugin(new UrlLauncherPlugin());

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

UrlLauncherPlugin::UrlLauncherPlugin() = default;

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
       
    OpenLink(std::move(res), std::move(url)); 

  } else if (method_call.method_name().compare("canLaunch") == 0) {
    std::string url = GetUrlArgument(method_call);
    if (url.empty()) {
      res->Error("argument_error", "No URL provided");
      return;
    }

    CanLaunch(std::move(res), std::move(url));   
  } else {
    res->NotImplemented();
  }
}

}  // namespace

void UrlLauncherPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  UrlLauncherPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
