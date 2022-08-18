// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PLUGINS_FILE_SELECTOR_LINUX_FILE_SELECTOR_PLUGIN_H_
#define PLUGINS_FILE_SELECTOR_LINUX_FILE_SELECTOR_PLUGIN_H_

// A plugin to show native save/open file choosers.

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __attribute__((visibility("default")))
#else
#define FLUTTER_PLUGIN_EXPORT
#endif

G_DECLARE_FINAL_TYPE(FlFileSelectorPlugin, fl_file_selector_plugin, FL,
                     FILE_SELECTOR_PLUGIN, GObject)

FLUTTER_PLUGIN_EXPORT FlFileSelectorPlugin* fl_file_selector_plugin_new(
    FlPluginRegistrar* registrar);

FLUTTER_PLUGIN_EXPORT void file_selector_plugin_register_with_registrar(
    FlPluginRegistrar* registrar);

G_END_DECLS

#endif  // PLUGINS_FILE_SELECTOR_LINUX_FILE_SELECTOR_PLUGIN_H_
