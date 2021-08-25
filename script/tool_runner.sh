#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -e

# WARNING! Do not remove this script, or change its behavior, unless you have
# verified that it will not break the flutter/flutter analysis run of this
# repository: https://github.com/flutter/flutter/blob/master/dev/bots/test.dart

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly REPO_DIR="$(dirname "$SCRIPT_DIR")"
readonly TOOL_PATH="$REPO_DIR/script/tool/bin/flutter_plugin_tools.dart"

# Ensure that the tool dependencies have been fetched.
(pushd "$REPO_DIR/script/tool" && dart pub get && popd) >/dev/null

# The tool expects to be run from the repo root.
cd "$REPO_DIR"
# Run from the in-tree source.
dart run "$TOOL_PATH" "$@" --packages-for-branch $PLUGIN_SHARDING
