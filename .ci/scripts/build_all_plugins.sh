#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

arg="$1"
cd all_packages
if [[ "$arg" == "web" ]]; then
  echo "Skipping; web does not support debug builds"
else
  flutter build "$arg" --debug
  flutter build "$arg" --release
fi
