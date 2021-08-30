#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -e

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Runs the plugin tools from the in-tree source.
function plugin_tools() {
  (pushd "$REPO_DIR/script/tool" && dart pub get && popd) >/dev/null
  dart run "$REPO_DIR/script/tool/bin/flutter_plugin_tools.dart" "$@"
}

ACTIONS=("$@")

# This has to be turned into a list and then split out to the command line,
# otherwise it gets treated as a single argument.
PLUGIN_SHARDING=($PLUGIN_SHARDING)

(cd "$REPO_DIR" && plugin_tools "${ACTIONS[@]}" --packages-for-branch ${PLUGIN_SHARDING[@]})
