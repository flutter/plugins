#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

function error() {
  echo "$@" 1>&2
}

# Runs the plugin tools from the plugin_tools git submodule.
function plugin_tools() {
  (pushd "$REPO_DIR/script/tool" && dart pub get && popd) >/dev/null
  dart run "$REPO_DIR/script/tool/lib/src/main.dart" "$@"
}
