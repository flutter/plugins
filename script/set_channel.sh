#!/bin/bash
# Copyright 202 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -e

# Set up the repository to the right channel before doing any Flutter operations
# to ensure the upgrade doesn't start off by downloading the wrong Dart SDK
# version.
git co $@
git pull
# Run the normal channel-switch code to ensure that all the state is correct.
flutter channel $@
flutter upgrade
