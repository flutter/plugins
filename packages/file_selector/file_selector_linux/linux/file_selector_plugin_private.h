// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <flutter_linux/flutter_linux.h>

#include "include/file_selector_linux/file_selector_plugin.h"

// Creates a GtkFileChooserNative for the given method call.
GtkFileChooserNative* create_dialog_for_method(GtkWindow* window,
                                               const gchar* method,
                                               FlValue* properties);
