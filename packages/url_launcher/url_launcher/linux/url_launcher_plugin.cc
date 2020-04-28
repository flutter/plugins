// Copyright 2019 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include "url_launcher_plugin.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar.h>
#include <flutter/standard_method_codec.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#include <memory>
#include <sstream>

namespace {

using flutter::EncodableMap;
using flutter::EncodableValue;

// Returns true if |s| starts with |prefix|.
bool StartsWith(const std::string &s, const std::string &prefix) {
  return s.compare(0, prefix.size(), prefix) == 0;
}

class UrlLauncherPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrar *registrar);

  virtual ~UrlLauncherPlugin();

 private:
  UrlLauncherPlugin();

  // Called when a method is called on the plugin's channel;
  void HandleMethodCall(
      const flutter::MethodCall<EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<EncodableValue>> result);
};

// static
void UrlLauncherPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrar *registrar) {
  auto channel = std::make_unique<flutter::MethodChannel<EncodableValue>>(
      registrar->messenger(), "plugins.flutter.io/url_launcher",
      &flutter::StandardMethodCodec::GetInstance());

  // Uses new instead of make_unique due to private constructor.
  std::unique_ptr<UrlLauncherPlugin> plugin(new UrlLauncherPlugin());

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

UrlLauncherPlugin::UrlLauncherPlugin() = default;

UrlLauncherPlugin::~UrlLauncherPlugin() = default;

void UrlLauncherPlugin::HandleMethodCall(
    const flutter::MethodCall<EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  if (method_call.method_name().compare("launch") == 0) {
    std::string url;
    if (method_call.arguments() && method_call.arguments()->IsMap()) {
      const EncodableMap &arguments = method_call.arguments()->MapValue();
      auto url_it = arguments.find(EncodableValue("url"));
      if (url_it != arguments.end()) {
        url = url_it->second.StringValue();
      }
    }
    if (url.empty()) {
      result->Error("argument_error", "No URL provided");
      return;
    }

    pid_t pid = fork();
    if (pid == 0) {
      execl("/usr/bin/xdg-open", "xdg-open", url.c_str(), nullptr);
      exit(1);
    }
    int status = 0;
    waitpid(pid, &status, 0);
    if (status != 0) {
      std::ostringstream error_message;
      error_message << "Failed to open " << url << ": error " << status;
      result->Error("open_error", error_message.str());
      return;
    }
    result->Success();
  } else if (method_call.method_name().compare("canLaunch") == 0) {
    std::string url;
    if (method_call.arguments() && method_call.arguments()->IsMap()) {
      const EncodableMap &arguments = method_call.arguments()->MapValue();
      auto url_it = arguments.find(EncodableValue("url"));
      if (url_it != arguments.end()) {
        url = url_it->second.StringValue();
      }
    }
    if (url.empty()) {
      result->Error("argument_error", "No URL provided");
      return;
    }

    flutter::EncodableValue response(
        StartsWith(url, "https:") || StartsWith(url, "http:") ||
        StartsWith(url, "ftp:") || StartsWith(url, "file:"));
    result->Success(&response);
    return;
  } else {
    result->NotImplemented();
  }
}

}  // namespace

void UrlLauncherPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  UrlLauncherPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrar>(registrar));
}
