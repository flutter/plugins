// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "include/url_launcher_linux/url_launcher_plugin.h"

#include <flutter_linux/flutter_linux.h>

// Handles the canLaunch method call.
//
// Temporarily exposed for testing due to
// https://github.com/flutter/flutter/issues/88724
FlMethodResponse* can_launch(FlUrlLauncherPlugin* self, FlValue* args);
