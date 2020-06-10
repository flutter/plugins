// Copyright 2018 Google LLC
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
#ifndef PLUGINS_URL_LAUNCHER_LINUX_URL_LAUNCHER_PLUGIN_H_
#define PLUGINS_URL_LAUNCHER_LINUX_URL_LAUNCHER_PLUGIN_H_

// A plugin to launch URLs.

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __attribute__((visibility("default")))
#else
#define FLUTTER_PLUGIN_EXPORT
#endif

G_DECLARE_FINAL_TYPE(FlUrlLauncherPlugin, fl_url_launcher_plugin, FL, URL_LAUNCHER_PLUGIN,
                     GObject)

FLUTTER_PLUGIN_EXPORT FlUrlLauncherPlugin* fl_url_launcher_plugin_new(
    FlPluginRegistrar* registrar);

FLUTTER_PLUGIN_EXPORT void url_launcher_plugin_register_with_registrar(
    FlPluginRegistrar* registrar);

G_END_DECLS

#endif  // PLUGINS_URL_LAUNCHER_LINUX_URL_LAUNCHER_PLUGIN_H_
