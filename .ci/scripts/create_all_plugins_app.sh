#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

dart pub global run flutter_plugin_tools create-all-packages-app \
    --output-dir=. --exclude script/configs/exclude_all_packages_app.yaml
